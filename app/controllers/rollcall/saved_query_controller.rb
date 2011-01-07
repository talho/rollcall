class Rollcall::SavedQueryController < Rollcall::RollcallAppController
  def index
    saved_queries      = Rollcall::SavedQuery.find_all_by_user_id(current_user.id).blank? ? "" : Rollcall::SavedQuery.find_all_by_user_id(current_user.id)
    saved_query_graphs = Rollcall::Rrd.render_saved_graphs saved_queries
    respond_to do |format|
      format.json do
        render :json => {
          :success => true,
          :results => [{
            :saved_queries => saved_queries.as_json
          },{
            :saved_graphs  => saved_query_graphs.as_json  
          }]
        }
      end
    end
  end

  def create
    saved_result = Rollcall::SavedQuery.create(
      :name                => params['query_name'],
      :user_id             => current_user.id,
      :query_params        => params['query_params'],
      :severity_min        => params['severity_min'],
      :severity_max        => params['severity_max'],
      :deviation_threshold => params['deviation_threshold'],
      :deviation_min       => params['deviation_min'],
      :deviation_max       => params['deviation_max']
    )
    respond_to do |format|
      format.json do
        render :json => {
          :success => !saved_result.blank?
        }
      end
    end
  end

  def update
    query   = Rollcall::SavedQuery.find(params[:id])
    success = query.update_attributes(params[:user])
    if success
      query.save
    end
    respond_to do |format|
      format.json do
        render :json => {
          :success => success  
        }
      end
    end
  end

  def delete
    query   = Rollcall::SavedQuery.find(params[:id])
    success = query.destroy
    respond_to do |format|
      format.json do
        render :json => {
          :success => success
        }
      end
    end
  end
end