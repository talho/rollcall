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
    test_data_date = Time.parse("11/22/2010")
    start_date     = params['startdt_'+param_switch].index('...') ? test_data_date : Time.parse(params['startdt_'+param_switch])
    end_date       = params['enddt_'+param_switch].index('...') ? Time.now : Time.parse(params['enddt_'+param_switch]) + 1.day
    image_paths    = []
    rrd_ids        = []
    rrd_image_path = Dir.pwd << "/public/rrd/"
    rrd_path       = Dir.pwd << "/rrd/"
    rrd_tool       = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
      YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
    end
    unless params['results'].blank?
      unless params['results']['schools'].blank?
        params['results']['schools'].split(',').each do |rec|
          tea_id         = rec.to_i
          filename       = "#{tea_id}_absenteeism"
          rrd_result     = reduce_rrd(params, filename)
          rrd_file       = rrd_result[:file_name]
          rrd_id         = rrd_result[:id]
          image_file     = rrd_file.gsub(".rrd",".png")
          school_name    = Rollcall::School.find_by_tea_id(tea_id).display_name.gsub(" ", "_")
          graph_title    = "Absenteeism Rate for #{school_name}"
          unless params['symptoms_'+param_switch].blank?
            if params['symptoms_'+param_switch].index("...").blank?
              graph_title = "Absenteeism Rate for #{school_name} based on #{params['symptoms_'+param_switch]}"
            end
          end
          File.delete("#{rrd_image_path}#{image_file}") if File.exist?("#{rrd_image_path}#{image_file}")
          RRD.send_later(:graph,
            "#{rrd_path}#{rrd_file}","#{rrd_image_path}#{image_file}",
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
          image_paths.push(:value => "/rrd/#{image_file}")
          rrd_ids.push(:value => rrd_id)
        end
      end
    end
    return {
      :rrd_ids => rrd_ids,
      :image_urls => image_paths
    }
  end

  def self.render_saved_graphs saved_queries
    image_urls = []
    unless saved_queries.blank?
      saved_queries.each do |query|
        query_params   = query.query_params.split("|")
        rrd_image_path = Dir.pwd << "/public/rrd/"
        rrd_path       = Dir.pwd << "/rrd/"
        params         = {}
        rrd_tool       = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
          YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
        end
        query_params.each do |param|
          params["#{param.split('=')[0]}"] = param.split('=')[1]
        end
        
        test_data_date = Time.parse("11/22/2010")
        start_date     = params['startdt'].blank? ? test_data_date : Time.parse(params['startdt'])
        end_date       = params['enddt'].blank? ? Time.now : Time.parse(params['enddt']) + 1.day
        tea_id         = params['tea_id']
        rrd_file       = find(:all, :conditions => ['id LIKE ?', "#{query.rrd_id}"]).first.file_name
        image_file     = rrd_file.gsub(".rrd", ".png")
        school_name    = Rollcall::School.find_by_tea_id(tea_id).display_name.gsub(" ", "_")
        graph_title    = "Absenteeism Rate for #{school_name}"
        unless params['symptoms'].blank?
          graph_title = "Absenteeism Rate for #{school_name} based on #{params['symptoms_'+param_switch]}"
        end
        File.delete("#{rrd_image_path}#{image_file}") if File.exist?("#{rrd_image_path}#{image_file}")
        RRD.send_later(:graph,
          "#{rrd_path}#{rrd_file}","#{rrd_image_path}#{image_file}",
          {
            :start      => start_date,
            :end        => end_date,
            :width      => 500,
            :height     => 120,
            :image_type => "PNG",
            :title      => graph_title,
            :vlabel     => "percent absent",
            :lowerlimit => 0,
            :defs       => self.build_defs({}, {}),
            :elements   => self.build_elements({}, {})
          }, "#{rrd_tool}")
        image_urls.push("/rrd/#{image_file}")
      end
    end
    return {
      :image_urls => image_urls
    }
  end

  def self.export_rrd_data params
    initial_result = search params
    if params[:adv] == 'true'
      param_switch = 'adv'
    else
      param_switch = 'simple'
    end
    test_data_date = Time.parse("11/22/2010")
    start_date = params['startdt_'+param_switch].index('...') ? test_data_date : Time.parse(params['startdt_'+param_switch])
    end_date   = params['enddt_'+param_switch].index('...') ? Time.now : Time.parse(params['enddt_'+param_switch])

    conditions = {}
    params.each { |key,value|
      case key
      when "absent_simple", "absent_adv"
        if value == "Confirmed+Illness" || value == "Confirmed Illness"
          conditions[:confirmed_illness] = true
        end
      when "gender_adv"
        if value == "Male"
          conditions[:gender] = true
        elsif value == "Female"
          conditions[:gender] = false
        end
      when "startdt_simple", "startdt_adv"
        if value.index('...').blank?
          conditions[:startdt] = value
        end
      when "enddt_simple", "enddt_adv"
        if value.index('...').blank?
          conditions[:enddt] = value
        end
      else
      end
    }
    @csv_data = "School Name,TEA ID,Total Absent,Total Enrolled,Report Date\n"
    initial_result.each do |rec|
      days = ((end_date - start_date) / 86400)
      (0..days).each do |i|
        report_date    = start_date + i.days
        unless conditions[:confirmed_illness].blank?
          total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date_and_confirmed_illness(rec.id, report_date, true).size
        else
          total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date(rec.id, report_date).size
        end
        total_enrolled = Rollcall::SchoolDailyInfo.find_by_report_date_and_school_id(report_date, rec.id).total_enrolled
        @csv_data      = "#{@csv_data}#{rec.display_name},#{rec.tea_id},#{total_absent},#{total_enrolled},#{report_date}\n"
      end
    end
    return @csv_data
  end

  private

  def self.build_defs options, switch
    keys    = ["a","b","c","d"]
    ds_name = ["Absent", "Enrolled"]
    defs    = []
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
    tea_id        = filename
    conditions    = {}
    rrd_file_name = nil
    rrd_id        = nil

    options.each { |key,value|
      case key
      when "absent_simple", "absent_adv"
        if value == "Confirmed+Illness"
          filename = "AB_#{filename}"
          conditions[:confirmed_illness] = true
        end
      when "gender_adv"
        if value == "Male"
          conditions[:gender] = true
          filename = "G-#{conditions[:gender]}_#{filename}"
        elsif value == "Female"
          conditions[:gender] = false
          filename = "G-#{conditions[:gender]}_#{filename}"
        end        
      when "startdt_simple", "startdt_adv"
        if value.index('...').blank?
          conditions[:startdt] = value
          filename = "SD-#{Time.parse(conditions[:startdt]).strftime("%s")}_#{filename}"
        end
      when "enddt_simple", "enddt_adv"
        if value.index('...').blank?
          conditions[:enddt] = value
          filename = "ED-#{Time.parse(conditions[:enddt]).strftime("%s")}_#{filename}"
        end
      else
      end
    }
    results = find(:all, :conditions => ['file_name LIKE ?', "#{filename}.rrd"]).first
    if results.blank?
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

        RRD.create "#{rrd_path}#{filename}.rrd",
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
        } , "#{rrd_tool}"

        school_id  = Rollcall::School.find_by_tea_id(tea_id).id
        #Walk through AbsenteeData model and RRD.update on time range using :conditions variable
        unless conditions[:startdt].blank? && conditions[:enddt].blank?
          start_date = Time.parse(conditions[:startdt])
          end_date   = Time.parse(conditions[:enddt]) + 1.day
        else
          start_date = Time.parse("11/22/2010")
          end_date   = Time.now
        end
        days = ((end_date - start_date) / 86400)
        (0..days).each do |i|
          report_date = start_date + i.days
          unless conditions[:confirmed_illness].blank?
            total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date_and_confirmed_illness(school_id, report_date, true).size
          else
            total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date(school_id, report_date).size
          end
          begin
            total_enrolled = Rollcall::SchoolDailyInfo.find_by_report_date_and_school_id(report_date, school_id).total_enrolled
            RRD.update "#{rrd_path}#{filename}.rrd",[report_date.to_i.to_s,total_absent, total_enrolled],"#{rrd_tool}"
          rescue
          end
        end
        create_results = create :file_name => "#{filename}.rrd"
        rrd_id         = create_results.object_id
        rrd_file_name  = create_results.file_name
      end
    else
      rrd_id        = results.id
      rrd_file_name = results.file_name
    end
    return {
      :id        => rrd_id,
      :file_name => rrd_file_name
    }
  end
end