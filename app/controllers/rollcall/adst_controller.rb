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
      #else
      #  results = results.find_all{|r| current_user.school_districts.include?(r.name)}
      end
    end
    results_paged = results.paginate(options)
    results_paged.each do |r|
      res = get_graph_data(params, r) if params[:return_individual_school]
      res = get_graph_data(params, r, {:foo_bar => true}) if params[:return_individual_school].blank?
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
    if RAILS_ENV == "test"
      filename = "rollcall_export.cucumber"
      export_data(params, filename, current_user)
    else
      filename = "rollcall_export.#{Time.now.strftime("%m-%d-%Y")}"
      send_later(:export_data, params, filename, current_user)
    end    

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

  private

  def get_graph_data(params, obj, options={})
    conditions = set_conditions params
    update_ary = []
    i          = obj
    unless params[:startdt].blank?
      conditions[:startdt] = params[:startdt]
    else
      conditions[:startdt] = "08/01/#{Time.now.month < 8 ? Time.now.year - 1 : Time.now.year}"
    end
    unless params[:enddt].blank?
      conditions[:enddt] = params[:enddt]
    else
      conditions[:enddt] = Time.now.strftime("%m/%d/%Y")
    end
    if i[:tea_id].blank?
      sd = Rollcall::SchoolDistrict.find_by_district_id(i[:district_id])
      sd.daily_infos.each{|s|
        update_ary.push({
          :report_date => s[:report_date],
          :total       => s[:total_absent],
          :enrolled    => s[:total_enrolled],
          :name        => sd[:name]
        })
      }
      if update_ary.length > 0
        data_func_ary = build_data_function_sets update_ary, params
        update_ary    = (update_ary + data_func_ary).group_by{|a| a[:report_date]}.map{|k,v| v.reduce(:merge)}
      end
      if update_ary.length == 0
        update_ary.push(:name => sd[:name])
      end
    else
      update_ary = build_update_array Rollcall::School.find_by_tea_id(i[:tea_id]).id, conditions
      if update_ary.length > 0
        data_func_ary = build_data_function_sets update_ary, params
        update_ary    = (update_ary + data_func_ary).group_by{|a| a[:report_date]}.map{|k,v| v.reduce(:merge)}
      end   
      update_ary.each{|u|
        r_d_t_i         = Time.at(u[:report_date].to_i)
        u[:report_date] = "#{r_d_t_i.strftime('%b')}-#{r_d_t_i.strftime('%d')}-#{r_d_t_i.strftime('%y')}"
        u[:tea_id]      = i.tea_id
        u[:school_name] = i.display_name
        u[:school_id]   = i.id
        u[:gmap_lat]    = i.gmap_lat
        u[:gmap_lng]    = i.gmap_lng
        u[:gmap_addr]   = i.gmap_addr
      }
      if update_ary.length == 0
        update_ary.push({
          :school_name => i.display_name,
          :tea_id      => i.tea_id,
          :school_name => i.display_name,
          :gmap_lat    => i.gmap_lat,
          :gmap_lng    => i.gmap_lng,
          :gmap_addr   => i.gmap_addr
      })
      end
    end
    update_ary
  end

  def build_update_array record_id, conditions
    students           = Rollcall::Student.find_all_by_school_id(record_id)
    student_daily_info = Rollcall::StudentDailyInfo.find_all_by_student_id(students, :order => "report_date ASC")
    if !conditions[:startdt].blank?
      parsed_sd  = DateTime.strptime(conditions[:startdt], "%m/%d/%Y")
      start_date = Time.gm(parsed_sd.year,parsed_sd.month,parsed_sd.day)
    elsif !student_daily_info.blank?
      first_start_date = student_daily_info.first.report_date
      start_date       = Time.gm(first_start_date.year, first_start_date.month, first_start_date.day)
    else
      start_date = Time.gm(Time.now.year,Time.now.month,Time.now.day)
    end
    if !conditions[:enddt].blank?
      parsed_ed  = DateTime.strptime(conditions[:enddt], "%m/%d/%Y")
      end_date   = Time.gm(parsed_ed.year,parsed_ed.month,parsed_ed.day)
    elsif !student_daily_info.blank?
      last_end_date = student_daily_info.last.report_date
      end_date      = Time.gm(last_end_date.year, last_end_date.month, last_end_date.day)
    else
      end_date = Time.gm(Time.now.year,Time.now.month,Time.now.day)
    end
    days = ((end_date - start_date) / 86400)
    if days == 0
      end_date = Time.gm(Time.now.year,Time.now.month,Time.now.day)
      days     = ((end_date - start_date) / 86400)
    end
    unless student_daily_info.blank?
      school_total   = Rollcall::SchoolDailyInfo.find_by_school_id(record_id)
      total_enrolled = school_total.blank? ? 0 : school_total.total_enrolled
    else
      total_enrolled = 0
    end
    update_ary = []
    (0..days).each do |i|
      report_date  = start_date + i.days
      total_absent = get_total_absent report_date, conditions, record_id
      total_absent = total_absent == false ? 0 : total_absent
      update_ary.push({
        :report_date => (report_date + 1.day).to_i.to_s,
        :total       => total_absent,
        :enrolled    => total_enrolled
      }) if total_absent > 0
    end
    update_ary
  end

  def get_total_absent report_date, conditions, school_id
    condition_array = []
    string_flag     = false
    condition_array.push("")
    conditions.each{|key,value|
      if key == :age || key == :zip || key == :gender || key == :race
        if key == :age
          key = "dob"
          dobs = []
          value.each{|v| dobs.push("'#{(Time.now - v.to_i.years)}'")}
          value = dobs
        else
          condition_array[0] += " AND " if string_flag
          if value.is_a?(Array)
            condition_array[0] += "#{key} IN (#{value.join(",")})"
          else
            condition_array[0] += "#{key} = ?"
            condition_array.push(value)
          end
          string_flag = true
        end
      end
    }
    condition_array[0] += " AND " if string_flag
    condition_array[0] += "school_id = ?"
    condition_array.push(school_id)
    students        = Rollcall::Student.find(:all, :conditions => condition_array)
    condition_array = []
    string_flag     = false
    condition_array.push("")
    conditions.each{|key,value|
      if key != :symptoms && key != :startdt && key != :enddt && key != :zipcode && key != :data_func &&
        key != :age && key != :zip && key != :gender && key != :race
        condition_array[0] += " AND " if string_flag
        if value.is_a?(Array)
          condition_array[0] += "#{key} IN (#{value.join(",")})"
        else
          condition_array[0] += "#{key} = ?"
          condition_array.push(value)
        end
        string_flag = true
      end
    }
    condition_array[0] += " AND " if string_flag
    condition_array[0] += "report_date = ?"
    condition_array.push(report_date)
    if !conditions[:symptoms].blank?
      symptom_ids  = conditions[:symptoms].collect {|s| Rollcall::Symptom.find_by_icd9_code(s).id}
      join_string  = "INNER JOIN rollcall_student_reported_symptoms ON
                     rollcall_student_daily_infos.id = rollcall_student_reported_symptoms.student_daily_info_id AND
                     rollcall_student_reported_symptoms.symptom_id IN (#{symptom_ids.join(",")})"
      total_absent = Rollcall::StudentDailyInfo.find_all_by_student_id(students, :include => :student_reported_symptoms, :joins => join_string, :conditions => condition_array).size
    elsif !conditions[:confirmed_illness].blank?
      total_absent = Rollcall::StudentDailyInfo.find_all_by_student_id(students, :conditions => condition_array).size
    else
      r_s_i        = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date(school_id, report_date)
      total_absent = r_s_i.blank? ? false : r_s_i.total_absent
    end
    return total_absent
  end

  def set_conditions options
    conditions = {}
    options.each { |key,value|
      case key
      when "data_func"
        conditions[:data_func] = value
      when "absent"
        conditions[:confirmed_illness] = true if value == "Confirmed Illness"
      when "gender"
        conditions[:gender]   = 'M' if value == "Male"
        conditions[:gender]   = 'F' if value == "Female"
      when "age"
        conditions[:age]      = value.collect{|v| v.to_i}
      when "grade"
        conditions[:grade]    = value.collect{|v| v.to_i}
      when "symptoms"
        conditions[:symptoms] = value
      when "startdt"
        conditions[:startdt]  = value
      when "enddt"
        conditions[:enddt]    = value
      else
      end
    }
    return conditions
  end

  def build_data_function_sets data, options
    set = []
    case options[:data_func]
      when "Standard Deviation"
        total_sum  = 0
        data_count = 1
        data.each{|d|
          total_sum += d[:total]
          mean_avg   = total_sum / data_count
          total_diff_sum = 0
          (0..data_count).each do |p|
            total_diff_sum += (p - mean_avg)**2
          end
          set.push(:deviation => Math.sqrt(total_diff_sum / data.length), :report_date => d[:report_date])
          data_count += 1
        }     
      when "Average"
        total_sum  = 0
        data_count = 1
        data.each{|d|
          total_sum += d[:total]
          mean_avg = total_sum / data_count
          set.push({:average => mean_avg, :report_date => d[:report_date]})
          data_count += 1
        }
      when "Average 30 Day"
        total_sum  = 0
        data_count = 1
        data.each{|d|
          total_sum += d[:total]
          mean_avg = total_sum / data_count
          set.push({:average30 => mean_avg, :report_date => d[:report_date]})
          data_count += 1
          break if data_count == 30
        }
      when "Average 60 Day"
        total_sum  = 0
        data_count = 1
        data.each{|d|
          total_sum += d[:total]
          mean_avg = total_sum / data_count
          set.push({:average60 => mean_avg, :report_date => d[:report_date]})
          data_count += 1
          break if data_count == 60
        }
      when "Cusum"
        total_sum  = 0
        data_count = 0
        avg        = 0
        data.each{|d|total_sum += d[:total]}
        avg = total_sum / data.length
        data.each{|d|
          unless set.blank?
            cusum = set[data_count - 1][:cusum] + (d[:total] - avg)
          else
            cusum = d[:total] - avg
          end
          cusum = 0 if cusum < 0
          set.push({:cusum => cusum, :report_date => d[:report_date]})
          data_count += 1
        }
    end
    set
  end

  def export_data params, filename, user_obj
    initial_result = user_obj.school_search params if params[:return_individual_school]
    initial_result = user_obj.school_districts if params[:return_individual_school].blank?
    conditions     = set_conditions params
    if params[:school_district] && params[:return_individual_school].blank?
      initial_result = initial_result.find_all{|r| params[:school_district].include?(r.name)}
    end
    update_ary = []
    initial_result.each do |i|
      unless params[:startdt].blank?
        conditions[:startdt] = params[:startdt]
      else
        conditions[:startdt] = "08/01/#{Time.now.month < 8 ? Time.now.year - 1 : Time.now.year}"
      end
      unless params[:enddt].blank?
        conditions[:enddt] = params[:enddt]
      else
        conditions[:enddt] = Time.now.strftime("%m/%d/%Y")
      end
      if i[:tea_id].blank?
        Rollcall::SchoolDistrict.find_by_district_id(i[:district_id]).daily_infos.each{|s|
          update_ary.push({:report_date => s[:report_date], :total => s[:total_absent], :enrolled => s[:total_enrolled]})
        }
      else
        update_ary = build_update_array Rollcall::School.find_by_tea_id(i[:tea_id]).id, conditions
        update_ary.each{|u|
          r_d_t_i         = Time.at(u[:report_date].to_i)
          u[:report_date] = "#{r_d_t_i.strftime('%b')}-#{r_d_t_i.strftime('%d')}-#{r_d_t_i.strftime('%y')}"
          u[:tea_id]      = i.tea_id
          u[:school_name] = i.display_name
        }
        if update_ary.length == 0
          update_ary.push({
              :school_name => i.display_name,
              :tea_id      => i.tea_id,
              :report_date => nil
          })
        end
      end
      @csv_data          = build_csv_string update_ary
      newfile            = File.join(Rails.root,'tmp',"#{filename}.csv")
      file_result        = File.open(newfile, 'wb') {|f| f.write(@csv_data) }
      file               = File.new(newfile, "r")
      folder             = Folder.find_by_name_and_user_id("Rollcall Documents", user_obj.id)
      folder             = Folder.create(
        :name => "Rollcall Documents",
        :notify_of_document_addition => true,
        :owner => user_obj) if folder.blank?
      folder.audience.recipients(:force => true).length if folder.audience
      @document = user_obj.documents.build(:folder_id => folder.id, :file => file)
      @document.save!
      if !@document.folder.nil? && @document.folder.notify_of_document_addition
        DocumentMailer.deliver_rollcall_document_addition(@document, user_obj)
      end
      return true
    end
  end

  def build_csv_string data_obj
    csv_data = "Name,Identifier,Total Absent,Total Enrolled,Report Date\n"
    trip     = false
    count    = data_obj.length
    data_obj.reverse_each{|d|
      count -= 1
      if d[1].to_s == "0"
        data_obj.delete_at(count)
      else
        break
      end
    }
    data_obj.each{|d|
      trip = true if d[1].to_s != "0"
      if trip
        csv_data = "#{csv_data}#{d[:school_name]},#{d[:tea_id]},#{d[:total]},#{d[:enrolled]},#{d[:report_date]}\n"
      end
    }
    csv_data
  end
end
