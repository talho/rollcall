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
    options = {:page => (params[:start] ? (params[:start].to_f / 6).floor + 1 : 1), :per_page => params[:limit] || 6}    

    @results = get_search_results(params).paginate(options)
    @length = @results.total_entries
        
    @results.each do |r|
      r.result = r.get_graph_data(params).as_json
    end
        
    if defined? REPORT_DB
      collection = REPORT_DB.collection("adst_analytics")
      
      doc = {"params" => params, "home_jurisdiction_id" => current_user.home_jurisdiction_id }
      
      collection.insert(doc)
    end 
    
    respond_with(@length, @results)    
  end

  # Action is called by the ADST main panel method exportResultSet and the ADSTResultPanel method exportResult.
  # Method sets the export file name based on export params.  Method then calls a delayed job on
  # export_data(a delayed job) which is responsible for gathering the data, creating a csv file, and placing it
  # in the users documents folder and sending out message to users email when process is done.
  #
  # GET /rollcall/export
  def export    
    results = get_search_results params
    export_hash = {:params => params, :user_id => current_user.id}
    adst_results = Rollcall::AdstResults.new
    adst_results.export_data(export_hash)    
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
    default_options  = get_default_options
    
    zipcodes = current_user.rollcall_zip_codes              
    
    school_types = current_user
      .schools
      .select("rollcall_schools.school_type")
      .where("rollcall_schools.school_type is not null")
      .reorder("rollcall_schools.school_type")
      .uniq
      .pluck("rollcall_schools.school_type")                      
        
    @options = {:schools => current_user.schools.all, :school_districts => current_user.school_districts.all, :default_options => default_options, :zipcodes => zipcodes, :school_types => school_types, :grades => (0..12).to_a}          
  end
  
  # GET /rollcall/search_results
  def search_results
    @results = get_search_results params    
    
    respond_with(@results)
  end
  
  def get_neighbors       
    @school_district_array = Array.new
    
    if params.has_key?(:school_districts) 
      params[:school_districts].map! do |sd|
          sd.to_i
        end 
      if current_user.has_school_districts(params[:school_districts])      
        #check to see if user has the school districts
        params[:school_districts].each do |sd|
          Rollcall::SchoolDistrict.get_neighbors(sd).each do |neighbor|
            @school_district_array.push(neighbor)
          end
        end
      else
        return render :json => {:dashboard => {}, :success => false}
      end
    end

    @school_district_array.each do |sd|      
      sd.result = sd.get_graph_data(params).as_json
    end
    
    @length = @school_district_array.count
    
    respond_with(@length, @school_district_array)
  end
  
  protected
  
  def get_search_results params
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
