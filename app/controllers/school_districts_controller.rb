class SchoolDistrictsController < ApplicationController
  load_and_authorize_resource
  respond_to :html

  def index
    @school_districts = current_user.school_districts
    respond_with @school_districts
  end

  def show
    respond_with @school_district
  end

  def new
    respond_with @school_district
  end

  def create
    if @school_district.save
      SchoolDistrictUser.create school_district_id: @school_district.id, user_id: current_user.id, role: :admin
    end

    respond_with @school_district
  end

  def edit
    respond_with @school_district
  end

  def update
    @school_district.update school_district_params
    respond_with @school_district
  end

  def destroy
    @school_district.destroy
    redirect_to school_districts_path
  end

  protected
  def school_district_params
    params.require(:school_district).permit(:name, :city, :county, :state, :state_id)
  end
end
