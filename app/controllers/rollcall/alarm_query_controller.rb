class Rollcall::AlarmQueryController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required

  def index
    alarm_queries = current_user.alarm_queries(params)
    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :success       => true,
          :total_results => alarm_queries.length,
          :results       => {
            :id            => 1,
            :alarm_queries => alarm_queries,
          }.as_json
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

  def create
    saved_result = Rollcall::AlarmQuery.create(
      :name                => params[:alarm_query_name],
      :user_id             => current_user.id,
      :query_params        => params[:alarm_query_params],
      :severity_min        => params[:severity_min],
      :severity_max        => params[:severity_max],
      :deviation_min       => params[:deviation_min],
      :deviation_max       => params[:deviation_max],
      :alarm_set           => false
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
    query = Rollcall::AlarmQuery.find(params[:id])
    alarm_set = params[:alarm_set].blank? ? query.alarm_set : params[:alarm_set]
    unless params[:alarm_set].blank?
      success = query.update_attributes :alarm_set => alarm_set
    else
      # Update the query params
      updated_alarm_query_params = ActiveSupport::JSON.decode(params[:alarm_query_params])
      updated_alarm_query_params["school"] = params[:school]

      success = query.update_attributes(
        :name                => params[:alarm_query_name],
        :query_params        => ActiveSupport::JSON.encode(updated_alarm_query_params),
        :severity_min        => params[:severity_min],
        :severity_max        => params[:severity_max],
        :deviation_min       => params[:deviation_min],
        :deviation_max       => params[:deviation_max],
        :alarm_set           => alarm_set)
    end   
    query.save if success
    respond_to do |format|
      format.json do
        render :json => {
          :success => success  
        }
      end
    end
  end

  def destroy
    alarm_query = Rollcall::AlarmQuery.find(params[:id])
    respond_to do |format|
      format.json do
        render :json => {
          :success => alarm_query.destroy
        }
      end
    end
  end

end
