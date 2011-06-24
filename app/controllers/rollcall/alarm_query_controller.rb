# The Alarm Query controller class for the Rollcall application.  This controller class handles
# the index(read), create, update, and destroy methods for the AlarmQuery object.
#
# Author::    Eddie Gomez  (mailto:eddie@talho.org)
# Copyright:: Copyright (c) 2011 TALHO
#
# The actions held in this controller are primarily called by the Rollcall AlarmQueriesPanel.

class Rollcall::AlarmQueryController < Rollcall::RollcallAppController

  # GET rollcall/alarm_query
  def index
    alarm_queries = current_user.alarm_queries(params)
    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :success       => true,
          :total_results => alarm_queries.length,
          :results       => alarm_queries
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

  # POST rollcall/alarm_query
  def create
    alarm_exist_by_name = Rollcall::AlarmQuery.find_by_name(params[:alarm_query_name])
    alarm_name          = alarm_exist_by_name.blank? ? params[:alarm_query_name] : "#{alarm_exist_by_name.name}_1"
    saved_result        = Rollcall::AlarmQuery.create(
      :name                => alarm_name,
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

  # PUT rollcall/alarm_query/:id
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

  # DELETE rollcall/alarm_query/:id
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
