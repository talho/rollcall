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
  # the search request, calling Rollcall::Rrd.render_graphs (a delayed job), returns
  # the total result length and the paginated result set
  #
  # GET /rollcall/adst
  def index
    results_with_rrd = Array.new
    rrd_info         = Array.new
    options          = {:page => params[:page] || 1, :per_page => params[:limit] || 6}    
    results          = current_user.school_search params if params[:return_individual_school]
    results          = current_user.school_districts if params[:return_individual_school].blank?
    if params[:school_district] && params[:return_individual_school].blank?
      results = results.find_all{|r| params[:school_district].include?(r.name)}
    end
    results_paged    = results.paginate(options)
    results_paged.each do |r|
      rrd_info.push(Rollcall::Rrd.render_graphs(params, r)) if params[:return_individual_school]
      rrd_info.push(Rollcall::Rrd.render_graphs(params, r, {:foo_bar => true})) if params[:return_individual_school].blank?
    end
    results_paged.each_index { |i| results_with_rrd.push(results_paged[i].attributes.merge(rrd_info[i])) }
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results.length,
          :results       => results_with_rrd
        }
      end
    end
  end

  # Action is called by the ADST main panel method exportResultSet and the ADSTResultPanel method exportResult.
  # Method sets the export file name based on export params.  Method then calls a delayed job on
  # Rollcall::Rrd.export_rrd_data which is responsible for gathering the data, creating a csv file, and placing it
  # in the users documents folder and sending out message to users email when process is done. 
  #
  # GET /rollcall/export
  def export   
    if RAILS_ENV == "test"
      filename = "rollcall_export.cucumber.csv"
    else
      filename = "rollcall_export.#{Time.now.strftime("%m-%d-%Y")}.csv"
    end    
    Rollcall::Rrd.send_later(:export_rrd_data, params, filename, current_user)
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
    Rollcall::Rrd.send_later(:generate_report, params, current_user)
    respond_to do |format|
      format.json do
        render :json => {
          :success => true  
        }
      end
    end
  end

  # Action is called by the ADST main panel method initFormComponent.  Method returns
  # a set of option values that are used to build the drop down boxes in the ADST main panel.
  #
  # POST /rollcall/query_options
  def get_options
    absenteeism = [
      {:id => 0, :value => 'Gross'},
      {:id => 1, :value => 'Confirmed Illness'}
    ]
    age = [
      {:id => 1, :value => '0'},
      {:id => 2, :value => '1'},
      {:id => 3, :value => '2'},
      {:id => 4, :value => '3'},
      {:id => 5, :value => '4'},
      {:id => 6, :value => '5'},
      {:id => 7, :value => '6'},
      {:id => 8, :value => '7'},
      {:id => 9, :value => '8'},
      {:id => 10, :value => '9'},
      {:id => 11, :value => '10'},
      {:id => 12, :value => '11'},
      {:id => 13, :value => '12'},
      {:id => 14, :value => '13'},
      {:id => 15, :value => '14'},
      {:id => 16, :value => '15'},
      {:id => 17, :value => '16'},
      {:id => 18, :value => '17'},
      {:id => 19, :value => '18'}
    ]
    gender = [
      {:id => 0, :value => 'Select Gender...'},
      {:id => 1, :value => 'Male'},
      {:id => 2, :value => 'Female'}
    ]
    grade = [
      {:id => 1, :value => 'Kindergarten (Pre-K)'},
      {:id => 2, :value => '1st Grade'},
      {:id => 3, :value => '2nd Grade'},
      {:id => 4, :value => '3rd Grade'},
      {:id => 5, :value => '4th Grade'},
      {:id => 6, :value => '5th Grade'},
      {:id => 7, :value => '6th Grade'},
      {:id => 8, :value => '7th Grade'},
      {:id => 9, :value => '8th Grade'},
      {:id => 10,:value => '9th Grade'},
      {:id => 11,:value => '10th Grade'},
      {:id => 12,:value => '11th Grade'},
      {:id => 13,:value => '12th Grade'}
    ]
    symptoms       = Rollcall::Symptom.find(:all)
    data_functions = [
      {:id => 0, :value => 'Raw'},
      {:id => 1, :value => 'Average'},
      {:id => 2, :value => 'Standard Deviation'}
    ]
    data_functions_adv = [
      {:id => 0, :value => 'Raw'},
      {:id => 1, :value => 'Average'},
      {:id => 2, :value => 'Average 30 Day'},
      {:id => 3, :value => 'Average 60 Day'},
      {:id => 4, :value => 'Standard Deviation'},
      {:id => 5, :value => 'Cusum'}
    ]
    schools          = current_user.schools
    school_districts = current_user.school_districts
    zipcodes         = school_districts.map{|s| s.zipcodes.map{|i| {:id => i, :value => i}}}.flatten
    school_types     = school_districts.map{|s| s.school_types.map{|i| {:id => i, :value => i}}}.flatten
    respond_to do |format|
      format.json do
        render :json => {
          :options => [{
            :absenteeism        => absenteeism,
            :age                => age,
            :data_functions     => data_functions,
            :data_functions_adv => data_functions_adv,
            :gender             => gender,
            :grade              => grade,
            :school_districts   => school_districts,
            :school_type        => school_types,
            :schools            => schools,
            :symptoms           => symptoms,
            :zipcode            => zipcodes
          }]
        }
      end
    end
  end
end
