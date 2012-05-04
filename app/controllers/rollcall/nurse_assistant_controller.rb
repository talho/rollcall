# The Nurse Assistant controller class for the Rollcall application.  This controller class handles
# the index(read) and destroy methods for the StudentDailyInfo object.
#
# Author::    Eddie Gomez  (mailto:eddie@talho.org)
# Copyright:: Copyright (c) 2011 TALHO
#
# The actions held in this controller are primarily called by the Rollcall NurseAssistant ExtJS panel.

class Rollcall::NurseAssistantController < Rollcall::RollcallAppController
  before_filter :rollcall_student_required
  
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
      st          = "%" + CGI::unescape(params[:search_term]) + "%"
      student_ids = []
      students    = Rollcall::Student.find(
        :all,
        :conditions => ["student_number LIKE ? OR first_name LIKE ? OR last_name LIKE ? AND school_id = ?", st, st, st, params[:school_id]])
      students.collect{|rec| student_ids.push(rec.id) }
      unless student_ids.blank?
        student_records = Rollcall::StudentDailyInfo.find_by_sql("SELECT * FROM rollcall_student_daily_infos WHERE student_id IN (#{student_ids.join(",")})")
      else
        student_records = []
      end
    elsif !params[:filter_report_date].blank?
      students        = Rollcall::Student.find_all_by_school_id params[:school_id]
      student_records = Rollcall::StudentDailyInfo.find_all_by_student_id(
        students,
        :include    => :student,
        :conditions => ["student_id = rollcall_students.id AND report_date >= ? AND report_date <= ?",
                        Time.parse(params[:filter_report_date]).beginning_of_month,
                        Time.parse(params[:filter_report_date]).end_of_month]
      )
    else
      students        = Rollcall::Student.find_all_by_school_id params[:school_id]
      student_records = Rollcall::StudentDailyInfo.find_all_by_student_id(
        students,
        :include    => :student,
        :conditions => ["student_id = rollcall_students.id"]
      )
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
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => student_records.length,
          :results       => students_paged
        }
      end
    end
  end

  # Method is responsible for destroying a StudentDailyInfo record.  Method is called from the
  # NurseAssistant ExtJS panel and is meant to delete a student visit to the nurse.
  #
  # DELETE rollcall/nurse_assistant/:id
  def destroy
    result = false
    result = Rollcall::StudentDailyInfo.find(params[:id]).destroy
    respond_to do |format|
      format.json do
        render :json => {
          :success => result
        }
      end
    end
  end

  # Method returns a set of option values that are used to built the drop down boxes for the
  # NurseAssisant ExtJs panel.  Method also determines if the Nurse Assistant app is being run for the
  # first time and sends back a flag to the client, app_init, that client uses to prompt the user to select
  # their current school.
  #
  # GET rollcall/nurse_assistant_options
  def get_options
    zipcodes             = current_user.school_districts.map{|s| s.zipcodes.map{|i| {:id => i, :value => i}}}.flatten
    schools              = current_user.schools
    default_options      = get_default_options({:schools => schools, :nurse => true})
    student_daily_info   = Rollcall::StudentDailyInfo.find(:all, :include => :student,
      :conditions => ["student_id >= ? AND rollcall_students.school_id IN (?)", 1, current_user.school_districts.first.schools],
      :order      => "rollcall_student_daily_infos.created_at DESC", :limit => 1)
    unless student_daily_info.blank?
      school_id            = student_daily_info.first.student.school_id
      app_init             = false
      total_enrolled_alpha = Rollcall::SchoolDailyInfo.find_all_by_school_id(school_id).blank?
    else     
      school_id            = current_user.school_districts.map(&:schools).flatten.first[:id]
      app_init             = true
      total_enrolled_alpha = true
    end
    respond_to do |format|
      format.json do
        render :json => {
          :options => [{
            :race                 => default_options[:race],
            :age                  => default_options[:age],
            :gender               => default_options[:gender],
            :grade                => default_options[:grade],
            :symptoms             => default_options[:symptoms],
            :zip                  => zipcodes,
            :total_enrolled_alpha => total_enrolled_alpha,
            :app_init             => app_init,
            :school_id            => school_id,
            :school_name          => Rollcall::School.find_by_id(school_id).display_name,
            :schools              => schools
          }]
        }
      end
    end
  end
end