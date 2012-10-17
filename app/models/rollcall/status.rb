class Rollcall::Status
  def self.get_school_districts
    Rollcall::SchoolDistrict.joins("inner join (select max(report_date), school_district_id from rollcall_school_district_daily_infos group by school_district_id) as I on I.school_district_id = rollcall_school_districts.id")
      .where("rollcall_school_districts.id not in (select T1.id from (select * from 
        (select id from rollcall_school_districts) as SchoolDs
          cross join 
        (select generate_series::date as \"Date\" from generate_series(current_date - 7, current_date - 1, interval '1 day') where extract(dow from generate_series::date) not in (6,0)) as DatesTable) as T1
        inner join rollcall_school_district_daily_infos I on I.report_date = T1.\"Date\" and T1.id = I.school_district_id
        group by T1.id having count(*) = 5)")
      .select('rollcall_school_districts.name as "School District", I.max as "Last Reported Date"')
      .order("max, rollcall_school_districts.name")
  end
  
  def self.get_schools
    Rollcall::School.joins("inner join (select max(report_date), school_id from rollcall_school_daily_infos group by school_id) as I on I.school_id = rollcall_schools.id")
      .joins("inner join rollcall_school_districts SD on rollcall_schools.district_id = SD.id")
      .where("rollcall_schools.id not in (select T1.id from (select * from 
        (select id from rollcall_schools) as Schools
          cross join 
        (select generate_series::date as \"Date\" from generate_series(current_date - 7, current_date - 1, interval '1 day') where extract(dow from generate_series::date) not in (6,0)) as DatesTable) as T1
        inner join rollcall_school_daily_infos I on I.report_date = T1.\"Date\" and T1.id = I.school_id
        group by T1.id having count(*) = 5)")
      .select('rollcall_schools.display_name as "School", SD.name as "School District", I.max as "Last Reported Date"')
      .order("max, SD.name, rollcall_schools.display_name")
  end
end