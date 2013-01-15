# The Alarm controller class for the Rollcall application.  This controller class handles
# the index(read), create, update, and destroy methods for the Alarm object. Controller also
# handles the get_info which return related data for an alarm.
#
# Author::    Eddie Gomez  (mailto:eddie@talho.org)
# Copyright:: Copyright (c) 2011 TALHO
#
# The actions held in this controller are primarily called by the Rollcall AlarmsPanel.

class Rollcall::AlarmController < Rollcall::RollcallAppController
  before_filter :rollcall_isd_required
  respond_to :json
  layout false
  
  # GET rollcall/alarms
  def index    
    if params[:alarm_query_id].present?
      @alarms = Rollcall::Alarm.where(:alarm_query_id => params[:alarm_query_id])
    else
      @alarms = Rollcall::Alarm.joins(:alarm_query).where("rollcall_alarm_queries.user_id = ?", current_user.id)
    end    
       
    respond_with(@alarms)
  end

  # POST rollcall/alarms
  def create    
    Rollcall::AlarmQuery.find(params[:alarm_query_id]).generate_alarms
  end

  # PUT rollcall/alarms/:id
  def update
    alarm     = Rollcall::Alarm.find(params[:id])
    ignore    = params[:alarms][:ignore_alarm].blank? ? false : params[:alarms][:ignore_alarm]
    success   = alarm.update_attributes :ignore_alarm => ignore
    alarm.save if success
    @success = success
    respond_with(@success)
  end

  # DELETE rollcall/alarms/:id
  def destroy
    result = false
    unless params[:alarm_query_id].blank?
      Rollcall::Alarm.find(:all, :conditions => ['alarm_query_id = ?', params[:alarm_query_id]]).each { |a| result = a.destroy }
    else
      result = Rollcall::Alarm.find(params[:id]).destroy
    end
    @result = result
    respond_with(@result)
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
    @school_info = school_info
    @severity = alarm.alarm_severity
    @confirmed_absents = confirmed_absents
    @student_info = student_info
    respond_with(@school_info, @severity, @confirmed_absents, @student_info)
  end
  
  # GET rollcall/get_gis
  def get_gis
    @alarms = Rollcall::Alarm.joins("inner join (select max(report_date), school_id from rollcall_alarms group by school_id) as max_date on max_date.max = report_date and max_date.school_id = rollcall_alarms.school_id")
      .joins("inner join rollcall_alarm_queries on rollcall_alarm_queries.id = rollcall_alarms.alarm_query_id")
      .joins("inner join rollcall_schools on rollcall_schools.id = rollcall_alarms.school_id")
      .where("user_id = ?", current_user.id)
      .where("gmap_addr is not null")
      .where("gmap_lat is not null")
      .where("gmap_lng is not null")
      .select("rollcall_schools.display_name, absentee_rate, deviation, severity, gmap_addr, gmap_lat, gmap_lng")
    
    respond_with(@alarms)
  end
end
