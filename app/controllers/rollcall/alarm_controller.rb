class Rollcall::AlarmController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required

  def index
    alarms        = []
    alarm_queries = []
    unless params[:alarm_query_id].blank?
      alarm_queries.push(Rollcall::AlarmQuery.find(params[:alarm_query_id]))
    else
      alarm_queries = current_user.alarm_queries
    end
    alarm_queries.each do |query|
      if query.alarm_set
        result = Rollcall::Alarm.find_all_by_alarm_query_id(query.id).each do |alarm|
          alarm[:school_name] = alarm.school.display_name
          alarm[:school_lat]  = alarm.school.gmap_lat
          alarm[:school_lng]  = alarm.school.gmap_lng
          alarm[:school_addr] = alarm.school.gmap_addr
          alarm[:alarm_name]  = alarm.alarm_query.name
        end
        alarms.push(result)
      end
    end
    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :success       => true,
          :total_results => alarms.length,
          :alarms => alarms.flatten
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

  def create
    result  = Rollcall::AlarmQuery.find(params[:alarm_query_id]).generate_alarm
    respond_to do |format|
      format.json do
        render :json => {
          :success => result
        }
      end
    end
  end

  def update
    alarm     = Rollcall::Alarm.find(params[:id])
    ignore    = params[:alarms][:ignore_alarm].blank? ? false : params[:alarms][:ignore_alarm]
    success   = alarm.update_attributes :ignore_alarm => ignore
    alarm.save if success
    respond_to do |format|
      format.json do
        render :json => {
          :success => success
        }
      end
    end
  end

  def destroy
    result = false
    unless params[:alarm_query_id].blank?
      find(:all, :conditions => ['alarm_query_id = ?', params[:alarm_query_id]]).each { |a| result = a.destroy }
    else
      result = Rollcall::Alarm.find(params[:id]).destroy
    end
    respond_to do |format|
      format.json do
        render :json => {
          :success => result
        }
      end
    end
  end
end
