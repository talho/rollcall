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
    if current_user.has_non_public_role?(:rollcall)
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

  # Method returns an object containing default options used to populate client-side list options.
  #
  # Method gathers up collections of options (race, grade, age, etc) based on collected data and static values
  def get_default_options(opt={})
    race = [
      {:id => 1, :value => "Native American/Alaskan"},
      {:id => 2, :value => "Asian"},
      {:id => 3, :value => "Black"},
      {:id => 4, :value => "Hispanic"},
      {:id => 5, :value => "White"},
      {:id => 6, :value => "Other"}
    ]
    if opt[:simple]
      return {:race => race}
    else
      absenteeism = [
        {:id => 0, :value => 'Gross'},
        {:id => 1, :value => 'Confirmed Illness'}
      ]
      age = [
        {:id => 1, :value => '0'},
        {:id => 2, :value => '1'},
        {:id => 3, :value => '2'},
        {:id => 4, :value => '3'},
        {:id => 5, :value => '4'},
        {:id => 6, :value => '5'},
        {:id => 7, :value => '6'},
        {:id => 8, :value => '7'},
        {:id => 9, :value => '8'},
        {:id => 10, :value => '9'},
        {:id => 11, :value => '10'},
        {:id => 12, :value => '11'},
        {:id => 13, :value => '12'},
        {:id => 14, :value => '13'},
        {:id => 15, :value => '14'},
        {:id => 16, :value => '15'},
        {:id => 17, :value => '16'},
        {:id => 18, :value => '17'},
        {:id => 19, :value => '18'}
      ]
      grade =[]
      if opt[:nurse]
        grade.push(
          {:id => 1, :value => 'Kindergarten (Pre-K)'},
          {:id => 2, :value => '1st Grade'},
          {:id => 3, :value => '2nd Grade'},
          {:id => 4, :value => '3rd Grade'},
          {:id => 5, :value => '4th Grade'},
          {:id => 6, :value => '5th Grade'},
          {:id => 7, :value => '6th Grade'},
          {:id => 8, :value => '7th Grade'},
          {:id => 9, :value => '8th Grade'},
          {:id => 10,:value => '9th Grade'},
          {:id => 11,:value => '10th Grade'},
          {:id => 12,:value => '11th Grade'},
          {:id => 13,:value => '12th Grade'}
        )
      end
      symptoms = Rollcall::Symptom.all
      gender = [
        {:id => 0, :value => 'Select Gender...'},
        {:id => 1, :value => 'Male'},
        {:id => 2, :value => 'Female'}
      ]
      data_functions = [
        {:id => 0, :value => 'Raw'},
        {:id => 1, :value => 'Average'},
        {:id => 2, :value => 'Average 30 Day'},
        {:id => 3, :value => 'Average 60 Day'},
        {:id => 4, :value => 'Standard Deviation'},
        {:id => 5, :value => 'Cusum'}
      ]
      return {
        :absenteeism        => absenteeism,
        :age                => age,
        :gender             => gender,
        :symptoms           => symptoms,
        :data_functions     => data_functions,
        :race               => race,
        :grade              => grade
      }
    end
  end
end
