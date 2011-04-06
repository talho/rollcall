# == Schema Information
#
# Table name: rollcall_rrd
#
#  id                 :integer(4)      not null, primary key
#  alarm_query_id     :integer(4)      foreign key
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
    conditions = set_conditions params

    return [] if school.blank?
    tea_id         = school.tea_id
    filename       = "#{tea_id}_absenteeism"
    some_file_name = set_filename conditions, filename
    image_file     = "#{some_file_name}.png"
    rrd_image_path = Dir.pwd << "/public/rrd/"
    results        = find(:all, :conditions => ['file_name LIKE ?', "#{some_file_name}.rrd"]).first
    school_name    = school.display_name.gsub(" ", "_")
    if conditions[:confirmed_illness].blank?
      graph_title    = "Gross Absenteeism for #{school_name}"
    else
      graph_title    = "Confirmed Absenteeism for #{school_name}"
    end

    unless params[:symptoms].blank?
      if params[:symptoms].index("...").blank?
        graph_title = "Absenteeism for #{school_name} based on #{params[:symptoms]}"
      end
    end
    if results.blank?
      school_id      = Rollcall::School.find_by_tea_id(tea_id).id
      create_results = create :file_name => "#{some_file_name}.rrd", :school_id => school_id
      rrd_id         = create_results.id
      rrd_file       = create_results.file_name
      self.send_later(:reduce_rrd, params, school_id, conditions, some_file_name, rrd_file, rrd_image_path, image_file, graph_title)
    else
      rrd_id         = results.id
      rrd_file       = results.file_name
      File.delete("#{rrd_image_path}#{image_file}") if File.exist?("#{rrd_image_path}#{image_file}")
      self.send_later(:graph, rrd_file, image_file, graph_title, params)
    end

    { "image_url" => "/rrd/#{image_file}", "rrd_id" => rrd_id }
  end

  def self.render_alarm_graphs alarm_queries
    image_urls = []
    unless alarm_queries.blank?
      alarm_queries.each do |alarm_query|
        query_params   = alarm_query.query_params.split("|")
        params         = {}
        query_params.each do |param|
          params[:"#{param.split('=')[0]}"] = param.split('=')[1]
        end
        tea_id      = params[:tea_id]
        rrd_file    = find(:all, :conditions => ['id LIKE ?', "#{alarm_query.rrd_id}"]).first.file_name
        image_file  = rrd_file.gsub(".rrd", ".png")
        school_name = Rollcall::School.find_by_tea_id(tea_id).display_name.gsub(" ", "_")
        graph_title = "Absenteeism for #{school_name}"
        unless params[:symptoms].blank?
          graph_title = "Absenteeism for #{school_name} based on #{params[:symptoms]}"
        end
        rrd_image_path = Dir.pwd << "/public/rrd/"
        File.delete("#{rrd_image_path}#{image_file}") if File.exist?("#{rrd_image_path}#{image_file}")
        self.send_later(:graph, rrd_file, image_file, graph_title, params)
        image_urls.push("/rrd/#{image_file}")
      end
    end
    return {
      :image_urls => image_urls
    }
  end

  def self.export_rrd_data params, filename, user_obj
    initial_result     = Rollcall::School.search params
    test_data_date     = Time.parse("11/22/2010")
    start_date         = params[:startdt].index('...') ? test_data_date : Time.parse(params[:startdt])
    end_date           = params[:enddt].index('...') ? Time.now : Time.parse(params[:enddt])
    conditions         = set_conditions params
    @csv_data          = build_csv_string initial_result, end_date, start_date, conditions
    newfile            = File.join(Rails.root,'tmp',"#{filename}.csv")
    file_result        = File.open(newfile, 'wb') {|f| f.write(@csv_data) }
    file               = File.new(newfile, "r")
    @document          = user_obj.documents.build({:folder_id => nil, :file => file})
    @document.owner_id = user_obj.id
    @document.save!
    if !@document.folder.nil? && @document.folder.notify_of_document_addition
      DocumentMailer.deliver_document_addition(@document, user_obj)
    end
    return true
  end

  def self.generate_report params, user_obj
    initial_result     = Rollcall::School.search params
    test_data_date     = Time.parse("11/22/2010")
    start_date         = params[:startdt].index('...') ? test_data_date : Time.parse(params[:startdt])
    end_date           = params[:enddt].index('...') ? Time.now : Time.parse(params[:enddt])
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

  def self.update_rrd_data report_date, total_absent, total_enrolled, filename
    rrd_path = Dir.pwd << "/rrd/"
    rrd_tool = ROLLCALL_RRDTOOL_CONFIG["rrdtool_path"] + "/rrdtool"
    return RRD.update "#{rrd_path}#{filename}.rrd",[report_date.to_i.to_s,total_absent,total_enrolled],"#{rrd_tool}"   
  end
  
  private

  # Dev Note: All Date times must be in UTC format for rrd
  def self.graph rrd_file, image_file, graph_title, params
    test_data_date = Time.gm(2010, "sep", 01,0,0)
    rrd_image_path = Dir.pwd << "/public/rrd/"
    rrd_path       = Dir.pwd << "/rrd/"
    rrd_tool       = ROLLCALL_RRDTOOL_CONFIG["rrdtool_path"] + "/rrdtool"
    if params[:startdt].blank? || params[:startdt].index('...')
      start_date = test_data_date
    else
      start_date = Time.gm(Time.parse(params[:startdt]).year, Time.parse(params[:startdt]).month, Time.parse(params[:startdt]).day)
    end
    if params[:enddt].blank? || params[:enddt].index('...')
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
        :lowerlimit => 0,
        :defs       => build_defs(params),
        :cdefs      => build_cdefs(params),
        :elements   => build_elements(params)
      }, "#{rrd_tool}")
  end

  def self.build_csv_string data_obj, end_date, start_date, conditions
    csv_data = "School Name,TEA ID,Total Absent,Total Enrolled,Report Date\n"
    data_obj.each do |rec|
      days = ((end_date - start_date) / 86400)
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
    when "Standard+Deviation"
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
    when "Moving+Average+30+Day"
      cdefs.push({:key => 'a', :new_key => 'mavg30d', :rpn => [2592000,'TREND']})
    when "Moving+Average+60+Day"
      cdefs.push({:key => 'a', :new_key => 'mavg60d', :rpn => [5184000,'TREND']})
    when "Cusum"
      cdefs.push({:key => 'a', :new_key => 'cusum', :rpn => ['PREV','UN','0','PREV','IF','+','20','-','0','MAX']})
    end
    cdefs
  end

  def self.build_elements options
    elements       = []
    school_color   = get_random_color
    if options[:absent] == "Confirmed+Illness"
      absent_text = "Total Confirmed Absent"
    else
      absent_text = "Total Gross Absent"
    end 
    elements.push({:key => 'a', :element => "AREA", :color => school_color, :text => absent_text})
    case options[:data_func]
    when "Standard+Deviation"
      school_color = get_random_color
      elements.push({:key => 'msd', :element => "LINE1", :color => school_color, :text => "Moving Standard Deviation"})
    when "Average"
      school_color = get_random_color
      elements.push({:key => 'mavg', :element => "LINE1", :color => school_color, :text => "Average"})
    when "Moving+Average+30+Day"
      school_color = get_random_color
      elements.push({:key => 'mavg30d', :element => "LINE1", :color => school_color, :text => "Moving Average 30 Day"})
    when "Moving+Average+60+Day"
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

  def self.reduce_rrd params, school_id, conditions, filename, rrd_file, rrd_image_path, image_file, graph_title
    rrd_path = Dir.pwd << "/rrd/"
    unless conditions.blank?
      rrd_tool = ROLLCALL_RRDTOOL_CONFIG["rrdtool_path"] + "/rrdtool"
      unless conditions[:startdt].blank?
        parsed_date    = Time.parse(conditions[:startdt])
        rrd_start_date = Time.gm(parsed_date.year,parsed_date.month,parsed_date.day) - 1.day
      else
        rrd_start_date = Time.gm(2010, "sep", 01,0,0) - 1.day
      end

      RRD.create "#{rrd_path}#{filename}.rrd",
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

      if !conditions[:startdt].blank?
        parsed_sd  = Time.parse(conditions[:startdt])
        start_date = Time.gm(parsed_sd.year,parsed_sd.month,parsed_sd.day)
      else
        first_start_date = Rollcall::SchoolDailyInfo.find_all_by_school_id(school_id, :order => "report_date DESC").last.report_date
        start_date       = Time.gm(first_start_date.year, first_start_date.month, first_start_date.day)
      end
      if !conditions[:enddt].blank?
        parsed_ed  = Time.parse(conditions[:enddt])
        end_date   = Time.gm(parsed_ed.year,parsed_ed.month,parsed_ed.day)
      else
        last_end_date  = Rollcall::SchoolDailyInfo.find_all_by_school_id(school_id, :order => "report_date ASC").last.report_date
        end_date       = Time.gm(last_end_date.year, last_end_date.month, last_end_date.day)
      end
      days           = ((end_date - start_date) / 86400)
      total_enrolled = Rollcall::SchoolDailyInfo.find_by_school_id(school_id).total_enrolled
      (0..days).each do |i|
        report_date = start_date + i.days
        if(i == 0)
          update_rrd_data report_date, 0, total_enrolled, filename
        end
        if report_date.strftime("%a").downcase == "sat" || report_date.strftime("%a").downcase == "sun"
          update_rrd_data report_date + 1.day, 0, total_enrolled, filename
        else
          total_absent = get_total_absent report_date, conditions, school_id
          begin
            update_rrd_data report_date + 1.day, total_absent, total_enrolled, filename
          rescue
          end
        end
        if(i == days.to_i)
          report_date = report_date + 1.day
          update_rrd_data (report_date + 1.day), 0, total_enrolled, filename
        end
      end
    end
    File.delete("#{rrd_image_path}#{image_file}") if File.exist?("#{rrd_image_path}#{image_file}")
    self.send_later(:graph, rrd_file, image_file, graph_title, params)
  end

  def self.set_conditions options
    conditions = {}
    options.each { |key,value|
      if value.index('...').blank?
        case key
        when "absent"
          if value == "Confirmed+Illness"
            conditions[:confirmed_illness] = true
          end
        when "gender"
          conditions[:gender]    = 'M' if value == "Male"
          conditions[:gender]    = 'F' if value == "Female"
        when "age"
          conditions[:age]       = value.to_i
        when "grade"
          conditions[:grade]     = value.to_i
        when "icd9_code"
          conditions[:icd9_code] = value
        when "symptoms"
          conditions[:symptom]   = value.gsub("+", " ")
        when "startdt"
          conditions[:startdt]   = value
        when "enddt"
          conditions[:enddt]     = value
        else
        end
      end
    }
    return conditions
  end

  def self.set_filename conditions, filename
    conditions.each { |key,value|
      case key
      when :confirmed_illness
        filename = "AB_#{filename}"
      when :gender
        filename = "GNDR-#{value}_#{filename}"
      when :age
        filename = "AGE-#{value}_#{filename}"
      when :grade
        filename = "GRD-#{value.to_i}_#{filename}"
      when :symptoms
        filename = "SYM-#{value.gsub("+", "_")}_#{filename}"
      when :icd9_code
        filename = "ICD9-#{value}_#{filename}"
      when :startdt
        filename = "SD-#{Time.parse(value).strftime("%s")}_#{filename}"
      when :enddt
        filename = "ED-#{Time.parse(value).strftime("%s")}_#{filename}"
      else
      end
    }
    return filename
  end

  def self.get_total_absent report_date, conditions, school_id
    condition_array = []
    string_flag      = false
    condition_array.push("")
    conditions.each{|key,value|
      if key != :symptom && key != :icd9_code && key != :startdt && key != :enddt && key != :zipcode
        condition_array[0] += " AND " if string_flag
        condition_array[0] += "#{key} = ?"
        string_flag         = true unless string_flag
        condition_array.push(value)
      end
    }
    condition_array[0] += " AND " if string_flag
    condition_array[0] += "report_date = ? AND school_id = ?"
    condition_array.push(report_date)
    condition_array.push(school_id)

    unless conditions[:icd9_code].blank?
      symptom_id   = Rollcall::Symptom.find_by_icd9_code(conditions[:icd9_code]).id
      join_string  = "INNER JOIN rollcall_student_reported_symptoms ON
                     rollcall_student_daily_infos.id = rollcall_student_reported_symptoms.student_daily_info_id AND
                     rollcall_student_reported_symptoms.symptom_id = #{symptom_id}"
      total_absent = Rollcall::StudentDailyInfo.find(:all, :include => :student_reported_symptoms, :joins => join_string, :conditions => condition_array).size

    else
      total_absent = Rollcall::StudentDailyInfo.find(:all, :conditions => condition_array).size
    end

    return total_absent
  end

  def self.get_random_color
    alpha          = ["A","B","C","D","E","F"]
    numeric        = ["0","1","2","3","4","5","6","7","8","9"]
    alpha_numeric  = [alpha,numeric]
    color          = ""
    (0..5).each do
      alpha_or_numeric = rand(2)
      color           += alpha_numeric[alpha_or_numeric][rand(alpha_numeric[alpha_or_numeric].length)]
    end
    return color
  end
end
