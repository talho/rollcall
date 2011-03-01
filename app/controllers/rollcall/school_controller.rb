class Rollcall::SchoolController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required

  def index
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