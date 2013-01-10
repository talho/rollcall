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
    respond_with(@alarm_queries = current_user.alarm_queries.order(:name))
  end

  # POST rollcall/alarm_query
  def create
    alarm_count = Rollcall::AlarmQuery.where("user_id = ? AND name LIKE ?", current_user.id, "#{params[:alarm_query][:name]}%").count  
    params[:alarm_query][:name] = "#{params[:alarm_query][:name]}_#{alarm_count}" if alarm_count > 0
    alarm_query = Rollcall::AlarmQuery.new(params[:alarm_query])
    alarm_query.attributes = {:user_id => current_user.id, :alarm_set => false}
    
    respond_with(@success = alarm_query.save)
  end

  def edit
    respond_with(@alarm_query = current_user.alarm_queries.find(params[:id]))
  end

  # PUT rollcall/alarm_query/:id
  def update
    query = Rollcall::AlarmQuery.find(params[:id])
    respond_with(@success = query.update_attributes(params[:alarm_query]))
  end

  # DELETE rollcall/alarm_query/:id
  def destroy
    alarm_query = Rollcall::AlarmQuery.find(params[:id])
    @success = alarm_query.destroy
    respond_with(@success)
  end
  
  # GET rollcall/alarm_query/:id
  def show
    @alarm_query = Rollcall::AlarmQuery.find(params[:id])
    respond_with(@alarm_query)
  end
  
  # POST rollcall/alarm_query/toggle/:id
  def toggle
    alarm_query = Rollcall::AlarmQuery.find(params[:id])
    
    alarm_query.alarm_set = alarm_query.alarm_set;
    alarm_query.save
    
    if self.alarm_set      
      Rollcall::Alarm.destroy_by_alarm_query_id(alarm_query.id)
      alarm_query.generate_alarms
    end        
  end
end
