class UpdateInsertFunctions < ActiveRecord::Migration
  def change
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
            FROM student_daily_infos
            JOIN students ON student_daily_infos.student_id = students.id
            JOIN schools ON students.school_id = schools.id
            WHERE cid = _cid
              AND health_year = _year
              AND schools.tea_id = _tea_id) 
          THEN
            -- find the user's school 
            SELECT INTO _school_id id
            FROM schools
            WHERE tea_id = _tea_id;
          
            -- insert the student
            INSERT INTO students(zip, gender, school_id)
            VALUES (_zip, _gender, _school_id);
            
            SELECT INTO _student_id CURRVAL(pg_get_serial_sequence('students','id'));
            
            -- insert the student info            
            INSERT INTO student_daily_infos(cid, student_id, report_date, grade, confirmed_illness, health_year, date_of_onset, temperature, in_school, released, diagnosis, treatment, follow_up, doctor, doctor_address)
            VALUES(_cid, _student_id, _date, _grade, _confirmed, _year, COALESCE(_onset, _date), _temp, _in_school, _released, _symptoms, _treatment, _follow_up, _doc, _doc_address);
            
            SELECT INTO _info_id CURRVAL(pg_get_serial_sequence('student_daily_infos', 'id'));
            
          -- if it exists:
          ELSE
            -- update the student
            UPDATE students
            SET zip = _zip,
                gender = _gender
            FROM student_daily_infos, schools
            WHERE student_daily_infos.cid = _cid
              AND student_daily_infos.health_year = _year
              AND schools.id = students.school_id
              AND schools.tea_id = _tea_id
              AND students.id = student_daily_infos.student_id;
               
            -- update the student info
            UPDATE student_daily_infos
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
            FROM students
            JOIN schools ON students.school_id = schools.id
            WHERE cid = _cid
              AND health_year = _year
              AND student_daily_infos.student_id = students.id
              AND schools.tea_id = _tea_id;
                        
            -- update the symptoms (by deleteing them and letting it fall to the catch-all below)
            SELECT INTO _info_id student_daily_infos.id
            FROM student_daily_infos
            JOIN students ON student_daily_infos.student_id = students.id
            JOIN schools ON students.school_id = schools.id
            WHERE cid = _cid
              AND health_year = _year
              AND schools.tea_id = _tea_id;
            
            DELETE FROM student_reported_symptoms
            WHERE student_daily_info_id = _info_id;            
          END IF;
          
          IF _info_id IS NOT NULL THEN
            -- link symptoms
            INSERT INTO student_reported_symptoms(symptom_id, student_daily_info_id)
            SELECT id, _info_id
            FROM symptoms
            WHERE _symptoms ~ ('(?i)'||name);
          END IF;
        END;
      $$ LANGUAGE plpgsql;
    }
    
    execute %Q{
      CREATE OR REPLACE FUNCTION rollcall_insert_school_info(_tea_id integer, _record_date date,  _absent integer, _enrolled integer) RETURNS VOID AS $$
        BEGIN
          IF EXISTS(SELECT *
           FROM school_daily_infos rsdi
           JOIN schools rs ON rsdi.school_id = rs.id
          WHERE rs.tea_id = _tea_id
            AND rsdi.report_date = _record_date) THEN
            
            UPDATE school_daily_infos
            SET total_absent = COALESCE(_absent, total_absent),
                total_enrolled = COALESCE(_enrolled, total_enrolled)
            FROM schools rs
            WHERE school_daily_infos.school_id = rs.id
            AND rs.tea_id = _tea_id
            AND school_daily_infos.report_date = _record_date;
      
          ELSE
      
            INSERT INTO school_daily_infos(school_id, total_absent, total_enrolled, report_date, created_at, updated_at)
            SELECT DISTINCT rs.id, _absent, _enrolled, _record_date, current_timestamp, current_timestamp
            FROM schools rs
            where rs.tea_id = _tea_id;
      
          END IF;
        END;
      $$ LANGUAGE plpgsql;
    }
    
    execute %Q{
      CREATE OR REPLACE FUNCTION rollcall_update_district_info(_district_tea_id integer, _record_date date) RETURNS VOID AS $$
        BEGIN
          DELETE FROM school_district_daily_infos
          USING school_districts rsd
          WHERE school_district_daily_infos.school_district_id = rsd.id
            AND rsd.state_id = _district_tea_id
            AND school_district_daily_infos.report_date = _record_date;
      
          INSERT INTO school_district_daily_infos(report_date, absentee_rate, total_enrollment, total_absent, school_district_id)
          SELECT _record_date, cast(SUM(total_absent) as float)/cast(SUM(total_enrolled) as float), SUM(total_enrolled), SUM(total_absent), rsd.id
          FROM school_districts rsd
          JOIN schools rs on rsd.id = rs.school_district_id
          JOIN school_daily_infos rsdi on rs.id = rsdi.school_id
          WHERE rsd.state_id = _district_tea_id
            AND rsdi.report_date = _record_date
          GROUP BY rsd.id;
        END;
      $$ LANGUAGE plpgsql;
    }
  end
end
