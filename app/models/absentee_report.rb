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

class AbsenteeReport < ActiveRecord::Base
  SEVERITY = {
      :low => {:min => 0.11000, :max => 0.14000},
      :medium => {:min => 0.14000, :max => 0.25000},
      :high => {:min => 0.25000, :max => 1.000},
      }
  belongs_to :school
  has_one :district, :through => :school

  named_scope :for_date, lambda{ |date|
    {
        :conditions => {:report_date => date}
    }
  }
  named_scope :for_date_range, lambda{ |start, finish|
    {
        :conditions => ["report_date >= ? and report_date <= ?", start, finish],
        :order => "report_date desc"
    }
  }
  named_scope :recent, lambda{|limit| {:limit => limit, :order => "report_date DESC"}}
  named_scope :recent_alerts_by_severity, lambda{|limit| {
      :limit => limit.to_i,
      :conditions => "(absent/enrolled) >= #{SEVERITY[:low][:min]}",
      :order => "(absent/enrolled) DESC"}}

  named_scope :absenses, lambda{{:conditions => ['absentee_reports.absent / absentee_reports.enrolled >= .11']}}
  named_scope :with_severity, lambda{|severity|
    range=SEVERITY[severity]
    { :conditions => ["(absent / enrolled) >= ? and (absent / enrolled) < ?", range[:min], range[:max]]
    }}

  def absentee_percentage
    ((absent.to_f / enrolled.to_f) * 100).to_f.round(2)
  end

  def severity
    return "low" if absentee_percentage >= (SEVERITY[:low][:min]*100) && absentee_percentage < (SEVERITY[:low][:max]*100)
    return "medium" if absentee_percentage >= (SEVERITY[:medium][:min]*100) && absentee_percentage < (SEVERITY[:medium][:max]*100)
    return "high" if absentee_percentage >= (SEVERITY[:high][:min]*100)
  end

  def self.render_graphs params
    if params[:adv] == 'true'
      param_switch = 'adv'
    else
      param_switch = 'simple'
    end

    school_name = params['school_'+param_switch].index('...').blank? ? CGI::unescape(params['school_'+param_switch]) : ""
    school_type = params['school_type_'+param_switch].index('...').blank? ? CGI::unescape(params['school_type_'+param_switch]) : ""
    schools     = School.search("#{school_name}").concat(School.search("#{school_type}"))
    schools.concat(School.search("#{params['zip_'+param_switch]}")) unless params['zip_'+param_switch].blank?

    options        = {:page => params[:page] || 1, :per_page => params[:limit] || 6}
    schools_uniq   = schools.uniq.map {|v| (schools-[v]).size < (schools.size - 1) ? v : nil}.compact
    schools_uniq   = schools_uniq.blank? ? schools.paginate(options) : schools_uniq.paginate(options)
    start_date     = params['startdt_'+param_switch].index('...').blank? ? Time.local(params['startdt_'+param_switch]) : Time.now - 60.days
    end_date       = params['enddt_'+param_switch].index('...').blank? ? Time.local(params['enddt_'+param_switch]) : Time.now
    image_names    = []
    rrd_path       = Dir.pwd << "/rrd/"
    rrd_image_path = Dir.pwd << "/public/rrd/"
    rrd_tool       = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
      YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
    end

    schools_uniq.each do |school|
      school_name    = school.display_name.gsub(" ", "_")
      tea_id  = school.tea_id
      #build_rrd rrd_path, rrd_tool, params, school_name unless File.exists?("#{rrd_path}#{school_name}_absenteeism.rrd")
      total_enrolled = (2..5).to_a[rand((2..5).to_a.length - 1)] * 100
      graph_title = "Absenteeism Rate for #{school_name}"

      unless params['symptoms_'+param_switch].blank?
        if params['symptoms_'+param_switch].index("...").blank?
          graph_title = "Absenteeism Rate for #{school_name} based on #{params['symptoms_'+param_switch]}"
        end
      end

      File.delete("#{rrd_image_path}school_absenteeism_#{tea_id}.png") if File.exist?("#{rrd_image_path}school_absenteeism_#{tea_id}.png")

      RRD.send_later(:graph,
        "#{rrd_path}#{tea_id}_absenteeism.rrd","#{rrd_image_path}school_absenteeism_#{tea_id}.png",
        {
          :start      => start_date,
          :end        => end_date,
          :width      => 500,
          :height     => 120,
          :image_type => "PNG",
          :title      => graph_title,
          :vlabel     => "percent absent",
          :lowerlimit => 0,
          :defs       => self.build_defs(params, param_switch),
          :elements   => self.build_elements(params, param_switch)
        }, "#{rrd_tool}")

      image_names.push(:value => "/rrd/school_absenteeism_#{tea_id}.png")

    end
    return image_names
  end

  private
  #These methods are used to construct data dynamically, all these methods will
  #be removed as we continue to refine the RDD process.  There are no plans to
  #preserve this code, it is being used to build fake data.
  def self.build_fake_data report_date, total_enrolled, total_absent, confirmed
    data_array = []
    data_array.push(report_date);
    data_array.push(total_enrolled);
    data_array.push(total_absent);
    totaled = 0;
    for i in 0..9
      ds_value = (0..(total_absent - totaled)).to_a[rand((0..(total_absent - totaled)).to_a.length - 1)]
      totaled += ds_value
      data_array.push(ds_value)
    end
    if confirmed
      data_array[2] = totaled
    end
    gender = total_absent/2
    data_array.push(gender)
    data_array.push(total_absent - gender)
    return data_array
  end

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
        :cf      => "AVERAGE",
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
end
