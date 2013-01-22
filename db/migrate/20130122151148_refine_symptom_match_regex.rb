class RefineSymptomMatchRegex < ActiveRecord::Migration
  def up
    # create symptom search function
    execute %Q{CREATE OR REPLACE FUNCTION rollcall_symptom_match(_info_id int) RETURNS VOID AS $$
      BEGIN
        INSERT INTO rollcall_student_reported_symptoms(symptom_id, student_daily_info_id)
        SELECT DISTINCT tag.symptom_id, info.id
        FROM rollcall_symptom_tags tag
        JOIN rollcall_student_daily_infos info ON info.diagnosis ~* ('(^|\\W)'||tag.match||'($|\\W)')
        WHERE info.id = _info_id;

        -- If the record's temperature is over 99 degrees go ahead and mark it as a fever
        IF EXISTS (SELECT * FROM rollcall_student_daily_infos WHERE id = _info_id AND temperature > 99)
        AND NOT EXISTS (SELECT *
                        FROM rollcall_student_daily_infos info
                        JOIN rollcall_student_reported_symptoms srs ON info.id = srs.student_daily_info_id
                        JOIN rollcall_symptoms symptom ON srs.symptom_id = symptom.id
                        WHERE info.id = _info_id AND symptom.icd9_code = '780.60'
                        )
        THEN
          INSERT INTO rollcall_student_reported_symptoms(symptom_id, student_daily_info_id)
          SELECT id, _info_id
          FROM rollcall_symptoms
          WHERE icd9_code = '780.60';
        END IF;

        -- If the record has the confirmed flu keyword, mark it as a confirmed illness
        IF EXISTS (SELECT * FROM rollcall_student_daily_infos WHERE id = _info_id AND diagnosis ~ 'Influenza \\(Flu\\)' )
        THEN
          UPDATE rollcall_student_daily_infos
          SET confirmed_illness = true
          WHERE id = _info_id;
        END IF;
      END;
      $$ LANGUAGE plpgsql;
    }
  end

  def down
  end
end
