# The Alarm controller class for the Rollcall application.  This controller class handles
# the index(read), create, update, and destroy methods for the Alarm object. Controller also
# handles the get_info which return related data for an alarm.
#
# Author::    Eddie Gomez  (mailto:eddie@talho.org)
# Copyright:: Copyright (c) 2011 TALHO
#
# The actions held in this controller are primarily called by the Rollcall AlarmsPanel.

class Rollcall::AlarmController < Rollcall::RollcallAppController

  # GET rollcall/alarms
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

  # POST rollcall/alarms
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

  # PUT rollcall/alarms/:id
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

  # DELETE rollcall/alarms/:alarm_query_id
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

  # GET rollcall/get_info
  def get_info
    alarm             = Rollcall::Alarm.find(params[:alarm_id])
    school_info       = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date params[:school_id],params[:report_date]
    students          = Rollcall::Student.find_all_by_school_id params[:school_id]
    confirmed_absents = Rollcall::StudentDailyInfo.find_all_by_student_id_and_report_date_and_confirmed_illness(
      students,params[:report_date],true).size
    student_info      = Rollcall::StudentDailyInfo.find_all_by_student_id_and_report_date(students,params[:report_date])
    student_info.each{|info|
      if info.student.dob.blank?
        info[:dob] = "Unknown"
        info[:age] = "Unknown"
      else
        info[:dob] = info.student.dob
        info[:age] = Time.now.year - info[:dob].year
      end
      info[:gender] = info.student.gender.blank? ? "Unknown" : info.student.gender
    }
    if school_info.blank?
      school_info              = Rollcall::SchoolDailyInfo.find_by_school_id params[:school_id]
      school_info.total_absent = Rollcall::StudentDailyInfo.find_all_by_student_id_and_report_date(students,params[:report_date]).size
    end
    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :info => [
            {
              :total_absent           => school_info.total_absent,
              :total_enrolled         => school_info.total_enrolled,
              :total_confirmed_absent => confirmed_absents,
              :alarm_severity         => alarm.alarm_severity,
              :school_name            => school_info.school.display_name,
              :school_type            => school_info.school.school_type,
              :students               => {:student_info => student_info.as_json}
            }
          ]
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end
end
