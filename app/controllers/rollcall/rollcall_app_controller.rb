class Rollcall::RollcallAppController < ApplicationController
  before_filter :rollcall_required

  # Method checks current user role memberships to detect if they have the Rollcall Application name attached to them
  #
  # Method checks against current_user.role_memberships.  If appropriate application is not found, method redirects to 
  # action unauthorized
  def rollcall_required  
    if current_user.is_rollcall_user?
      return true
    else
      redirect_to :action => "unauthorized", :controller => 'rollcall/rollcall_app'
      return false
    end
  end

  # Method checks current user role memberships to detect if they have the Epidemiologist role or the
  # Health Officer role name attached to them
  #
  # Method checks against current_user.role_memberships.  If appropriate role is not found, method redirects to
  # action unauthorized
  def rollcall_isd_required
    if current_user.is_rollcall_epi? || current_user.is_rollcall_health_officer? || current_user.is_rollcall_admin?
      return true
    else
      redirect_to :action => "unauthorized", :controller => 'rollcall/rollcall_app'
      return false
    end
  end

  # Method checks current user role memberships to detect if they have the Epidemiologist role or the
  # Health Officer or the Nurse role name attached to them
  #
  # Method checks against current_user.role_memberships.  If appropriate role is not found, method redirects to
  # action unauthorized
  def rollcall_student_required
    if current_user.is_rollcall_epi? || current_user.is_rollcall_health_officer? || current_user.is_rollcall_nurse? ||
      current_user.is_rollcall_admin?
      return true
    else
      redirect_to :action => "unauthorized", :controller => 'rollcall/rollcall_app'
      return false
    end
  end

  # Method checks current user for Admin role
  #
  # Method checks against current_user.is_rollcall_admin?  If appropriate role is not found, method redirects to
  # action unauthorized
  def rollcall_admin_required
    if current_user.is_rollcall_admin?
      return true
    else
      redirect_to :action => "unauthorized", :controller => 'rollcall/rollcall_app'
      return false
    end
  end

  # Method returns unauthorized (401) status to client
  #
  # Method returns 401 status to client along with JSON formatted message
  def unauthorized
    render :json => "You are not authorized for access.", :status => :unauthorized
  end
end
