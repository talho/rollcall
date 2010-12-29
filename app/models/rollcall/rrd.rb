# == Schema Information
#
# Table name: rollcall_rrd
#
#  id                 :integer(4)      not null, primary key
#  saved_query_id     :integer(4)      foreign key
#  file_name          :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class Rollcall::Rrd < Rollcall::Base
  set_table_name "rollcall_rrds"

  def self.search params
    if params[:adv] == 'true'
      param_switch = 'adv'
    else
      param_switch = 'simple'
    end

    school_name = params['school_'+param_switch].index('...').blank? ? CGI::unescape(params['school_'+param_switch]) : ""
    school_type = params['school_type_'+param_switch].index('...').blank? ? CGI::unescape(params['school_type_'+param_switch]) : ""
    schools     = Rollcall::School.search("#{school_name}").concat(Rollcall::School.search("#{school_type}"))
    schools.concat(Rollcall::School.search("#{params['zip_'+param_switch]}")) unless params['zip_'+param_switch].blank?
    schools_uniq = schools.uniq.map {|v| (schools-[v]).size < (schools.size - 1) ? v : nil}.compact
    return schools_uniq
  end

  def self.render_graphs params
    if params[:adv] == 'true'
      param_switch = 'adv'
    else
      param_switch = 'simple'
    end
    start_date     = params['startdt_'+param_switch].index('...') ? Time.now - 60.days : Time.parse(params['startdt_'+param_switch])
    end_date       = params['enddt_'+param_switch].index('...') ? Time.now : Time.parse(params['enddt_'+param_switch])
    image_names    = []
    rrd_image_path = Dir.pwd << "/public/rrd/"
    rrd_tool       = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
      YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
    end

    unless params['results'].blank?
      unless params['results']['schools'].blank?
        params['results']['schools'].split(',').each do |rec|
          tea_id         = rec.to_i
          filename       = "#{tea_id}_absenteeism"
          rrd_file       = reduce_rrd(params, filename)
          school_name    = Rollcall::School.find_by_tea_id(tea_id).display_name.gsub(" ", "_")
          graph_title    = "Absenteeism Rate for #{school_name}"

          unless params['symptoms_'+param_switch].blank?
            if params['symptoms_'+param_switch].index("...").blank?
              graph_title = "Absenteeism Rate for #{school_name} based on #{params['symptoms_'+param_switch]}"
            end
          end

          File.delete("#{rrd_image_path}#{tea_id}_absenteeism.png") if File.exist?("#{rrd_image_path}#{tea_id}_absenteeism.png")

          RRD.send_later(:graph,
            rrd_file,"#{rrd_image_path}#{tea_id}_absenteeism.png",
            {
              :start      => start_date,
              :end        => end_date,
              :width      => 500,
              :height     => 120,
              :image_type => "PNG",
              :title      => graph_title,
              :vlabel     => "percent absent",
              :lowerlimit => 0,
              :defs       => self.build_defs({}, param_switch),
              :elements   => self.build_elements({}, param_switch)
            }, "#{rrd_tool}")

          image_names.push(:value => "/rrd/#{tea_id}_absenteeism.png")
        end
      end
    end
    return image_names
  end

  def self.export_rrd_data params
    initial_result = search params
    @csv_data       = nil
    if params[:adv] == 'true'
      param_switch = 'adv'
    else
      param_switch = 'simple'
    end
    start_date = params['startdt_'+param_switch].index('...') ? Time.now - 60.days : Time.parse(params['startdt_'+param_switch])
    end_date   = params['enddt_'+param_switch].index('...') ? Time.now : Time.parse(params['enddt_'+param_switch])
    initial_result.each do |rec|
      days       = end_date.day - start_date.day
      (0..days).each do |i|
        report_date    = start_date + i.days
        unless conditions[:confirmed_illness].blank?
          total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date_and_confirmed_illness(rec.id, report_date, true).size
        else
          total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date(rec.id, report_date).size
        end
        total_enrolled = Rollcall::SchoolDailyInfo.find_by_report_date(report_date).total_enrolled
        @csv_data      += "#{rec.display_name},#{rec.tea_id},#{total_absent},#{total_enrolled},#{report_date}\n"
      end
    end
    return @csv_data
  end

  private
  #These methods are used to construct data dynamically, all these methods will
  #be removed as we continue to refine the RDD process.  There are no plans to
  #preserve this code, it is being used to build fake data.

  def self.build_defs options, switch
    keys    = ["a","b","c","d"]
    ds_name = ["Absent", "Enrolled"]
    defs    = []
    unless options['symptoms_'+switch].blank?
      unless !options["symptoms_"+switch].index("...").blank?
        ds_name.push(CGI::unescape(options["symptoms_"+switch]))
      end
    end
    unless options['gender_'+switch].blank?
      unless !options["gender_"+switch].index("...").blank?
        ds_name.push(CGI::unescape(options["gender_"+switch]))
      end
    end
    for i in 0..(ds_name.length - 1)
      defs.push({
        :key     => keys[i],
        :cf      => "LAST",
        :ds_name => ds_name[i].gsub(" ","_")
      })
    end
    return defs
  end

  def self.build_elements options, switch
    keys           = ["a","b","c","d"]
    ds_name        = ["Absent", "Enrolled"]
    elements       = []
    alpha          = ["A","B","C","D","E","F"]
    numeric        = ["0","1","2","3","4","5","6","7","8","9"]
    alpha_numeric  = [alpha,numeric]
    unless options['symptoms_'+switch].blank?
      unless !options["symptoms_"+switch].index("...").blank?
        ds_name.push(CGI::unescape(options["symptoms_"+switch]))
      end
    end
    unless options['gender_'+switch].blank?
      unless !options["gender_"+switch].index("...").blank?
        ds_name.push(CGI::unescape(options["gender_"+switch]))
      end
    end

    for i in 0..(ds_name.length - 1)
      school_color = ""
      for c in 0..5
        alpha_or_numeric = rand(2)
        school_color    += alpha_numeric[alpha_or_numeric][rand(alpha_numeric[alpha_or_numeric].length)]
      end
      elements.push({
        :key     => keys[i],
        :element => keys[i] == "a" ? "AREA" : "LINE1",
        :color   => school_color,
        :text    => "Total "+ds_name[i]
      })
    end
    return elements
  end

  def self.reduce_rrd options, filename
    tea_id       = filename
    total_absent = nil
    unless options[:adv].match(/true/i).blank?
      options.delete_if{|key,value| key[-4,4] == "_simple"}
    else
      options.delete_if{|key,value| key[-7,7] == "_adv"}
    end
    conditions = {}
    options.each { |key,value|
      case key
      when "absent_simple", "absent_adv"
        if value == "Confirmed+Illness"
          filename = "AB_#{filename}"
          conditions[:confirmed_illness] = true
        end
      when "gender_adv"
        if value == "Male"
          filename = "G_#{filename}"
          conditions[:gender] = true
        elsif value == "Female"
          filename = "G_#{filename}"
          conditions[:gender] = false
        end
      when "startdt_simple", "startdt_adv"
        if value.index('...').blank?
          filename = "SD_#{filename}"
          conditions[:startdt] = value
        end
      when "enddt_simple", "enddt_adv"
        if value.index('...').blank?
          filename = "ED_#{filename}"
          conditions[:enddt] = value
        end
      else
      end
    }
    rrd_path = Dir.pwd << "/rrd/"
    unless conditions.blank?
      rrd_tool = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
        YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
      end
      unless conditions[:startdt].blank?
        start_date = Time.parse(conditions[:startdt]).to_i
      else
        start_date = Time.local(2010,"oct",1,0,0).to_i
      end
      RRD.send_later(:create, "#{rrd_path}#{filename}.rrd",
      {
        :step  => 24.hours.seconds,
        :start => start_date,
        :ds    => [
          {
            :name => "Absent", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
          },
          {
            :name => "Enrolled", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
          }
        ],
        :rra => [{
          :type => "AVERAGE", :xff => 0.5, :steps => 1, :rows => 366
        },{
          :type => "MAX", :xff => 0.5, :steps => 1, :rows => 366
        },{
          :type => "LAST", :xff => 0.5, :steps => 1, :rows => 366
        }]
      } , "#{rrd_tool}") #unless File.exists?("#{rrd_path}#{filename}.rrd")
      #Walk through AbsenteeData model and RRD.update on time range using :conditions variable
      unless conditions[:startdt].blank? && conditions[:enddt].blank?
        school_id  = Rollcall::School.find_by_tea_id(tea_id).id
        start_date = Time.parse(conditions[:startdt])
        end_date   = Time.parse(conditions[:enddt])
        days       = end_date.day - start_date.day
        (0..days).each do |i|
          report_date    = start_date + i.days
          unless conditions[:confirmed_illness].blank?
            total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date_and_confirmed_illness(school_id, report_date, true).size
          else
            total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date(school_id, report_date).size
          end
          total_enrolled = Rollcall::SchoolDailyInfo.find_by_report_date(report_date).total_enrolled
          RRD.send_later(:update,"#{rrd_path}#{filename}.rrd",[report_date.to_i.to_s,total_absent, total_enrolled],"#{rrd_tool}")
        end
      else

      end
    end
    "#{rrd_path}#{filename}.rrd"
  end
end
