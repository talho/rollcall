class SchoolUsersController < ApplicationController
  load_and_authorize_resource :school_district
  load_and_authorize_resource :school, :through => :school_district
  load_and_authorize_resource :through => :school
  respond_to :html

  def new
    respond_with @school_user
  end

  def create
    if @school_user.save
      # send email
    end

    loc = @school_user.errors.blank? ? school_district_school_path(@school_user.school.school_district_id, @school_user.school) : new_school_district_school_school_user_path(@school_user.school)
    respond_with @school_user, location: loc
  end

  def destroy
    @school_user.destroy
    respond_with @school_user.school.school_district, @school_user.school
  end

  protected
  def school_user_params
    params.require(:school_user).permit(:email, :role)
  end
end
