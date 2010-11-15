class Rollcall::SchoolsController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required
  before_filter :set_toolbar, :except => :chart

  def index
    if current_user.schools.empty?
      flash[:notice] = "You do not have access to Rollcall, or do not have any schools in your jurisdiction(s)."
      redirect_to :action => "about", :controller => 'rollcall/rollcall', :format => "ext"
    else
      id = current_user.schools.first.id
      respond_to do |format|
        format.ext { redirect_to :action => "show", :id => id, :format => "ext" }
        format.html { redirect_to :action => "show", :id => id, :format => "html" }
      end
    end
  end

  def get
    schools = current_user.schools(:order => "display_name")
    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :schools => schools.as_json
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

  def show
    schools = current_user.schools(:order => "display_name")
    
    @school = School.find(params[:id])

    if @school
      @district = @school.district
    end

    respond_to do |format|
      if @school && schools.include?(@school)
        @chart=open_flash_chart_object(600, 300, rollcall_school_chart_path(@school, params[:timespan]))
        format.ext
        format.html
        format.xml { render :xml => @school }
      else
        flash[:error] = "You do not have any schools or school does not exist"
        format.ext
        format.html
        format.xml { render :xml => "", :status => :unprocessable_entity }
      end
    end
  end

  def chart
    @school = School.find(params[:rollcall_school_id])
    render :text => create_school_chart(@school, params[:timespan])
  end

  protected
  def set_toolbar
    toolbar = current_user.roles.include?(Role.find_by_name('Rollcall')) ? "rollcall" : "application"
    Rollcall::SchoolsController.app_toolbar toolbar
  end

  private
  include RollcallHelper
end
