class Rollcall::StatusController < Rollcall::RollcallAppController
  before_filter :rollcall_admin_required
  
  respond_to :json
  layout false

  #GET rollcall/status
  def index
    if current_user.is_super_admin?("rollcall")
      @school_districts = Rollcall::Status.get_school_districts.having("MAX(rsdi.report_date) < CURRENT_DATE - 7")
      @schools = Rollcall::Status.get_schools
          
      respond_with(@school_districts, @schools)
    else
      render :json => "You are not authorized for access.", :status => :unauthorized
    end    
  end
end