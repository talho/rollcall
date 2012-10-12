class Rollcall::StatusController < Rollcall::RollcallAppController
  before_filter :rollcall_admin_required
  
  respond_to :json
  layout false

  #GET rollcall/status
  def index
    @school_districts = Rollcall::Status.get_school_districts
    @schools = Rollcall::Status.get_schools
    
    respond_with(@school_districts, @schools)
  end
end