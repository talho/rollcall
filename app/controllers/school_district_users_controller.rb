class SchoolDistrictUsersController < ApplicationController
  load_and_authorize_resource :school_district
  load_and_authorize_resource :through => :school_district
  respond_to :html

  def new
    respond_with @school_district_user
  end

  def create
    if @school_district_user.save
      # send email
    end

    loc = @school_district_user.errors.blank? ? school_district_path(@school_district_user.school_district) : new_school_district_school_district_user_path(@school_district_user.school_district)
    respond_with @school_district_user, location: loc
  end

  def destroy
    @school_district_user.destroy
    respond_with @school_district_user.school_district
  end

  protected
  def school_district_user_params
    params.require(:school_district_user).permit(:email, :role)
  end
end
