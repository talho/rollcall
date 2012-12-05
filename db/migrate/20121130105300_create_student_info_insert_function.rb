class CreateStudentInfoInsertFunction < ActiveRecord::Migration
  def up
    execute %Q{
      CREATE OR REPLACE FUNCTION rollcall_insert_student_info(_cid varchar(255), _year varchar(4), _tea_id int, _date date, _temp float, _grade int, _zip int, _gender varchar(1), _doc varchar(200), _doc_address varchar(200), 
                                                              _symptoms text, _treatment text, _follow_up date, _confirmed boolean, _in_school boolean, _released boolean) RETURNS VOID AS $$
        DECLARE
          _student_id integer;
          _info_id integer;
          _school_id integer;
        BEGIN
          -- find if the record already exists based on cid
          -- if it does not exist:
          IF NOT EXISTS (SELECT * FROM rollcall_student_daily_infos WHERE cid = _cid) THEN
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
            VALUES(_cid, _student_id, _date, _grade, _confirmed, _year, _date, _temp, _in_school, _released, _symptoms, _treatment, _follow_up, _doc, _doc_address);
            
            SELECT INTO _info_id CURRVAL(pg_get_serial_sequence('rollcall_student_daily_infos', 'id'));
            
          -- if it exists:
          ELSE
            -- update the student
            UPDATE rollcall_students
            SET zip = _zip,
                gender = _gender
            FROM rollcall_student_daily_infos
            WHERE cid = _cid
              AND rollcall_students.id = rollcall_student_daily_infos.student_id;
               
            -- update the student info
            UPDATE rollcall_student_daily_infos
            SET grade = COALESCE(grade, _grade), 
                confirmed_illness = COALESCE(_confirmed, confirmed_illness), 
                health_year = COALESCE(_year, health_year),
                date_of_onset = COALESCE(_date, date_of_onset), 
                temperature = COALESCE(_temp, temperature), 
                in_school = COALESCE(_in_school, in_school), 
                released = COALESCE(_released, released), 
                diagnosis = COALESCE(_symptoms, diagnosis), 
                treatment = COALESCE(_treatment, treatment), 
                follow_up = COALESCE(_follow_up, follow_up), 
                doctor = COALESCE(_doc, doctor), 
                doctor_address = COALESCE(_doc_address, doctor_address)
            WHERE cid = _cid;
            
            -- update the symptoms (by deleteing them and letting it fall to the catch-all below)
            SELECT INTO _info_id id
            FROM rollcall_student_daily_infos
            WHERE cid = _cid;
            
            DELETE FROM rollcall_student_reported_symptoms
            WHERE student_daily_info_id = _info_id;            
          END IF;
          
          IF _info_id IS NOT NULL THEN
            -- link symptoms
            INSERT INTO rollcall_student_reported_symptoms(symptom_id, student_daily_info_id)
            SELECT id, _info_id
            FROM rollcall_symptoms
            WHERE _symptoms ~ ('(?i)'||name);
          END IF;
        END;
      $$ LANGUAGE plpgsql;
    }
    
    # We're not using this anymore, blank it out until we can upgrade all the import scripts to not call it.
    execute %Q{
      CREATE OR REPLACE FUNCTION rollcall_update_district_info(_district_tea_id integer, _record_date date) RETURNS VOID AS $$
        BEGIN
          
        END;
      $$ LANGUAGE plpgsql;
    }
  end

  def down
    execute "DROP FUNCTION rollcall_insert_student_info(varchar, varchar, int, date, float, int, int, varchar, varchar, varchar, text, text, date, boolean, boolean, boolean)"
  end
end