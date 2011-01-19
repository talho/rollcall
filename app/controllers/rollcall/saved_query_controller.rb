class Rollcall::SavedQueryController < Rollcall::RollcallAppController
  def index
    unless params[:r_id].blank?
      saved_queries = Rollcall::SavedQuery.find_all_by_user_id_and_rrd_id(current_user.id, params[:r_id])
    else
      saved_queries = Rollcall::SavedQuery.find_all_by_user_id(current_user.id)
    end
    saved_query_graphs = Rollcall::Rrd.render_saved_graphs saved_queries   
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => saved_query_graphs[:image_urls].length,
          :results       => {
            :id            => 1,
            :saved_queries => saved_queries,
            :img_urls      => saved_query_graphs,
          }.as_json
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
      :deviation_max       => params['deviation_max'],
      :rrd_id              => params['r_id']
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
    #success = query.update_attributes(params)
    success = query.update_attributes(
      :name                => params['query_name'],
      :query_params        => params['query_params'],
      :severity_min        => params['severity_min'],
      :severity_max        => params['severity_max'],
      :deviation_threshold => params['deviation_threshold'],
      :deviation_min       => params['deviation_min'],
      :deviation_max       => params['deviation_max'],
      :rrd_id              => params['r_id'])
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