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
    unless params[:start].blank?
      per_page = params[:limit].to_i
      if params[:start].to_i == 0
        page = 1
      else
        page = (params[:start].to_i / per_page) + 1
      end
      options = {:page => page, :per_page => per_page}
    else
      options = {}
    end 
    if !params[:search_term].blank?
      st = "%" + CGI::unescape(params[:search_term]) + "%"      
      student_ids = Rollcall::Student.where("student_number LIKE ? OR first_name LIKE ? OR last_name LIKE ? AND school_id = ?", st, st, st, params[:school_id]).pluck(:id)      
      if student_ids.present?
        student_records = Rollcall::StudentDailyInfo.where("student_id IN (?)", student_ids).all
      else
        student_records = []
      end
    elsif !params[:filter_report_date].blank?
      students = Rollcall::Student.where("school_id = ?", params[:school_id]).pluck(:id)
      student_records = Rollcall::StudentDailyInfo
        .where("student_id in (?)", students)
        .includes(:student)
        .where("student_id = rollcall_students.id")
        .where("report_date >= ?", Time.parse(params[:filter_report_date]).beginning_of_month)
        .where("report_date <= ?", Time.parse(params[:filter_report_date]).end_of_month)
        .all
    else
      students = Rollcall::Student.where("school_id = ?", params[:school_id]).pluck(:id)
      student_records = Rollcall::StudentDailyInfo
        .where("student_id in (?)", students)
        .includes(:student)
        .where("student_id = rollcall_students.id")
        .all
    end
    require 'will_paginate/array'
    students_paged = student_records.paginate(options)
    students_paged.each do |record|
      symptom_array  = []
      student_obj    = record.student
      record.symptoms.each do |symptom|
        symptom_array.push(symptom.name)
      end
      record[:symptom]            = symptom_array.join(",")
      record[:first_name]         = student_obj.first_name.blank? ? "Unknown" : student_obj.first_name
      record[:last_name]          = student_obj.last_name.blank? ? "Unknown" : student_obj.last_name
      record[:contact_first_name] = student_obj.contact_first_name.blank? ? "Unknown" : student_obj.contact_first_name
      record[:contact_last_name]  = student_obj.contact_last_name.blank? ? "Unknown" : student_obj.contact_last_name
      record[:address]            = student_obj.address.blank? ? "Unknown" : student_obj.address
      record[:zip]                = student_obj.zip.blank? ? "Unknown" : student_obj.zip
      record[:dob]                = student_obj.dob.blank? ? "Unknown" : student_obj.dob
      record[:student_number]     = student_obj.student_number.blank? ? "Unknown" : student_obj.student_number
      record[:phone]              = student_obj.phone.blank? ? "Unknown" : student_obj.phone
      record[:gender]             = student_obj.gender.blank? ? "Unknown" : student_obj.gender
      record[:student_id]         = student_obj.id
      record[:race]               = student_obj.race
    end
    @length = student_records.length
    @students_paged = students_paged
    respond_with(@length, @students_paged)
  end

  # Method is responsible for destroying a StudentDailyInfo record.  Method is called from the
  # NurseAssistant ExtJS panel and is meant to delete a student visit to the nurse.
  #
  # DELETE rollcall/nurse_assistant/:id
  def destroy
    result = false
    result = Rollcall::StudentDailyInfo.find(params[:id]).destroy
    @result = result
    respond_with(@result)
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