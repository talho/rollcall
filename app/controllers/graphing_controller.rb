# The Graphing controller class for the Rollcall application.  This controller class handles
# the initial search request(index), the export request, the report request, and the
# get_options method (which returns the drop down values for the Rollcall Graphing application).
#
# Author::    Eddie Gomez  (mailto:eddie@talho.org)
# Copyright:: Copyright (c) 2011 TALHO
#
# The actions held in this controller are called by the Rollcall Graphing panel.

class GraphingController < ApplicationController
  respond_to :html, only: [:index]
  respond_to :json, except: [:index]

  # Action is called by the GraphingResultPanel result_store on load.  Method processes
  # the search request, calling get_graph_data(), returns
  # the total result length and the paginated result set
  #
  # GET /rollcall/graphing
  def index
    params[:span] ||= '3month'
    @type = params[:type] ||= :school_district
    @entities = params[:type] == 'school' ? School.for_user(current_user) : current_user.school_districts
    @entities = @entities.page(params[:page]).per(5)
  end

  def school
    @school = School.includes(:school_district).find(params[:id])
    authorize! :read, @school
    @infos = DataFilterService.new(:school, params).graph.where(:'schools.id' => @school.id)
    render json: Graph.new(@school, @infos), root: false
  end

  def school_district
    @school_district = SchoolDistrict.find(params[:id])
    authorize! :read, @school_district
    @infos = DataFilterService.new(:school_district, params).graph.where(:'school_districts.id' => @school_district.id)
    render json: Graph.new(@school_district, @infos), root: false
  end

  # Action is called by the Graphing main panel method exportResultSet and the GraphingResultPanel method exportResult.
  # Method sets the export file name based on export params.  Method then calls a delayed job on
  # export_data(a delayed job) which is responsible for gathering the data, creating a csv file, and placing it
  # in the users documents folder and sending out message to users email when process is done.
  #
  # GET /rollcall/export
  def export
    results = get_search_results params
    export_hash = {:params => params, :user_id => current_user.id}
    graphing_results = Rollcall::GraphingResults.new
    graphing_results.export_data(export_hash)
  end

  # Action is called by the Graphing main panel method initFormComponent.  Method returns
  # a set of option values that are used to build the drop down boxes in the Graphing main panel.
  #
  # POST /rollcall/query_options
  def get_options
    default_options = get_default_options
    zipcodes = current_user.rollcall_zip_codes

    school_types = current_user
      .schools
      .select("rollcall_schools.school_type")
      .where("rollcall_schools.school_type is not null")
      .reorder("rollcall_schools.school_type")
      .uniq
      .pluck("rollcall_schools.school_type")

    @options = {:schools => current_user.schools.all, :school_districts => current_user.school_districts.all, :default_options => default_options, :zipcodes => zipcodes, :school_types => school_types, :grades => (0..12).to_a }
  end

  # GET /rollcall/search_results
  def search_results
    @results = get_search_results params

    respond_with(@results)
  end

  def get_neighbors
    params[:startdt] ||= 3.months.ago.to_s # put a 3 month limit on start date to limit data points being returned
    params[:enddt] ||= Date.today.to_s

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
        return render :json => {:success => false}
      end
    end

    @school_district_array.each do |sd|
      sd.result = sd.get_graph_data(params).as_json
    end

    @length = @school_district_array.count

    respond_with(@length, @school_district_array)
  end
end
