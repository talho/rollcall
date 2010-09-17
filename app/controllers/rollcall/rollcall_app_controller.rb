class Rollcall::RollcallAppController < ApplicationController
  def rollcall_required
    unless current_user.role_memberships.detect{ |rm| rm.role == Role.find_by_name('Rollcall')}
      flash[:error] = "You have not been given access to the Rollcall application.  Email your OpenPHIN administrator for help."
      redirect_to :action => "about", :controller => 'rollcall/rollcall', :format => "ext"
      false
    end
  end
end
