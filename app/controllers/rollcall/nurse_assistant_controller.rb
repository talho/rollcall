# The Nurse Assistant controller class for the Rollcall application.  This controller class handles
# the index(read) and destroy methods for the StudentDailyInfo object.
#
# Author::    Eddie Gomez  (mailto:eddie@talho.org)
# Copyright:: Copyright (c) 2011 TALHO
#
# The actions held in this controller are primarily called by the Rollcall NurseAssistant ExtJS panel.

class Rollcall::NurseAssistantController < Rollcall::RollcallAppController
  before_filter :rollcall_student_required
  respond_to :json
  layout false
  
  # Method returns a set of student records and associated values. Method can be called with :search_term param
  # which will search against the student db object attributes.  Method can also be called with
  # a :filter_report_date param which will return a student set for a specific date.
  #
  # GET rollcall/nurse_assistant
  def index
    options = {:page => (params[:start].to_i / (params[:limit] || 25).to_i) + 1, :per_page => (params[:limit] || 25).to_i}
    
    if !params[:search_term].blank?
      st = "%" + CGI::unescape(params[:search_term]) + "%"
      student_records = Rollcall::StudentDailyInfo
        .joins(:student).includes(:symptoms)
        .where("student_number LIKE ? OR first_name LIKE ? OR last_name LIKE ? AND school_id = ?", st, st, st, params[:school_id])
    else
      student_records = Rollcall::StudentDailyInfo
        .joins(:student).includes(:symptoms)
        .where("school_id = ?", params[:school_id])
                
      unless params[:filter_report_date].blank?
        student_records = student_records
          .where("report_date >= ?", Time.parse(params[:filter_report_date]).beginning_of_month)
          .where("report_date <= ?", Time.parse(params[:filter_report_date]).end_of_month)
      end
    end
    respond_with(@student_infos = student_records.paginate(options))
  end

  # Method is responsible for destroying a StudentDailyInfo record.  Method is called from the
  # NurseAssistant ExtJS panel and is meant to delete a student visit to the nurse.
  #
  # DELETE rollcall/nurse_assistant/:id
  def destroy
    respond_with(@result = Rollcall::StudentDailyInfo.find(params[:id]).destroy)
  end

  # Method returns a set of option values that are used to built the drop down boxes for the
  # NurseAssisant ExtJs panel.  Method also determines if the Nurse Assistant app is being run for the
  # first time and sends back a flag to the client, app_init, that client uses to prompt the user to select
  # their current school.
  #
  # GET rollcall/nurse_assistant_options
  def get_options    
    zipcodes = current_user.school_districts.all.map{ |sd| sd.zipcodes }.flatten
    schools = current_user.schools.all
    default_options = get_default_options({:schools => schools, :nurse => true})
    student_daily_info = Rollcall::StudentDailyInfo
      .includes(:student)
      .where("student_id >= 1")
      .where("rollcall_students.school_id IN (?)", current_user.school_districts.all.first.schools.pluck(:id))
      .order("rollcall_student_daily_infos.created_at DESC")
      .limit(1)
    if student_daily_info.present?
      school_id = student_daily_info.first.student.school_id
      app_init = false
      total_enrolled_alpha = Rollcall::SchoolDailyInfo.find_all_by_school_id(school_id).blank?
    else     
      school_id = current_user.school_districts.all.map(&:schools).flatten.first[:id]
      app_init = true
      total_enrolled_alpha = true
    end
    @options = { 
      :default_options => default_options, 
      :zipcodes => zipcodes.map{ |z| {:value => z, :id => z}}, 
      :total_enrolled_alpha => total_enrolled_alpha,
      :app_init => app_init,
      :school_id => school_id,
      :schools => schools
    }
    respond_with(@options)
  end
end