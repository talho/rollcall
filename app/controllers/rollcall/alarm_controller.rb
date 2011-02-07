class Rollcall::AlarmController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required

  def index
    alarms  = []
    queries = []
    unless params[:query_id].blank?
      queries.push(Rollcall::SavedQuery.find(params[:query_id]))
    else
      queries = current_user.saved_queries
    end
    queries.each do |query|
      if query.alarm_set
        result = Rollcall::Alarm.find_all_by_saved_query_id(query.id).each do |alarm|
          alarm[:school_name] = alarm.school.display_name
          alarm[:alarm_name]  = alarm.saved_query.name
        end
        alarms.push(result)
      end
    end
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => alarms.length,
          :results       => {
            :id     => 1,
            :alarms => alarms
          }.as_json
        }
      end
    end
  end

  def create
    query  = Rollcall::SavedQuery.find(params[:saved_query_id])
    result = Rollcall::Alarm.generate_alarm query
    respond_to do |format|
      format.json do
        render :json => {
          :success => result
        }
      end
    end
  end
  
end