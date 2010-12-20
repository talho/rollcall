# == Schema Information
#
# Table name: absentee_reports
#
#  id          :integer(4)      not null, primary key
#  school_id   :integer(4)
#  report_date :date
#  enrolled    :integer(4)
#  absent      :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#
require 'fastercsv'
  
class Rollcall::AbsenteeReport < Rollcall::Base
  
  SEVERITY = {
    :low    => {:min => 0.11000, :max => 0.14000},
    :medium => {:min => 0.14000, :max => 0.25000},
    :high   => {:min => 0.25000, :max => 1.000},
  }
  belongs_to :school, :class_name => "Rollcall::School"
  has_one :district, :through => :school

  named_scope :for_date, lambda{|date|
    {:conditions => {:report_date => date}}
  }
  named_scope :for_date_range, lambda{ |start, finish|
    {
      :conditions => ["report_date >= ? and report_date <= ?", start, finish],
      :order      => "report_date desc"
    }
  }
  named_scope :recent, lambda{|limit| {:limit => limit, :order => "report_date DESC"}}
  named_scope :recent_alerts_by_severity, lambda{|limit|
    {
      :limit      => limit.to_i,
      :conditions => "(absent/enrolled) >= #{SEVERITY[:low][:min]}",
      :order      => "(absent/enrolled) DESC"
    }
  }
  named_scope :absenses, lambda{{:conditions => ['absentee_reports.absent / absentee_reports.enrolled >= .11']}}
  named_scope :with_severity, lambda{|severity|
    range = SEVERITY[severity]
    { :conditions => ["(absent / enrolled) >= ? and (absent / enrolled) < ?", range[:min], range[:max]] }
  }

  set_table_name'rollcall_absentee_reports'

  def absentee_percentage
    ((absent.to_f / enrolled.to_f) * 100).to_f.round(2)
  end

  def severity
    return "low" if absentee_percentage >= (SEVERITY[:low][:min]*100) && absentee_percentage < (SEVERITY[:low][:max]*100)
    return "medium" if absentee_percentage >= (SEVERITY[:medium][:min]*100) && absentee_percentage < (SEVERITY[:medium][:max]*100)
    return "high" if absentee_percentage >= (SEVERITY[:high][:min]*100)
  end

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
          tea_id      = rec.to_i
          filename    = "#{tea_id}_absenteeism"
          rrd_file    = reduce_rrd(params, filename)
          #rrd_path    = Dir.pwd << "/rrd/"
          #rrd_file    = "#{rrd_path}#{filename}.rrd"
          school_name = Rollcall::School.find_by_tea_id(tea_id).display_name.gsub(" ", "_")

          total_enrolled = (2..5).to_a[rand((2..5).to_a.length - 1)] * 100
          graph_title = "Absenteeism Rate for #{school_name}"

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
    rrd_tool = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
      YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
    end
    results = Crack::XML.parse(RRD.xport("#{params["tea_id"]}_absenteeism.rrd", "#{rrd_tool}"))

    csv_data = FasterCSV.generate do |csv|
      csv << [
        "Absent",
        "Enrolled",
        "001",
        "002",
        "003",
        "004",
        "005",
        "006",
        "007",
        "008",
        "009",
        "010",
        "Male",
        "Female"
      ]
    end
    csv_data
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
    conditions = {}

    if options[:adv]
      options.delete_if{|key,value| key[-7,7] == "_simple"}
    else
      options.delete_if{|key,value| key[-4,4] == "_adv"}
    end

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
      else
      end
    }

    rrd_path = Dir.pwd << "/rrd/"
    unless conditions.blank?
      rrd_tool = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
        YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
      end
      RRD.create("#{rrd_path}#{filename}.rrd",
      {
        :step  => 24.hours.seconds,
        :start => (Time.now - 60.days).to_i,
        :ds    => [
          {
            :name => "Enrolled", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
          },
          {
            :name => "Absent", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
          }
        ],
        :rra => [{
          :type => "AVERAGE", :xff => 0.5, :steps => 1, :rows => 366
        },{
          :type => "MAX", :xff => 0.5, :steps => 1, :rows => 366
        },{
          :type => "LAST", :xff => 0.5, :steps => 1, :rows => 366
        }]
      } , "#{rrd_tool}")
    end
    
    #Walk through AbsenteeData model and RRD.update on time range using :conditions variable
    (1..60).reverse_each do |i|
      report_date = Date.today - i.days
      report_time = Time.now - i.days
      total_absent = Rollcall::StudentDailyInfo.find_all_by_report_date(report_date, :conditions => conditions).size
      sdi = Rollcall::SchoolDailyInfo.find_by_report_date(report_date)
      if(sdi)
        total_enrolled = sdi.total_enrolled
        RRD.update("#{rrd_path}#{filename}.rrd", [report_time.to_i.to_s,total_absent, total_enrolled], "#{rrd_tool}")
      end
    end
    "#{rrd_path}#{filename}.rrd"
  end
end