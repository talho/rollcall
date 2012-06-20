class Rollcall::Data
  # Method exports data into CSV file and places it in users "Rollcall Documents" folder
  def self.export_data params, filename, user_obj
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
          t_ary.push({:report_date => s[:report_date], :total => s[:total_absent], :enrolled => s[:total_enrolled]})
          update_ary += t_ary
          update_ary.sort!{|a,b| a[:report_date] <=> b[:report_date]}
        }
      else
        t_ary = build_update_array Rollcall::School.find_by_tea_id(i[:tea_id]).id, conditions
        t_ary.each{|u|
          r_d_t_i         = Time.at(u[:report_date].to_i)
          u[:report_date] = "#{r_d_t_i.strftime('%b')}-#{r_d_t_i.strftime('%d')}-#{r_d_t_i.strftime('%y')}"
          u[:tea_id]      = i.tea_id
          u[:school_name] = i.display_name
        }
        if t_ary.length == 0
          t_ary.push({
              :school_name => i.display_name,
              :tea_id      => i.tea_id,
              :report_date => nil
          })
        end
        update_ary += t_ary
      end
    end
    @csv_data          = build_csv_string update_ary
    newfile            = File.join(Rails.root.to_s,'tmp',"#{filename}.csv")
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
      DocumentMailer.rollcall_document_addition(@document, user_obj).deliver
    end
    return true
  end

  # Method extracts data from and returns array of objects
  def self.get_graph_data(params, obj, options={})
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
        update_ary.push({:report_date => s[:report_date],:total => s[:total_absent],:name => sd[:name]})
      }
      if update_ary.length > 0
        data_func_ary = build_data_function_sets update_ary, params
        update_ary    = (update_ary + data_func_ary).group_by{|a| a[:report_date]}.map{|k,v| v.reduce(:merge)}
      end
      update_ary.push(:name => sd[:name]) if update_ary.length == 0
    else
      update_ary = build_update_array Rollcall::School.find_by_tea_id(i[:tea_id]).id, conditions, {:graph => true}
      if update_ary.length > 0
        data_func_ary = build_data_function_sets update_ary, params
        update_ary    = (update_ary + data_func_ary).group_by{|a| a[:report_date]}.map{|k,v| v.reduce(:merge)}
      end
      update_ary.each{|u|
        r_d_t_i         = Time.at(u[:report_date].to_i)
        u[:report_date] = "#{r_d_t_i.strftime('%m')}-#{r_d_t_i.strftime('%d')}-#{r_d_t_i.strftime('%y')}"
      }
      if update_ary.length == 0
        update_ary.push({
          :school_name => i.display_name,
          :tea_id      => i.tea_id,
          :school_id   => i.id,
          :gmap_lat    => i.gmap_lat,
          :gmap_lng    => i.gmap_lng,
          :gmap_addr   => i.gmap_addr
        })
      else
        update_ary.first[:tea_id]      = i.tea_id
        update_ary.first[:school_name] = i.display_name
        update_ary.first[:school_id]   = i.id
        update_ary.first[:gmap_lat]    = i.gmap_lat
        update_ary.first[:gmap_lng]    = i.gmap_lng
        update_ary.first[:gmap_addr]   = i.gmap_addr
      end
    end
    update_ary
  end

  # Method builds array with data
  #
  # Method runs and gathers student data, pushes it into array, returns array
  def self.build_update_array record_id, conditions, options={}
    students           = Rollcall::Student.find_all_by_school_id(record_id)
    student_daily_info = students.map(&:student_daily_info).flatten.sort{|a,b| a.report_date <=> b.report_date}

    #student_daily_info = Rollcall::StudentDailyInfo.find_all_by_student_id(students, :order => "report_date ASC")
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
    school_total   = Rollcall::SchoolDailyInfo.find_by_school_id(record_id)
    total_enrolled = school_total.blank? ? 0 : school_total.total_enrolled
    update_ary = []
    (0..days).each do |i|
      report_date           = start_date + i.days
      total_absent          = get_total_absent report_date, conditions, record_id
      total_absent          = total_absent == false ? 0 : total_absent
      total_absent          = total_absent.blank? ? 0 : total_absent
      update_obj            = {:report_date => (report_date + 1.day).to_i.to_s,:total => total_absent}
      update_obj[:enrolled] = total_enrolled if options[:graph].blank?
      update_ary.push(update_obj) if total_absent > 0
    end
    update_ary
  end

  # Method returns total absent of students
  #
  # Method returns total absent of student based on conditions and school
  def self.get_total_absent report_date, conditions, school_id
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
        end
        #else
          condition_array[0] += " AND " if string_flag
          if value.is_a?(Array)
            condition_array[0] += "#{key} IN (#{value.join(",")})"
          else
            condition_array[0] += "#{key} = ?"
            condition_array.push(value)
          end
          string_flag = true
        #end
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

  # Method returns conditions object
  #
  # Method builds a condition array based on passed options
  def self.set_conditions options
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

  # Method builds the data function set
  #
  # Method builds the data function set based on options, returns data function data set
  def self.build_data_function_sets data, options
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

  # Method builds a csv string
  #
  # Method builds a csv string based off the data_obj
  def self.build_csv_string data_obj
    csv_data = "Name,Identifier,Total Absent,Total Enrolled,Report Date\n"
    trip     = false
    count    = data_obj.length
    data_obj.reverse_each{|d|
      count -= 1
      if d[:total].to_s == "0"
        data_obj.delete_at(count)
      else
        break
      end
    }
    data_obj.each{|d|
      trip = true if d[:total].to_s != "0"
      if trip
        csv_data = "#{csv_data}#{d[:school_name]},#{d[:tea_id]},#{d[:total]},#{d[:enrolled]},#{d[:report_date]}\n"
      end
    }
    csv_data
  end
end