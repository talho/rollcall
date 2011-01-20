class Rollcall::AlarmController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required

  def index
    alarms = []
    current_user.saved_queries.each do |query|
      result = Rollcall::Alarm.find_all_by_saved_query_id(query.id).each do |query|
        query[:school_name] = query.school.display_name
      end
      alarms.push(result)
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

end