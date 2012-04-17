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
  # Action is called by the ADSTResultPanel result_store on load.  Method processes
  # the search request, calling get_graph_data(), returns
  # the total result length and the paginated result set
  #
  # GET /rollcall/adst
  def index
    graph_info       = Array.new
    options          = {:page => params[:page] || 1, :per_page => params[:limit] || 6}
    results          = current_user.school_search params if params[:return_individual_school]
    results          = current_user.school_districts if params[:return_individual_school].blank?
    if params[:return_individual_school].blank?
      if params[:school_district]
        results = results.find_all{|r| params[:school_district].include?(r.name)}
      end
    end
    require 'will_paginate/array'
    results_paged = results.paginate(options)
    results_paged.each do |r|
      res = Rollcall::Data.get_graph_data(params, r) if params[:return_individual_school]
      res = Rollcall::Data.get_graph_data(params, r, {:foo_bar => true}) if params[:return_individual_school].blank?
      graph_info.push(res.flatten)
    end
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results.length,
          :results       => graph_info
        }
      end
    end
  end

  # Action is called by the ADST main panel method exportResultSet and the ADSTResultPanel method exportResult.
  # Method sets the export file name based on export params.  Method then calls a delayed job on
  # export_data(a delayed job) which is responsible for gathering the data, creating a csv file, and placing it
  # in the users documents folder and sending out message to users email when process is done.
  #
  # GET /rollcall/export
  def export
    filename = "rollcall_export.#{Time.now.strftime("%m-%d-%Y")}"
    Rollcall::Data.delay.export_data(params, filename, current_user)

    respond_to do |format|
      format.json do
        render :json => {
          :success => true
        }
      end
    end
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
      respond_to do |format|
        format.json {render :json => {:success => true, :id => report[:id]}}
      end
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
    schools          = current_user.schools
    school_districts = current_user.school_districts
    default_options  = get_default_options({:schools => schools})
    zipcodes         = school_districts.map{|s| s.zipcodes.map{|i| {:id => i, :value => i}}}.flatten.uniq
    school_types     = school_districts.map{|s| s.school_types.map{|i| {:id => i, :value => i}}}.flatten.uniq
    grades           = []
    Rollcall::StudentDailyInfo.find_by_sql("SELECT grade FROM rollcall_student_daily_infos WHERE
                      student_id IN (SELECT id FROM rollcall_students WHERE school_id IN
                      (#{schools.map(&:id).to_s.gsub(/[\[\]]/,"")})) ORDER BY grade ASC").map(&:grade).uniq.delete_if{|d| d.blank?}.delete_if{|d| d < 0 || d > 12}.each_with_index{|g,i|
                        text = "#{g.ordinalize} Grade"
                        text = "Kindergarten (Pre-K)" if g == 0
                        grades.push({:id => i+1, :value => text})
                      }
    respond_to do |format|
      format.json do
        render :json => {
          :options => [{
            :absenteeism        => default_options[:absenteeism],
            :age                => default_options[:age],
            :data_functions     => default_options[:data_functions],
            :data_functions_adv => default_options[:data_functions_adv],
            :gender             => default_options[:gender],
            :grade              => grades,
            :school_districts   => school_districts,
            :school_type        => school_types,
            :schools            => schools,
            :symptoms           => default_options[:symptoms],
            :zipcode            => zipcodes
          }]
        }
      end
    end
  end
end
