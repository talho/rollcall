# The ADST controller class for the Rollcall application.  This controller class handles
# the initial search request(index), the export request, the report request, and the
# get_options method (which returns the drop down values for the Rollcall ADST application).
#
# Author::    Eddie Gomez  (mailto:eddie@talho.org)
# Copyright:: Copyright (c) 2011 TALHO
#
# The actions held in this controller are called by the Rollcall ADST panel.

class Rollcall::AdstController < Rollcall::RollcallAppController
  before_filter :rollcall_isd_required
  respond_to :json
  layout false
  
  # Action is called by the ADSTResultPanel result_store on load.  Method processes
  # the search request, calling get_graph_data(), returns
  # the total result length and the paginated result set
  #
  # GET /rollcall/adst
  def index
    graph_info = Array.new
    options = {:page => params[:page] || 1, :per_page => params[:limit] || 6}    
        
    # if params[:return_individual_school].blank?
      # results = current_user.school_districts
      # if params[:school_district].present? || params[:school].present?
        # results = results.where("rollcall_school_districts.name in (?)", params[:school_district])
      # end     
      # results.all
    # else
      # results = current_user.school_search params
    # end
    
    #Think this is better than the above way to get school districts
    
    results = load_results params    
    
    @length = results.length    
    
    require 'will_paginate/array'    
    results_paged = results.paginate(options)    
    results_paged.each do |r|      
      #res = Rollcall::Data.get_graph_data(params, r)
      new_res = Rollcall::NewData.get_graph_data(params, r)     
      graph_info.push(new_res.flatten)      
    end
    
    @graph_info = graph_info    
    respond_with(@length, @graph_info)    
  end

  # Action is called by the ADST main panel method exportResultSet and the ADSTResultPanel method exportResult.
  # Method sets the export file name based on export params.  Method then calls a delayed job on
  # export_data(a delayed job) which is responsible for gathering the data, creating a csv file, and placing it
  # in the users documents folder and sending out message to users email when process is done.
  #
  # GET /rollcall/export
  def export
    filename = "rollcall_export.#{Time.now.strftime("%m-%d-%Y")}"
    results = load_results params
    Rollcall::NewData.delay.export_data(params, filename, current_user, results)    
  end

  # GET /rollcall/report
  def report
    begin
      recipe             = params[:recipe_id]
      report             = current_user.reports.create!(:recipe=>recipe,:criteria=>params,:incomplete=>true)
      unless Rails.env == 'development'
        Delayed::Job.enqueue( Reporters::Reporter.new(:report_id=>report[:id]) )
      else
        Reporters::Reporter.new(:report_id=>report[:id]).perform  # for development
      end      
      @reportId = report[:id]        
    rescue StandardError => error
      respond_to do |format|
        format.json {render :json => {:success => false, :msg => error.as_json}, :content_type => 'text/html', :status => 406}
      end
    end
  end

  # Action is called by the ADST main panel method initFormComponent.  Method returns
  # a set of option values that are used to build the drop down boxes in the ADST main panel.
  #
  # POST /rollcall/query_options
  def get_options
    schools          = current_user.schools.all
    school_districts = current_user.school_districts.all
    default_options  = get_default_options({:schools => schools})
    
    zipcodes = current_user  
      .schools
      .select("rollcall_schools.postal_code")
      .where("rollcall_schools.postal_code is not null")
      .reorder("rollcall_schools.postal_code")      
      .uniq
      .pluck("rollcall_schools.postal_code")                     
    
    school_types = current_user
      .schools
      .select("rollcall_schools.school_type")
      .where("rollcall_schools.school_type is not null")
      .reorder("rollcall_schools.school_type")
      .uniq
      .pluck("rollcall_schools.school_type")                      
    
    grades = Rollcall::StudentDailyInfo
      .joins("inner join rollcall_students S on rollcall_student_daily_infos.student_id = S.id")
      .joins("inner join rollcall_schools SS on S.school_id = SS.id")
      .where("grade between 0 and 12")
      .where("grade is not null")
      .order(:grade)
      .uniq
      .pluck(:grade)
    
    @options = {:schools => schools, :school_districts => school_districts, :default_options => default_options, :zipcodes => zipcodes, :school_types => school_types, :grades => grades}          
  end
  
  protected
  
  def load_reults params
    if params[:return_individual_school].blank?
      school_ids = current_user
        .school_search_relation(params)
        .where('rollcall_schools.district_id is not null')
        .reorder('rollcall_schools.district_id')
        .pluck('rollcall_schools.district_id')
        .uniq
      results = current_user.school_districts.where("rollcall_school_districts.id in (?)", school_ids)
    else
      results = current_user.school_search params
    end
    
    results
  end
end
