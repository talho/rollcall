class SchoolsController < ApplicationController
  load_and_authorize_resource :school_district
  load_and_authorize_resource :through => :school_district
  respond_to :html

  def show
    respond_with @school
  end

  def new
    respond_with @school
  end

  def create
    if @school.save
      SchoolUser.create school_id: @school.id, user_id: current_user.id, role: :admin
    end

    respond_with @school, location: @school.errors.blank? ? school_district_path(@school.school_district) : new_school_district_school_path(@school.school_district)
  end

  def edit
    respond_with @school
  end

  def update
    @school.update school_params
    respond_with @school, location: @school.errors.blank? ? school_district_path(@school.school_district) : edit_school_district_school_path(@school.school_district, @school)
  end

  def destroy
    @school.destroy
    respond_with @school.school_district
  end

  protected
  def school_params
    params.require(:school).permit(:name, :school_type, :tea_id, :postal_code, :gmap_addr, :gmap_lat, :gmap_lng)
  end
end
