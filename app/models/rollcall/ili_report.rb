class Rollcall::ILIReport < ::Report
  view = 'rollcall/ili_report'
  
  def self.build_report(user_id)
    # in here we're going to put together the parameters that we want to save off for the report.
    r = self.new user_id: user_id
    user = ::User.find(user_id) 
    
    params = {school_districts: []}
    
    school_districts = user.school_districts
    school_districts.each do |sd|
      val = {district: sd}
      # find the absence rate for the school district
      val[:rates] = sd.school_daily_infos.select('SUM(total_enrolled) as enrolled, SUM(total_absent) as absent, SUM(total_absent)::float/SUM(total_enrolled) as rate').group(:report_date).having('report_date > (current_date - 7)').as_json
      # find confirmed illness
      val[:confirmed] = sd.
      # find ili
      val[:ili] 
      
      params[:school_districts] << val
    end
  end
end