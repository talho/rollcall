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

    # Search schools by passed params
    school_name = params['school_'+param_switch].index('...').blank? ? CGI::unescape(params['school_'+param_switch]) : ""
    school_type = params['school_type_'+param_switch].index('...').blank? ? CGI::unescape(params['school_type_'+param_switch]) : ""
    schools     = School.search("#{school_name}").concat(School.search("#{school_type}"))
    schools.concat(School.search("#{params['zip_'+param_switch]}")) unless params['zip_'+param_switch].blank?
    #Build school result set, and paginate
    options        = {:page => params[:page] || 1, :per_page => params[:limit] || 6}
    schools       = schools.uniq.map {|v| (schools-[v]).size < (schools.size - 1) ? v : nil}.compact
    school_length = schools.blank? ? schools.length : schools.length
    schools       = schools.blank? ? schools.paginate(options) : schools.paginate(options)

    start_date    = params['startdt_'+param_switch].index('...').blank? ? Time.local(params['startdt_'+param_switch]) : Time.now - 60.days
    end_date      = params['enddt_'+param_switch].index('...').blank? ? Time.local(params['enddt_'+param_switch]) : Time.now

    rrd_path       = Dir.pwd << "/rrd/"
    rrd_image_path = Dir.pwd << "/public/rrd/"
    rrd_tool       = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
      YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
    end

    #empty image array
    image_names   = []
    #Following arrays are used to dynamically create schools colors for graphs
    alpha         = ["A","B","C","D","E","F"]
    numeric       = ["0","1","2","3","4","5","6","7","8","9"]
    alpha_numeric = [alpha,numeric]

    #Run through the schools results and update the corresponding school rrd file with fake data
    #Graph the updated data using RRD
    #Push image names into @image_names array
    schools.each do |school, index|
      school_name = school.display_name.gsub(" ", "_")
      school_number = school.school_number
      school_color_a = ""
      school_color_b = ""
      for c in 0..5
        alpha_or_numeric = rand(2)
        school_color_a += alpha_numeric[alpha_or_numeric][rand(alpha_numeric[alpha_or_numeric].length)]
      end
      for c in 0..5
        alpha_or_numeric = rand(2)
        school_color_b += alpha_numeric[alpha_or_numeric][rand(alpha_numeric[alpha_or_numeric].length)]
      end

      graph_title = "Absenteeism Rate for #{school_name}"
      unless params['symptoms_'+param_switch].blank?
        if params['symptoms_'+param_switch].index("...").blank?
          graph_title = "Absenteeism Rate for #{school_name} based on #{params['symptoms_'+param_switch]}"
        end
      end

      File.delete("#{rrd_image_path}school_absenteeism_#{school_number}.png") if File.exist?("#{rrd_image_path}school_absenteeism_#{school_number}.png")

      RRD.send_later(:graph,
        "#{rrd_path}#{school_number}_absenteeism.rrd","#{rrd_image_path}school_absenteeism_#{school_number}.png",
        {
          :start      => start_date,
          :end        => end_date,
          :width      => 500,
          :height     => 120,
          :image_type => "PNG",
          :title      => graph_title,
          :vlabel     => "percent absent",
          :lowerlimit => 0,
          :defs       => [{
            :key     => "a",
            :cf      => "LAST",
            :ds_name => "Absent"
          },{
            :key     => "b",
            :cf      => "LAST",
            :ds_name => "Enrolled"
          }],
          :elements   => [{
            :key     => "a",
            :element => "AREA",
            :color   => school_color_a,
            :text    => "Total Absent"
          },{
            :key     => "b",
            :element => "LINE1",
            :color   => school_color_b,
            :text    => "Total Enrolled"
          }]
        }, "#{rrd_tool}")

      image_names.push(:value => "/rrd/school_absenteeism_#{school_number}.png")
    end
    image_names
  end
end
