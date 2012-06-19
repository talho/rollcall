# The Alarm Query controller class for the Rollcall application.  This controller class handles
# the index(read), create, update, and destroy methods for the AlarmQuery object.
#
# Author::    Eddie Gomez  (mailto:eddie@talho.org)
# Copyright:: Copyright (c) 2011 TALHO
#
# The actions held in this controller are primarily called by the Rollcall AlarmQueriesPanel.

class Rollcall::AlarmQueryController < Rollcall::RollcallAppController
  before_filter :rollcall_isd_required
  respond_to :json
  layout false
  
  # GET rollcall/alarm_query
  def index
    alarm_queries = current_user.alarm_queries(params)
    @alarm_queries = alarm_queries
    respond_with(@alarm_queries)
  end

  # POST rollcall/alarm_query
  def create
    alarm_exist_by_name = Rollcall::AlarmQuery.find_by_name(params[:alarm_query_name])
    fs                  = ActiveSupport::JSON.decode(params[:alarm_query_params])    
    alarm_name          = alarm_exist_by_name.blank? ? params[:alarm_query_name] : "#{alarm_exist_by_name.name}_1"
    saved_result        = Rollcall::AlarmQuery.create(
      :name          => alarm_name,
      :user_id       => current_user.id,
      :query_params  => (fs.is_a? String) ? fs : params[:alarm_query_params],
      :severity_min  => params[:severity_min],
      :severity_max  => params[:severity_max],
      :deviation_min => params[:deviation_min],
      :deviation_max => params[:deviation_max],
      :alarm_set     => false
    )
    @success = !saved_result.blank?
    respond_with(@success)
  end

  # PUT rollcall/alarm_query/:id
  def update
    query     = Rollcall::AlarmQuery.find(params[:id])
    alarm_set = params[:alarm_set].blank? ? query.alarm_set : params[:alarm_set]
    unless params[:alarm_set].blank?
      success = query.update_attributes :alarm_set => alarm_set
    else
      # Update the query params
      updated_alarm_query_params           = ActiveSupport::JSON.decode(params[:alarm_query_params])
      updated_alarm_query_params["school"] = params[:school]
      success                              = query.update_attributes(
        :name          => params[:alarm_query_name],
        :query_params  => ActiveSupport::JSON.encode(updated_alarm_query_params),
        :severity_min  => params[:severity_min],
        :severity_max  => params[:severity_max],
        :deviation_min => params[:deviation_min],
        :deviation_max => params[:deviation_max],
        :alarm_set     => alarm_set)
    end   
    query.save if success
    @success = success
    respond_with(@success)
  end

  # DELETE rollcall/alarm_query/:id
  def destroy
    alarm_query = Rollcall::AlarmQuery.find(params[:id])
    @success = alarm_query.destroy
    respond_with(@success)
  end
end
