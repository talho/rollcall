class Rollcall::Status
  def self.get_school_districts
    Rollcall::SchoolDistrict.select('rollcall_school_districts.name as "School District", rollcall_school_districts.id as id, MAX(rsdi.report_date) as "Last Reported Date"')
      .joins("JOIN rollcall_schools as rs ON rollcall_school_districts.id = rs.district_id")
      .joins("JOIN rollcall_school_daily_infos rsdi ON rs.id = rsdi.school_id")
      .order('MAX(rsdi.report_date) desc, rollcall_school_districts.name')
      .group("rollcall_school_districts.name, rollcall_school_districts.id")      
  end
  
  def self.get_schools
    Rollcall::School.select('rollcall_schools.display_name as "School", sd."School District" as "School District", rsdi.report_date as "Last Reported Date"')
      .joins("JOIN (#{self.get_school_districts.to_sql}) as sd on rollcall_schools.district_id = sd.id")
      .joins("JOIN (SELECT school_id, MAX(report_date) as report_date
                    FROM rollcall_school_daily_infos
                    GROUP BY school_id) as rsdi on rsdi.school_id = rollcall_schools.id")
      .where('rsdi.report_date != sd."Last Reported Date"')
      .order('rollcall_schools.display_name, sd."School District", rsdi.report_date')
  end
end