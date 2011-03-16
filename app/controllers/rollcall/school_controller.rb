class Rollcall::SchoolController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required

  def index
    original_included_root = ActiveRecord::Base.include_root_in_json
    ActiveRecord::Base.include_root_in_json = false
    results = Rollcall::School.search(params)
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results.length,
          :results       => results.as_json
        }
      end
    end
    ActiveRecord::Base.include_root_in_json = original_included_root
  end

  def get_schools_for_combobox
    original_included_root = ActiveRecord::Base.include_root_in_json
    ActiveRecord::Base.include_root_in_json = false
    results = Rollcall::School.find(:all, :select => "id,display_name")
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results.length,
          :results       => results.as_json
        }
      end
    end
    ActiveRecord::Base.include_root_in_json = original_included_root
  end

  def show
    results = Rollcall::School.find_by_id(params[:school_id])
    respond_to do |format|
      format.json do
        render :json => {
          :success => true,
          :results => results.as_json
        }
      end
    end
  end

  def get_schools
    schools = []
    params[:school_ids].split(",").each do |id|
      schools.push(Rollcall::School.find_by_id(id))
    end
    respond_to do |format|
      format.json do
        render :json => {
          :success => true,
          :results => schools.as_json
        }
      end
    end
  end

  def get_school_data
    school             = Rollcall::School.find_by_tea_id(params[:tea_id])
    time_span          = params[:time_span].to_i * 10
    school_daily_info  = school.school_daily_infos.find(:all, :conditions => ["report_date >= ?", Time.now - time_span.days])


    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :success => true,
          :results => {
            :school_daily_infos  => school_daily_info
          }
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

  def get_student_data
    school             = Rollcall::School.find_by_tea_id(params[:tea_id])
    time_span          = params[:time_span].to_i * 10
    student_daily_info = school.student_daily_infos.find(:all,:conditions => ["report_date >= ?", Time.now - time_span.days])

    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :success => true,
          :results => {
            :student_daily_infos => student_daily_info
          }
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end
end