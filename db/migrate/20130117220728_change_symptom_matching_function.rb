class ChangeSymptomMatchingFunction < ActiveRecord::Migration
  def up
    # create symptom search function
    execute %Q{CREATE OR REPLACE FUNCTION rollcall_symptom_match(_info_id int) RETURNS VOID AS $$
      BEGIN
        INSERT INTO rollcall_student_reported_symptoms(symptom_id, student_daily_info_id)
        SELECT DISTINCT tag.symptom_id, info.id
        FROM rollcall_symptom_tags tag
        JOIN rollcall_student_daily_infos info ON info.diagnosis ~ ('(?i)'||tag.match)
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

    # perform, not select
    execute %Q{
      CREATE OR REPLACE FUNCTION rollcall_insert_student_info(_cid varchar(255), _year varchar(20), _tea_id int, _date date, _onset date, _temp float, _grade int, _zip int, _gender varchar(1), _doc varchar(200), _doc_address varchar(200),
                                                              _symptoms text, _treatment text, _follow_up date, _confirmed boolean, _in_school boolean, _released boolean) RETURNS VOID AS $$
        DECLARE
          _student_id integer;
          _info_id integer;
          _school_id integer;
        BEGIN
          -- find if the record already exists based on cid
          -- if it does not exist:
          IF NOT EXISTS (SELECT *
            FROM rollcall_student_daily_infos
            JOIN rollcall_students ON rollcall_student_daily_infos.student_id = rollcall_students.id
            JOIN rollcall_schools ON rollcall_students.school_id = rollcall_schools.id
            WHERE cid = _cid
              AND health_year = _year
              AND rollcall_schools.tea_id = _tea_id)
          THEN
            -- find the user's school
            SELECT INTO _school_id id
            FROM rollcall_schools
            WHERE tea_id = _tea_id;

            -- insert the student
            INSERT INTO rollcall_students(zip, gender, school_id)
            VALUES (_zip, _gender, _school_id);

            SELECT INTO _student_id CURRVAL(pg_get_serial_sequence('rollcall_students','id'));

            -- insert the student info
            INSERT INTO rollcall_student_daily_infos(cid, student_id, report_date, grade, confirmed_illness, health_year, date_of_onset, temperature, in_school, released, diagnosis, treatment, follow_up, doctor, doctor_address)
            VALUES(_cid, _student_id, _date, _grade, _confirmed, _year, COALESCE(_onset, _date), _temp, _in_school, _released, _symptoms, _treatment, _follow_up, _doc, _doc_address);

            SELECT INTO _info_id CURRVAL(pg_get_serial_sequence('rollcall_student_daily_infos', 'id'));

          -- if it exists:
          ELSE
            -- update the student
            UPDATE rollcall_students
            SET zip = _zip,
                gender = _gender
            FROM rollcall_student_daily_infos, rollcall_schools
            WHERE rollcall_student_daily_infos.cid = _cid
              AND rollcall_student_daily_infos.health_year = _year
              AND rollcall_schools.id = rollcall_students.school_id
              AND rollcall_schools.tea_id = _tea_id
              AND rollcall_students.id = rollcall_student_daily_infos.student_id;

            -- update the student info
            UPDATE rollcall_student_daily_infos
            SET grade = COALESCE(grade, _grade),
                confirmed_illness = COALESCE(_confirmed, confirmed_illness),
                date_of_onset = COALESCE(_onset, _date, date_of_onset),
                temperature = COALESCE(_temp, temperature),
                in_school = COALESCE(_in_school, in_school),
                released = COALESCE(_released, released),
                diagnosis = COALESCE(_symptoms, diagnosis),
                treatment = COALESCE(_treatment, treatment),
                follow_up = COALESCE(_follow_up, follow_up),
                doctor = COALESCE(_doc, doctor),
                doctor_address = COALESCE(_doc_address, doctor_address)
            FROM rollcall_students
            JOIN rollcall_schools ON rollcall_students.school_id = rollcall_schools.id
            WHERE cid = _cid
              AND health_year = _year
              AND rollcall_student_daily_infos.student_id = rollcall_students.id
              AND rollcall_schools.tea_id = _tea_id;

            -- update the symptoms (by deleteing them and letting it fall to the catch-all below)
            SELECT INTO _info_id rollcall_student_daily_infos.id
            FROM rollcall_student_daily_infos
            JOIN rollcall_students ON rollcall_student_daily_infos.student_id = rollcall_students.id
            JOIN rollcall_schools ON rollcall_students.school_id = rollcall_schools.id
            WHERE cid = _cid
              AND health_year = _year
              AND rollcall_schools.tea_id = _tea_id;

            DELETE FROM rollcall_student_reported_symptoms
            WHERE student_daily_info_id = _info_id;
          END IF;

          IF _info_id IS NOT NULL THEN
            PERFORM rollcall_symptom_match(_info_id);
          END IF;
        END;
      $$ LANGUAGE plpgsql;
    }
  end

  def down
    # create symptom search function
    execute %Q{CREATE OR REPLACE FUNCTION rollcall_symptom_match(_info_id int) RETURNS VOID AS $$
      BEGIN
        INSERT INTO rollcall_student_reported_symptoms(symptom_id, student_daily_info_id)
        SELECT DISTINCT tag.symptom_id, info.id
        FROM rollcall_symptom_tags tag
        JOIN rollcall_student_daily_infos info ON info.diagnosis ~ ('(?i)'||tag.match)
        WHERE info.id = _info_id;
      END;
      $$ LANGUAGE plpgsql;
    }
  end
end
