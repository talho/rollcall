class Rollcall::RollcallAppController < ApplicationController
  before_filter :rollcall_required
  
  def rollcall_required  
    if current_user.role_memberships.detect{|rm| rm.role.application == Role.find_by_application('rollcall').application}
      return true
    else
      redirect_to :action => "unauthorized", :controller => 'rollcall/rollcall_app'
      return false
    end
  end

  def rollcall_nurse_required
    if current_user.role_memberships.detect{|rm| rm.role == Role.find_by_name_and_application('Nurse', 'rollcall')} ||
      is_rollcall_admin? || rollcall_student_required
      return true
    else
      redirect_to :action => "unauthorized", :controller => 'rollcall/rollcall_app'
      return false
    end
  end

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

  def is_rollcall_admin?
    if current_user.role_memberships.detect{ |rm| rm.role == Role.find_by_name_and_application('Admin', 'rollcall')}
      return true
    end
    return false
  end
  
  def unauthorized
    render :json => "You are not authorized for access.", :status => :unauthorized
  end
end
