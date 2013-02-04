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
    @alarms = Rollcall::Alarm
        .joins(:alarm_query)
        .joins(:school)
        
    if params[:alarm_query_id].present? 
      @alarms = @alarms
        .where(:alarm_query_id => params[:alarm_query_id])
    else
      @alarms = @alarms
        .where("rollcall_alarm_queries.user_id = ?", current_user.id)    
    end
    
    @alarms = @alarms
      .select('rollcall_schools.display_name, report_date, rollcall_alarms.id')
      .order('report_date, display_name')
    
    options = {:page => (params[:start] ? (params[:start].to_f / 15).floor + 1 : 1), :per_page => params[:limit] || 15}
    @total = @alarms.count()
    @alarms = @alarms.paginate(options)
    
    respond_with(@alarms, @total)
  end
  
  #GET rollcall/alarm/:id
  def show
    @alarm = Rollcall::Alarm
      .joins(:school)
      .select('display_name, school_id, rollcall_alarms.id, deviation, severity, ignore_alarm, report_date, gmap_lat, gmap_lng, gmap_addr, absentee_rate, alarm_query_id')
      .where(:id => params[:id])
      .first
      
    @alarm['school_info'] = Rollcall::SchoolDailyInfo
      .where(:school_id => @alarm.school_id)
      .where("report_date between ? and ?", @alarm.report_date - 7.days, @alarm.report_date)
      
    @alarm['symptom_info'] = Rollcall::Symptom
      .joins("inner join rollcall_student_reported_symptoms s on rollcall_symptoms.id = s.symptom_id")
      .joins("inner join rollcall_student_daily_infos i on s.student_daily_info_id = i.id")
      .joins("inner join rollcall_students ss on ss.id = i.student_id")
      .where("ss.school_id = ?", @alarm.school_id)
      .where("i.report_date between ? and ?", @alarm.report_date - 7.days, @alarm.report_date)
      .select("name")
      .uniq
      
    reasons = []
    aq = Rollcall::AlarmQuery.find(@alarm.alarm_query_id)
    reasons.push("Severity (#{@alarm.severity}) met or exceeded the threshold of #{aq.severity}") if (aq.severity <= @alarm.severity && aq.severity != 0)
    reasons.push("Deviation (#{@alarm.deviation}) met or exceeded the threshold of #{aq.deviation}") if (aq.deviation <= @alarm.deviation && aq.deviation !=0)
    @alarm['reason'] = reasons.count == 0 ? "None" : reasons.join(" and ")
          
    @alarm = [@alarm]
    
    respond_with(@alarm)
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
      .select("rollcall_schools.display_name, absentee_rate, rollcall_alarms.deviation, rollcall_alarms.severity, gmap_addr, gmap_lat, gmap_lng")
    
    respond_with(@alarms)
  end
end
