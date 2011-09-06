# == Schema Information
#
# Table name: rollcall_rrd
#
#  id                 :integer(4)      not null, primary key
#  file_name          :string(255)
#  school_id          :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Rollcall::Rrd < Rollcall::Base
  belongs_to :school, :class_name => "Rollcall::School"
  set_table_name "rollcall_rrds"

  validates_presence_of :school_id, :file_name

  def self.render_graphs(params, school)
    return [] if school.blank?
    
    conditions     = set_conditions params 
    tea_id         = school.tea_id
    filename       = "#{tea_id}_absenteeism"
    filename       = "#{tea_id}_c_absenteeism" if Rails.env == 'cucumber'
    image_file     = set_filename conditions, filename, 'image'

    rrd_file       = set_filename conditions, filename, 'rrd'
    rrd_image_path = Dir.pwd << "/public/rrd/"
    results        = find(:all, :conditions => ['file_name LIKE ?', "#{rrd_file}"]).first
    school_name    = school.display_name.gsub(" ", "_")
    if conditions[:confirmed_illness].blank?
      graph_title = "Gross Absenteeism for #{school_name}"
    else
      graph_title = "Confirmed Absenteeism for #{school_name}"
    end
    unless params[:symptoms].blank?
      #if params[:symptoms].index("...").blank?
        graph_title = "Absenteeism for #{school_name} based on #{params[:symptoms]}"
      #end
    end
    if results.blank?
      school_id      = Rollcall::School.find_by_tea_id(tea_id).id
      create_results = create :file_name => "#{rrd_file}", :school_id => school_id
      rrd_id         = create_results.id
      self.send_later(:reduce_rrd, params, school_id, conditions, rrd_file, rrd_image_path, image_file, graph_title)
    else
      rrd_id         = results.id
      rrd_file       = results.file_name
      File.delete("#{rrd_image_path}#{image_file}") if File.exist?("#{rrd_image_path}#{image_file}")
      self.send_later(:graph, rrd_file, image_file, graph_title, params)
    end
    { :image_url => "/rrd/#{image_file}", :rrd_id => rrd_id }
  end

  def self.export_rrd_data params, filename, user_obj
    initial_result     = Rollcall::School.search params, user_obj
    unless params[:startdt].blank?
      start_date = Time.gm(Time.parse(params[:startdt]).year,Time.parse(params[:startdt]).month,Time.parse(params[:startdt]).day)
    else
      start_date = Time.gm(2010,"aug",01,0,0)
    end
    unless params[:enddt].blank?
      end_date = Time.gm(Time.parse(params[:enddt]).year,Time.parse(params[:enddt]).month,Time.parse(params[:enddt]).day)
    else
      end_date = Time.gm(Time.now.year,Time.now.month,Time.now.day)
    end
    conditions         = set_conditions params
    @csv_data          = build_csv_string initial_result, end_date, start_date, conditions
    newfile            = File.join(Rails.root,'tmp',"#{filename}.csv")
    file_result        = File.open(newfile, 'wb') {|f| f.write(@csv_data) }
    file               = File.new(newfile, "r")
    folder             = Folder.find_by_name("Rollcall Documents")
    folder             = Folder.create(
      :name => "Rollcall Documents",
      :notify_of_document_addition => true,
      :owner => user_obj) if folder.blank?

    folder.audience.recipients(:force => true).length if folder.audience
    @document          = user_obj.documents.build(:folder_id => folder.id, :file => file)
    #@document.owner_id = user_obj.id
    @document.save!
    if !@document.folder.nil? && @document.folder.notify_of_document_addition
      DocumentMailer.deliver_rollcall_document_addition(@document, user_obj)
    end
    return true
  end

  def self.generate_report params, user_obj
    initial_result     = Rollcall::School.search params, user_obj
    test_data_date     = Time.parse("11/22/2010")
    start_date         = params[:startdt].blank? ? test_data_date : Time.parse(params[:startdt])
    end_date           = params[:enddt].blank? ? Time.now : Time.parse(params[:enddt])
    conditions         = set_conditions params
    report_data        = build_report initial_result, end_date, start_date, conditions
    report_file        = user_obj.reports.build({:report => report_data, :template => report_template})
    @document          = user_obj.documents.build({:folder_id => nil, :file => report_file})
    @document.owner_id = user_obj.id
    @document.save!
    if !@document.folder.nil? && @document.folder.notify_of_document_addition
      DocumentMailer.deliver_document_addition(@document, user_obj)
    end
    return true
  end

  def self.build_rrd identifier, school_id, gm_date_time
    rrd_path       = Dir.pwd << "/rrd/"
    rrd_tool       = ROLLCALL_RRDTOOL_CONFIG["rrdtool_path"] + "/rrdtool"
    rrd_start_date = gm_date_time - 1.day
    RRD.create("#{rrd_path}#{identifier}_absenteeism.rrd",
      {
        :step  => 24.hours.seconds,
        :start => rrd_start_date.to_i,
        :ds    => [{
          :name => "Absent", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
        },{
          :name => "Enrolled", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
        }],
        :rra => [{
          :type => "AVERAGE", :xff => 0.5, :steps => 5, :rows => 366
        },{
          :type => "HWPREDICT", :rows => 366, :alpha=> 0.5, :beta => 0.5, :period => 366, :rra_num => 3
        },{
          :type => "SEASONAL", :period => 365, :gamma => 0.5, :rra_num => 2
        },{
          :type => "DEVSEASONAL", :period => 366, :gamma => 0.5, :rra_num => 2
        },{
          :type => "DEVPREDICT", :rows => 366, :rra_num => 4
        },{
          :type => "MAX", :xff => 0.5, :steps => 1, :rows => 366
        },{
          :type => "LAST", :xff => 0.5, :steps => 1, :rows => 366
        }]
      } , "#{rrd_tool}") unless File.exists?("#{rrd_path}#{identifier}_absenteeism.rrd")
    find_or_create_by_file_name(
      :file_name => "#{identifier}_absenteeism.rrd", :school_id => school_id
    )
  end

  private

  # Dev Note: All Date times must be in UTC format for rrd
  def self.graph rrd_file, image_file, graph_title, params
    test_data_date = Time.gm(2010, "sep", 01,0,0)
    rrd_image_path = Dir.pwd << "/public/rrd/"
    rrd_path       = Dir.pwd << "/rrd/"
    rrd_tool       = ROLLCALL_RRDTOOL_CONFIG["rrdtool_path"] + "/rrdtool"
    if params[:startdt].blank?
      start_date = test_data_date
    else
      start_date = Time.gm(Time.parse(params[:startdt]).year, Time.parse(params[:startdt]).month, Time.parse(params[:startdt]).day)
    end
    if params[:enddt].blank?
      end_date = Time.gm(Time.now.year, Time.now.month, Time.now.day)
    else
      end_date = Time.gm(Time.parse(params[:enddt]).year, Time.parse(params[:enddt]).month, Time.parse(params[:enddt]).day) + 1.day
    end
    return RRD.graph(
      "#{rrd_path}#{rrd_file}","#{rrd_image_path}#{image_file}",
      {
        :start      => start_date,
        :end        => end_date,
        :step       => 24.hours.seconds,
        :width      => 300,
        :height     => 120,
        :image_type => "PNG",
        :title      => graph_title,
        :vlabel     => "total absent",
        #:lowerlimit => 0,
        :defs       => build_defs(params),
        :cdefs      => build_cdefs(params),
        :elements   => build_elements(params)
      }, "#{rrd_tool}")
  end

  def self.build_csv_string data_obj, end_date, start_date, conditions
    csv_data = "School Name,TEA ID,Total Absent,Total Enrolled,Report Date\n"
    days     = ((end_date - start_date) / 86400)
    data_obj.each do |rec|      
      (0..days).each do |i|
        report_date = start_date + i.days
        school_info = Rollcall::SchoolDailyInfo.find_by_report_date_and_school_id(report_date, rec.id)
        unless school_info.blank?
          total_enrolled = school_info.total_enrolled
          total_absent   = get_total_absent report_date, conditions, rec.id
          csv_data       = "#{csv_data}#{rec.display_name},#{rec.tea_id},#{total_absent},#{total_enrolled},#{report_date}\n"
        end
      end
    end
    csv_data
  end

  def self.build_report data_obj, end_date, start_date, conditions
    result = [];
    data_obj.each do |rec|
      days = ((end_date - start_date) / 86400)
      (0..days).each do |i|
        report_date = start_date + i.days
        school_info = Rollcall::SchoolDailyInfo.find_by_report_date_and_school_id(report_date, rec.id)
        unless school_info.blank?
          result.push({
            :total_enrolled => school_info.total_enrolled,
            :total_absent   => get_total_absent(report_date, conditions, rec.id),
            :report_date    => report_date
          })
        end
      end
    end
    result
  end

  def self.build_defs options
    defs = []
    defs.push({:key => "a", :cf => "LAST", :ds_name => "Absent"})
    if options[:enrolled_base_line] == "on"
      defs.push({:key => "b", :cf => "LAST", :ds_name => "Enrolled"})
    end
    defs
  end

  def self.build_cdefs options
    cdefs = []
    case options[:data_func]
    when "Standard Deviation"
      cdefs.push({:key => 'a', :new_key => 'sum', :rpn => ['PREV','UN','0','PREV','IF','+']})
      cdefs.push({:key => 'sum', :new_key => 'meanavg', :rpn => ['COUNT','/']})
      cdefs.push({:key => 'meanavg', :new_key => 'avgdiff', :rpn => ['PREV','UN','0','PREV','IF','-']})
      cdefs.push({:key => 'avgdiff', :new_key => 'avgsqr', :rpn => ['avgdiff','*']})
      cdefs.push({:key => 'avgsqr', :new_key => 'avgsqrttl', :rpn => ['PREV','UN','0','PREV','IF','+']})
      cdefs.push({:key => 'avgsqrttl', :new_key => 'avgsqrdiv', :rpn => ['COUNT','/']})
      cdefs.push({:key => 'avgsqrdiv', :new_key => 'msd', :rpn => ['SQRT']})
    when "Average"
      cdefs.push({:key => 'a', :new_key => 'sum', :rpn => ['PREV','UN','0','PREV','IF','+']})
      cdefs.push({:key => 'sum', :new_key => 'mavg', :rpn => ['COUNT','/']})
    when "Moving Average 30 Day"
      cdefs.push({:key => 'a', :new_key => 'mavg30d', :rpn => [2592000,'TREND']})
    when "Moving Average 60 Day"
      cdefs.push({:key => 'a', :new_key => 'mavg60d', :rpn => [5184000,'TREND']})
    when "Cusum"
      cdefs.push({:key => 'a', :new_key => 'cusum', :rpn => ['PREV','UN','0','PREV','IF','+','20','-','0','MAX']})
    end
    cdefs
  end

  def self.build_elements options
    elements     = []
    school_color = get_random_color
    if options[:absent] == "Confirmed Illness"
      absent_text = "Total Confirmed Absent"
    else
      absent_text = "Total Gross Absent"
    end 
    elements.push({:key => 'a', :element => "AREA", :color => school_color, :text => absent_text})
    case options[:data_func]
    when "Standard Deviation"
      school_color = get_random_color
      elements.push({:key => 'msd', :element => "LINE1", :color => school_color, :text => "Moving Standard Deviation"})
    when "Average"
      school_color = get_random_color
      elements.push({:key => 'mavg', :element => "LINE1", :color => school_color, :text => "Average"})
    when "Moving Average 30 Day"
      school_color = get_random_color
      elements.push({:key => 'mavg30d', :element => "LINE1", :color => school_color, :text => "Moving Average 30 Day"})
    when "Moving Average 60 Day"
      school_color = get_random_color
      elements.push({:key => 'mavg60d', :element => "LINE1", :color => school_color, :text => "Moving Average 60 Day"})
    when "Cusum"
      school_color = get_random_color
      elements.push({:key => 'cusum', :element => "LINE1", :color => school_color, :text => "Cusum"})
    end
    school_color = get_random_color
    if options[:enrolled_base_line] == "on"
      elements.push({:key => 'b', :element => "LINE1", :color => school_color, :text => "Total Enrolled"})
    end
    elements
  end

  def self.reduce_rrd params, school_id, conditions, rrd_file, rrd_image_path, image_file, graph_title
    rrd_path = Dir.pwd << "/rrd/"
    unless conditions.blank?
      rrd_tool = ROLLCALL_RRDTOOL_CONFIG["rrdtool_path"] + "/rrdtool"
      unless conditions[:startdt].blank?
        parsed_date    = Time.parse(conditions[:startdt])
        rrd_start_date = Time.gm(parsed_date.year,parsed_date.month,parsed_date.day) - 1.day
      else
        rrd_start_date = Time.gm(Time.now.year, "aug", 01,0,0) - 1.day
      end
      RRD.create "#{rrd_path}#{rrd_file}",
      {
        :step  => 24.hours.seconds,
        :start => (rrd_start_date).to_i,
        :ds    => [
          {
            :name => "Absent", :type => "GAUGE", :heartbeat => 24.hours.seconds, :min => 0, :max => 768000
          },
          {
            :name => "Enrolled", :type => "GAUGE", :heartbeat => 24.hours.seconds, :min => 0, :max => 768000
          }
        ],
        :rra => [{
          :type => "AVERAGE", :xff => 0.5, :steps => 5, :rows => 366
        },{
          :type => "HWPREDICT", :rows => 366, :alpha=> 0.5, :beta => 0.5, :period => 365, :rra_num => 3
        },{
          :type => "SEASONAL", :period => 365, :gamma => 0.5, :rra_num => 2
        },{
          :type => "DEVSEASONAL", :period => 365, :gamma => 0.5, :rra_num => 2
        },{
          :type => "DEVPREDICT", :rows => 366, :rra_num => 4
        },{
          :type => "MAX", :xff => 0, :steps => 1, :rows => 366
        },{
          :type => "MIN", :xff => 0, :steps => 1, :rows => 366
        },{
          :type => "LAST", :xff => 0, :steps => 1, :rows => 366
        }]
      } , "#{rrd_tool}"

      #school_daily_info = Rollcall::SchoolDailyInfo.find_by_school_id(school_id)
      students           = Rollcall::Student.find_all_by_school_id(school_id)
      student_daily_info = Rollcall::StudentDailyInfo.find_all_by_student_id(students, :order => "report_date ASC")

      if !conditions[:startdt].blank?
        parsed_sd  = Time.parse(conditions[:startdt])
        start_date = Time.gm(parsed_sd.year,parsed_sd.month,parsed_sd.day)
      elsif !student_daily_info.blank?
        #first_start_date = Rollcall::SchoolDailyInfo.find_all_by_school_id(school_id, :order => "report_date DESC").last.report_date
        first_start_date = student_daily_info.first.report_date
        start_date       = Time.gm(first_start_date.year, first_start_date.month, first_start_date.day)
      else
        start_date = Time.gm(Time.now.year,Time.now.month,Time.now.day)
      end
      if !conditions[:enddt].blank?
        parsed_ed  = Time.parse(conditions[:enddt])
        end_date   = Time.gm(parsed_ed.year,parsed_ed.month,parsed_ed.day)
      elsif !student_daily_info.blank?
        #last_end_date = Rollcall::SchoolDailyInfo.find_all_by_school_id(school_id, :order => "report_date ASC").last.report_date
        last_end_date = student_daily_info.last.report_date
        end_date      = Time.gm(last_end_date.year, last_end_date.month, last_end_date.day)
      else
        end_date      = Time.gm(Time.now.year,Time.now.month,Time.now.day)
      end
      days = ((end_date - start_date) / 86400)
      if days == 0
        end_date = Time.gm(Time.now.year,Time.now.month,Time.now.day)  
        days     = ((end_date - start_date) / 86400)
      end
      unless student_daily_info.blank?
        total_enrolled = Rollcall::SchoolDailyInfo.find_by_school_id(school_id).total_enrolled
      else
        total_enrolled = 0
      end     
      update_ary     = [ [start_date.to_i.to_s, 0, total_enrolled] ]
      (0..days).each do |i|
        report_date = start_date + i.days
        if report_date.strftime("%a").downcase == "sat" || report_date.strftime("%a").downcase == "sun"
          update_ary.push([(report_date + 1.day).to_i.to_s, 0, total_enrolled])
        else
          total_absent = get_total_absent report_date, conditions, school_id
          update_ary.push([(report_date + 1.day).to_i.to_s, total_absent, total_enrolled])
        end
      end
      update_ary.push([(start_date + (days+2).days).to_i.to_s, 0, total_enrolled])
      rrd_path = Dir.pwd << "/rrd/"
      rrd_tool = ROLLCALL_RRDTOOL_CONFIG["rrdtool_path"] + "/rrdtool"
      RRD.update_batch("#{rrd_path}/#{rrd_file}", update_ary, rrd_tool)
    end
    File.delete("#{rrd_image_path}#{image_file}") if File.exist?("#{rrd_image_path}#{image_file}")
    self.send_later(:graph, rrd_file, image_file, graph_title, params)
  end

  def self.set_conditions options
    conditions = {}
    options.each { |key,value|
      #if value.index('...').blank?
        case key
        when "data_func"
          conditions[:data_func] = value
        when "absent"
          if value == "Confirmed Illness"
            conditions[:confirmed_illness] = true
          end
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
      #end
    }
    return conditions
  end

  def self.set_filename conditions, filename, type
    conditions.sort_by.each{|key|key.to_s}.reverse.each{|key,value|
      case key
      when :confirmed_illness
        filename = "CNF_#{filename}"
      when :gender
        filename = "GNDR-#{value}_#{filename}"
      when :age
        filename = "AGE-#{value.join("-")}_#{filename}"
      when :grade
        filename = "GRD-#{value.collect{|v| v.to_i}.join("-")}_#{filename}"
      when :symptoms
        filename = "SYM-#{value.join("-")}_#{filename}" unless value.blank?
      when :startdt
        filename = "SD-#{Time.parse(value).strftime("%s")}_#{filename}" if type == 'image'
      when :enddt                                                      
        filename = "ED-#{Time.parse(value).strftime("%s")}_#{filename}" if type == 'image'
      when :data_func
        filename = "DF-#{value.gsub(" ", "")}_#{filename}" if type == 'image'
      else
      end
    }
    if type == 'image'
      filename = "#{filename}.png"
    else
      filename = "#{filename}.rrd"
    end
    return filename
  end

  def self.get_total_absent report_date, conditions, school_id
    condition_array = []
    string_flag     = false
    condition_array.push("")
    conditions.each{|key,value|
      if key == :age || key == :zip || key == :gender || key == :race
        if key == :age
          key = "dob"
          dobs = []
          value.each do |v|
            dobs.push("'#{(Time.now - v.to_i.years)}'")
          end
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
    unless conditions[:symptoms].blank?
      symptom_ids  = conditions[:symptoms].collect {|s| Rollcall::Symptom.find_by_icd9_code(s).id}
      join_string  = "INNER JOIN rollcall_student_reported_symptoms ON
                     rollcall_student_daily_infos.id = rollcall_student_reported_symptoms.student_daily_info_id AND
                     rollcall_student_reported_symptoms.symptom_id IN (#{symptom_ids.join(",")})"
      total_absent = Rollcall::StudentDailyInfo.find_all_by_student_id(students, :include => :student_reported_symptoms, :joins => join_string, :conditions => condition_array).size

    else
      total_absent = Rollcall::StudentDailyInfo.find_all_by_student_id(students, :conditions => condition_array).size
    end
    return total_absent
  end

  def self.get_random_color
    alpha         = ["A","B","C","D","E","F"]
    numeric       = ["0","1","2","3","4","5","6","7","8","9"]
    alpha_numeric = [alpha,numeric]
    color         = ""
    (0..5).each do
      alpha_or_numeric = rand(2)
      color           += alpha_numeric[alpha_or_numeric][rand(alpha_numeric[alpha_or_numeric].length)]
    end
    return color
  end
end