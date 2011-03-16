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
      graph_title    = "Gross Absenteeism Rate for #{school_name}"
    else
      graph_title    = "Confirmed Absenteeism Rate for #{school_name}"
    end

    unless params[:symptoms].blank?
      if params[:symptoms].index("...").blank?
        graph_title = "Absenteeism Rate for #{school_name} based on #{params[:symptoms]}"
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
        graph_title = "Absenteeism Rate for #{school_name}"
        unless params[:symptoms].blank?
          graph_title = "Absenteeism Rate for #{school_name} based on #{params[:symptoms]}"
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
    initial_result = Rollcall::School.search params
    test_data_date = Time.parse("11/22/2010")
    start_date     = params[:startdt].index('...') ? test_data_date : Time.parse(params[:startdt])
    end_date       = params[:enddt].index('...') ? Time.now : Time.parse(params[:enddt])
    conditions     = set_conditions params
    @csv_data      = "School Name,TEA ID,Total Absent,Total Enrolled,Report Date\n"
    initial_result.each do |rec|
      days = ((end_date - start_date) / 86400)
      (0..days).each do |i|
        report_date = start_date + i.days
        school_info = Rollcall::SchoolDailyInfo.find_by_report_date_and_school_id(report_date, rec.id)
        unless school_info.blank?
          total_enrolled = school_info.total_enrolled
          total_absent   = get_total_absent report_date, conditions, rec.id
          @csv_data      = "#{@csv_data}#{rec.display_name},#{rec.tea_id},#{total_absent},#{total_enrolled},#{report_date}\n"
        end
      end
    end
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
    #File.delete("#{rrd_image_path}#{image_file}") if File.exist?("#{rrd_image_path}#{image_file}")
    return RRD.graph(
      "#{rrd_path}#{rrd_file}","#{rrd_image_path}#{image_file}",
      {
        :start      => start_date,
        :end        => end_date,
        :step       => 24.hours.seconds,
        :width      => 500,
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

  def self.build_defs options
    defs = []
    defs.push({
      :key     => "a",
      :cf      => "LAST",
      :ds_name => "Absent"
    })
    if options[:enrolled_base_line] == "on"
      defs.push({
        :key     => "b",
        :cf      => "LAST",
        :ds_name => "Enrolled"
      })
    end
    return defs
  end

  def self.build_cdefs options
    cdefs   = []
    if options[:data_func] == "Standard+Deviation"
      cdefs.push({
        :key     => 'a',
        :new_key => 'avg',
        :rpn     => ['POP','a','PREV','UN','0','PREV','IF','+']
      })
      cdefs.push({
        :key     => 'avg',
        :new_key => 'meanavg',
        :rpn     => ['COUNT','/']
      })
      cdefs.push({
        :key     => 'a',
        :new_key => 'avgdiff',
        :rpn     => ['POP','meanavg','PREV','UN','0','PREV','IF','-']
      })
      cdefs.push({
        :key     => 'avgdiff',
        :new_key => 'avgsqr',
        :rpn     => ['avgdiff','*']
      })
      cdefs.push({
        :key     => 'avgsqr',
        :new_key => 'avgsqrttl',
        :rpn     => ['POP','avgsqr','PREV','UN','0','PREV','IF','+']
      })
      cdefs.push({
        :key     => 'avgsqrttl',
        :new_key => 'avgsqrdiv',
        :rpn     => ['COUNT','/']
      })
      cdefs.push({
        :key     => 'avgsqrdiv',
        :new_key => 'msd',
        :rpn     => ['SQRT']
      })
    end
    if options[:data_func] == "Average"
      cdefs.push({
        :key     => 'a',
        :new_key => 'avg',
        :rpn     => ['POP','a','PREV','UN','0','PREV','IF','+']
      })
      cdefs.push({
        :key     => 'avg',
        :new_key => 'mavg',
        :rpn     => ['COUNT','/']
      })
    end
    return cdefs
  end

  def self.build_elements options
    elements       = []
    school_color   = get_random_color
    if options[:absent] == "Confirmed+Illness"
      absent_text = "Total Confirmed Absent"
    else
      absent_text = "Total Gross Absent"
    end 
    if options[:data_func] == "Standard+Deviation"
      elements.push({
        :key     => 'a',
        :element => "AREA",
        :color   => school_color,
        :text    => absent_text
      })
      school_color = get_random_color
      elements.push({
        :key     => 'msd',
        :element => "LINE1",
        :color   => school_color,
        :text    => "Moving Standard Deviation"
      })
    else
      if options[:data_func] == "Average"
        elements.push({
          :key     => 'a',
          :element => "AREA",
          :color   => school_color,
          :text    => absent_text
        })
        school_color = get_random_color
        elements.push({
          :key     => 'mavg',
          :element => "LINE1",
          :color   => school_color,
          :text    => "Moving Absent Average"
        })
      else
        elements.push({
          :key     => 'a',
          :element => "AREA",
          :color   => school_color,
          :text    => absent_text
        })
      end
    end
    school_color = get_random_color
    elements.push({
      :key     => 'b',
      :element => "LINE1",
      :color   => school_color,
      :text    => "Total Enrolled"
    }) if options[:enrolled_base_line] == "on"
    return elements
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
        start_date = Time.gm(2010, "sep", 01,0,0)
      end
      if !conditions[:enddt].blank?
        parsed_ed  = Time.parse(conditions[:enddt])
        end_date   = Time.gm(parsed_ed.year,parsed_ed.month,parsed_ed.day)
      else
        end_date   = Time.gm(Time.now.year, Time.now.month, Time.now.day)
      end
      days           = ((end_date - start_date) / 86400)
      total_enrolled = Rollcall::SchoolDailyInfo.find_by_school_id(school_id).total_enrolled
      (0..days).each do |i|
        report_date = start_date + i.days
        if(i == 0)
          RRD.update "#{rrd_path}#{filename}.rrd",[report_date.to_i.to_s,0,total_enrolled],"#{rrd_tool}"
        end
        if report_date.strftime("%a").downcase == "sat" || report_date.strftime("%a").downcase == "sun"        
          RRD.update("#{rrd_path}#{filename}.rrd",[(report_date + 1.day).to_i.to_s,0,total_enrolled], "#{rrd_tool}")
        else
          total_absent = get_total_absent report_date, conditions, school_id
          begin
            RRD.update "#{rrd_path}#{filename}.rrd",[(report_date + 1.day).to_i.to_s,total_absent, total_enrolled],"#{rrd_tool}"
          rescue
          end
        end
        if(i == days.to_i)
          report_date = report_date + 1.day
          RRD.update "#{rrd_path}#{filename}.rrd",[(report_date + 1.day).to_i.to_s,0,total_enrolled],"#{rrd_tool}"
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
          conditions[:gender]  = 'M' if value == "Male"
          conditions[:gender]  = 'F' if value == "Female"
        when "age"
          conditions[:age]     = value.to_i
        when "grade"
          conditions[:grade]   = value.to_i
        when "symptoms"
          conditions[:symptom] = value.gsub("+", " ")
        when "startdt"
          conditions[:startdt] = value
        when "enddt"
          conditions[:enddt]   = value
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
    condition_string = ""
    condition_array  = []
    string_flag      = false
    condition_array.push(condition_string)
    conditions.each{|key,value|
      if key != :symptom && key != :startdt && key != :enddt && key != :zipcode
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
    daily_result = Rollcall::StudentDailyInfo.find(:all, :conditions => condition_array)
    unless conditions[:symptom].blank?
      symptom_id            = Rollcall::Symptom.find_by_name(conditions[:symptom]).id
      student_symptom_count = 0
      daily_result.each do |rec|
        unless Rollcall::StudentReportedSymptoms.find_by_symptom_id_and_student_daily_info_id(symptom_id, rec.id).blank?
          student_symptom_count += 1
        end
      end
      total_absent = student_symptom_count
    else
      total_absent = daily_result.size
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
