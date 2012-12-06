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
      val[:absence_rate] = sd.school_daily_infos
      # find confirmed illness
      # find
      params[:school_districts] << val
    end
  end
end