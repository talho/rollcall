class Rollcall::RollcallAppController < ApplicationController
  before_filter :rollcall_required

  # Method checks current user role memberships to detect if they have the Rollcall Application name attached to them
  #
  # Method checks against current_user.role_memberships.  If appropriate application is not found, method redirects to 
  # action unauthorized
  def rollcall_required  
    if current_user.role_memberships.detect{|rm| rm.role.application == Role.find_by_application('rollcall').application}
      return true
    else
      redirect_to :action => "unauthorized", :controller => 'rollcall/rollcall_app'
      return false
    end
  end

  # Method checks current user role memberships to detect if they have the Nurse role name attached to them
  #
  # Method checks against current_user.role_memberships.  If appropriate role is not found, method redirects to
  # action unauthorized
  def rollcall_nurse_required
    if current_user.role_memberships.detect{|rm| rm.role == Role.find_by_name_and_application('Nurse', 'rollcall')} ||
      is_rollcall_admin? || rollcall_student_required
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
    if current_user.role_memberships.detect{|rm| rm.role == Role.find_by_name_and_application('Epidemiologist', 'rollcall')} ||
      current_user.role_memberships.detect{ |rm| rm.role == Role.find_by_name_and_application('Health Officer', 'rollcall')} ||
      is_rollcall_admin?
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
    if current_user.role_memberships.detect{|rm| rm.role == Role.find_by_name_and_application('Epidemiologist', 'rollcall')} ||
      current_user.role_memberships.detect{|rm| rm.role == Role.find_by_name_and_application('Health Officer', 'rollcall')} ||
      current_user.role_memberships.detect{|rm| rm.role == Role.find_by_name_and_application('Nurse', 'rollcall')} ||
      is_rollcall_admin?
      return true
    else
      redirect_to :action => "unauthorized", :controller => 'rollcall/rollcall_app'
      return false
    end
  end

  # Method checks current user role memberships to detect if they have the Admin role name attached to them
  #
  # Method checks against current_user.role_memberships.  If appropriate role is not found, method redirects to
  # action unauthorized
  def is_rollcall_admin?
    if current_user.role_memberships.detect{ |rm| rm.role == Role.find_by_name_and_application('Admin', 'rollcall')}
      return true
    end
    return false
  end

  # Method returns unauthorized (401) status to client
  #
  # Method returns 401 status to client along with JSON formatted message
  def unauthorized
    render :json => "You are not authorized for access.", :status => :unauthorized
  end
end
