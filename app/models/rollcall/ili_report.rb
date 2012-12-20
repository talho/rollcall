class Rollcall::ILIReport < ::Report
  self.view = 'rollcall/ili_report'
  
  self.run_detached = true
  
  def self.build_report(user_id)
    # in here we're going to put together the parameters that we want to save off for the report.
    r = self.new user_id: user_id
    user = ::User.find(user_id) 
    
    params = {totals: [], school_districts: []}
    
    icd9_codes = ['487.1', '780.60', '780.64', '787.02'];
    
    params[:totals] = Rollcall::SchoolDailyInfo.select('report_date, SUM(total_enrolled) as enrolled, SUM(total_absent) as absent, SUM(total_absent)::float/nullif(SUM(total_enrolled), 0) as rate').order(:report_date)
                    .group(:report_date).having('report_date > (current_date - 7) AND report_date <= current_date').as_json    
    confirmed = Rollcall::StudentDailyInfo.select("report_date, count(*) as total").where(confirmed_illness: true).order(:report_date).group(:report_date).where("report_date > (current_date -7) AND report_date <= current_date").as_json
    ili = Rollcall::StudentDailyInfo.select("report_date, count(*) as total").joins(:symptoms).where("icd9_code in (#{icd9_codes.map{|c| "'#{c}'"}.join(',')})").where("report_date > (current_date -7) AND report_date <= current_date").order(:report_date).group(:report_date).as_json
    params[:totals].each do |v|
      v['confirmed'] = (confirmed.select{|c| c["report_date"] == v["report_date"]}.first || {})["total"] 
      v['ili'] = (ili.select{|i| i["report_date"] == v["report_date"]}.first || {})["total"] 
      v["report_date"] = v["report_date"].to_time
    end
    
    school_districts = user.school_districts
    school_districts.each do |sd|
      val = {district: sd.as_json(:only => [:id, :district_id, :jurisdiction_id, :name])}
      # find the absence rate for the school district
      val[:rates] = sd.school_daily_infos.select('report_date, SUM(total_enrolled) as enrolled, SUM(total_absent) as absent, SUM(total_absent)::float/nullif(SUM(total_enrolled), 0) as rate').order(:report_date)
                    .group(:report_date).having('report_date > (current_date - 7) AND report_date <= current_date').as_json
      val[:rates].each{|v| v["report_date"] = v["report_date"].to_time}
      # find confirmed illness
      val[:confirmed] = sd.student_daily_infos.select("report_date, count(*) as total").where(confirmed_illness: true).order(:report_date).group(:report_date).where("report_date > (current_date -7) AND report_date <= current_date").as_json
      val[:confirmed].each{|v| v["report_date"] = v["report_date"].to_time}
      # find ili
      val[:ili] = sd.student_daily_infos.select("report_date, count(*) as total").joins(:symptoms).where("icd9_code in (#{icd9_codes.map{|c| "'#{c}'"}.join(',')})").where("report_date > (current_date -7) AND report_date <= current_date").order(:report_date).group(:report_date).as_json
      val[:ili].each{|v| v["report_date"] = v["report_date"].to_time}
      
      schools_with_ili = sd.schools.select("rollcall_schools.*, confirmed, ili")
                                   .joins("LEFT JOIN (SELECT school_id, count(*) as confirmed
                                             FROM   rollcall_student_daily_infos
                                             JOIN   rollcall_students on rollcall_student_daily_infos.student_id = rollcall_students.id
                                             WHERE  report_date > (current_date -7)
                                               AND  report_date <= current_date
                                               AND  confirmed_illness = 't'
                                             GROUP BY school_id) confirmed on rollcall_schools.id = confirmed.school_id")
                                   .joins("LEFT JOIN (SELECT school_id, count(*) as ili
                                             FROM   rollcall_student_daily_infos
                                             JOIN   rollcall_students on rollcall_student_daily_infos.student_id = rollcall_students.id
                                             JOIN   rollcall_student_reported_symptoms on rollcall_student_daily_infos.id = rollcall_student_reported_symptoms.student_daily_info_id
                                             JOIN   rollcall_symptoms on rollcall_student_reported_symptoms.symptom_id = rollcall_symptoms.id
                                             WHERE  report_date > (current_date -7)
                                               AND  report_date <= current_date
                                               AND  icd9_code in (#{icd9_codes.map{|c| "'#{c}'"}.join(',')})
                                             GROUP BY school_id) ili on rollcall_schools.id = ili.school_id")
                                   .where("confirmed > 0 or ili > 0")
                                   .order("display_name")
      
      val[:schools_with_ili] = schools_with_ili.as_json(:only => [:display_name, :confirmed, :ili])
      
      schools_above_average = sd.schools.select("display_name, report_date, total_absent::float/nullif(total_enrolled, 0) as rate, total_absent, total_enrolled, absent_dev, absent_avg")
                                        .joins("JOIN rollcall_school_daily_infos on rollcall_schools.id = rollcall_school_daily_infos.school_id")
                                        .joins("JOIN (SELECT school_id, STDDEV(total_absent) as absent_dev, AVG(total_absent) as absent_avg
                                                      FROM   rollcall_school_daily_infos
                                                      WHERE  report_date > (current_date - 60)
                                                      GROUP BY school_id) as deviation on deviation.school_id = rollcall_schools.id")
                                        .where("report_date > (current_date - 7)
                                           AND  report_date <= current_date
                                           AND  (total_absent - absent_avg) > absent_dev")
                                        .order("display_name, report_date").as_json
      schools_above_average.each{|v| v["report_date"] = v["report_date"].to_time}
      
      val[:schools_above_average] = schools_above_average
      
      params[:school_districts] << val
    end
    
    r.params = params
    r
  end
  
  def self.run_detached?
    true
  end
  
  def self.user_can_run?(user_id)
    User.find(user_id).has_non_public_role?('rollcall')
  end
end