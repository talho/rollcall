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
        
    respond_with(@length, @results)    
  end

  # Action is called by the ADST main panel method exportResultSet and the ADSTResultPanel method exportResult.
  # Method sets the export file name based on export params.  Method then calls a delayed job on
  # export_data(a delayed job) which is responsible for gathering the data, creating a csv file, and placing it
  # in the users documents folder and sending out message to users email when process is done.
  #
  # GET /rollcall/export
  def export     
    filename = "rollcall_export.#{Time.now.strftime("%m-%d-%Y")}"
    results = get_search_results params
    self.delay.export_data(params, filename, current_user, results)    
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
  
  def export_data params, filename, user_obj, results    
    results.each do |r|
      r.result = r.get_graph_data(params).as_json            
    end
    
    @csv_data = "Name,Identifier,Total Absent,Total Enrolled,Report Date\n"
    results.each do |row|      
      @csv_data += "#{row.school_name},#{row.tea_id},#{row.result["total"]},#{row.result["enrolled"]},#{row.result["report_date"]}\n" unless row.result["total"].to_s == "0"
    end
    
    newfile            = File.join(Rails.root.to_s,'tmp',"#{filename}.csv")
    file_result        = File.open(newfile, 'wb') {|f| f.write(@csv_data) }
    file               = File.new(newfile, "r")
    folder             = Folder.find_by_name_and_user_id("Rollcall Documents", user_obj.id)
    folder             = Folder.create(
      :name => "Rollcall Documents",
      :notify_of_document_addition => true,
      :owner => user_obj) if folder.blank?
    @document = user_obj.documents.build(:folder_id => folder.id, :file => file)
    @document.save!
    if !@document.folder.nil? && @document.folder.notify_of_document_addition
      DocumentMailer.rollcall_document_addition(@document, user_obj).deliver
    end
    true
  rescue => e
    p e.message
    pp e.backtrace
  end
end
