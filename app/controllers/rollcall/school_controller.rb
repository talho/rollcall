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
  
end
