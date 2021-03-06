class RollcallStatusUpdater < BackgrounDRb::MetaWorker
  set_worker_name :rollcall_status_updater
  reload_on_schedule true

  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def mail_status()
    users = Role.superadmins("rollcall").first.users
    school_districts = Rollcall::Status.get_school_districts.having("MAX(rsdi.report_date) < CURRENT_DATE - 7")
    schools = Rollcall::Status.get_schools
    
    unless school_districts.count == 0 && schools.count == 0
      RollcallStatusMailer.send_status(users, school_districts, schools).deliver
    end
  end
end