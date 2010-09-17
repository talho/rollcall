class Rollcall::SchoolDistrictsController < Rollcall::RollcallAppController
  def school
    @district = current_user.school_districts.detect{|d| d.id.to_s==params[:id]}
    if @district.nil?
      flash[:notice] = "You do not have access to that school district."
      redirect_to rollcall_path
    else
      @school = @district.schools.find_by_id(params[:school][:id])
      respond_to do |format|
        format.ext { redirect_to "#{school_path(@school)}.ext" }
        format.html { redirect_to school_path(@school) }
      end
    end
  end
end
