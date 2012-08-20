class CreateInsertShoolInfoFunction < ActiveRecord::Migration
  def up
    execute %Q{
      CREATE OR REPLACE FUNCTION rollcall_insert_school_info(_tea_id integer, _record_date date,  _absent integer, _enrolled integer) RETURNS VOID AS $$
        BEGIN
          IF EXISTS(SELECT *
           FROM rollcall_school_daily_infos rsdi
           JOIN rollcall_schools rs ON rsdi.school_id = rs.id
          WHERE rs.tea_id = _tea_id
            AND rsdi.report_date = _record_date) THEN
            
            UPDATE rollcall_school_daily_infos
            SET total_absent = COALESCE(_absent, total_absent),
                total_enrolled = COALESCE(_enrolled, total_enrolled)
            FROM rollcall_schools rs
            WHERE rollcall_school_daily_infos.school_id = rs.id
            AND rs.tea_id = _tea_id
            AND rollcall_school_daily_infos.report_date = _record_date;
      
          ELSE
      
            INSERT INTO rollcall_school_daily_infos(school_id, total_absent, total_enrolled, report_date, created_at, updated_at)
            SELECT DISTINCT rs.id, _absent, _enrolled, _record_date, current_timestamp, current_timestamp
            FROM rollcall_schools rs
            where rs.tea_id = _tea_id;
      
          END IF;
        END;
      $$ LANGUAGE plpgsql;
    }
    
    execute %Q{
      CREATE OR REPLACE FUNCTION rollcall_update_district_info(_district_tea_id integer, _record_date date) RETURNS VOID AS $$
        BEGIN
          DELETE FROM rollcall_school_district_daily_infos
          USING rollcall_school_districts rsd
          WHERE rollcall_school_district_daily_infos.school_district_id = rsd.id
            AND rsd.district_id = _district_tea_id
            AND rollcall_school_district_daily_infos.report_date = _record_date;
      
          INSERT INTO rollcall_school_district_daily_infos(report_date, absentee_rate, total_enrollment, total_absent, school_district_id)
          SELECT _record_date, cast(SUM(total_absent) as float)/cast(SUM(total_enrolled) as float), SUM(total_enrolled), SUM(total_absent), rsd.id
          FROM rollcall_school_districts rsd
          JOIN rollcall_schools rs on rsd.id = rs.district_id
          JOIN rollcall_school_daily_infos rsdi on rs.id = rsdi.school_id
          WHERE rsd.district_id = _district_tea_id
            AND rsdi.report_date = _record_date
          GROUP BY rsd.id;
        END;
      $$ LANGUAGE plpgsql;
    }
  end

  def down
    execute "DROP FUNCTION rollcall_insert_school_info(integer, date, integer, integer)"
  end
end
