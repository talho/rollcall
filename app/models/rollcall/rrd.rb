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
    school_name = params[:school].index('...').blank? ? CGI::unescape(params[:school]) : ""
    school_type = params[:school_type].index('...').blank? ? CGI::unescape(params[:school_type]) : ""
    schools     = Rollcall::School.search("#{school_name}").concat(Rollcall::School.search("#{school_type}"))
    schools.concat(Rollcall::School.search("#{params[:zip]}")) unless params[:zip].blank?
    schools_uniq = schools.uniq.map {|v| (schools-[v]).size < (schools.size - 1) ? v : nil}.compact
    return schools_uniq
  end

  def self.render_graphs params
    image_paths    = []
    rrd_ids        = []
    unless params[:results].blank?
      unless params[:results][:schools].blank?
        params[:results][:schools].split(',').each do |rec|
          tea_id         = rec.to_i
          filename       = "#{tea_id}_absenteeism"
          rrd_result     = reduce_rrd(params, filename)
          rrd_file       = rrd_result[:file_name]
          rrd_id         = rrd_result[:id]
          image_file     = rrd_file.gsub(".rrd", ".png")
          school_name    = Rollcall::School.find_by_tea_id(tea_id).display_name.gsub(" ", "_")
          graph_title    = "Absenteeism Rate for #{school_name}"
          unless params[:symptoms].blank?
            if params[:symptoms].index("...").blank?
              graph_title = "Absenteeism Rate for #{school_name} based on #{params[:symptoms]}"
            end
          end
          self.graph rrd_file, image_file, graph_title, params
          #rrd_image_path = Dir.pwd << "/public/rrd/"
          #File.delete("#{rrd_image_path}#{image_file}") if File.exist?("#{rrd_image_path}#{image_file}")
          #self.send_later(:graph, rrd_file, image_file, graph_title, params)
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
        params         = {}
        query_params.each do |param|
          params[:"#{param.split('=')[0]}"] = param.split('=')[1]
        end
        tea_id      = params[:tea_id]
        rrd_file    = find(:all, :conditions => ['id LIKE ?', "#{query.rrd_id}"]).first.file_name
        image_file  = rrd_file.gsub(".rrd", ".png")
        school_name = Rollcall::School.find_by_tea_id(tea_id).display_name.gsub(" ", "_")
        graph_title = "Absenteeism Rate for #{school_name}"
        unless params[:symptoms].blank?
          graph_title = "Absenteeism Rate for #{school_name} based on #{params[:symptoms]}"
        end
        self.graph rrd_file, image_file, graph_title, params
        #rrd_image_path = Dir.pwd << "/public/rrd/"
        #File.delete("#{rrd_image_path}#{image_file}") if File.exist?("#{rrd_image_path}#{image_file}")
        #self.send_later(:graph, rrd_file, image_file, graph_title, params)
        image_urls.push("/rrd/#{image_file}")
      end
    end
    return {
      :image_urls => image_urls
    }
  end

  def self.export_rrd_data params, filename, user_obj
    initial_result = search params
    test_data_date = Time.parse("11/22/2010")
    start_date     = params[:startdt].index('...') ? test_data_date : Time.parse(params[:startdt])
    end_date       = params[:enddt].index('...') ? Time.now : Time.parse(params[:enddt])
    conditions     = {}
    params.each { |key,value|
      case key
      when "absent"
        if value == "Confirmed+Illness" || value == "Confirmed Illness"
          conditions[:confirmed_illness] = true
        end
      when "gender"
        if value == "Male"
          conditions[:gender] = true
        elsif value == "Female"
          conditions[:gender] = false
        end
      when "startdt"
        if value.index('...').blank?
          conditions[:startdt] = value
        end
      when "enddt"
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
        school_info = Rollcall::SchoolDailyInfo.find_by_report_date_and_school_id(report_date, rec.id)
        unless school_info.blank?
          total_enrolled = school_info.total_enrolled
          unless conditions[:confirmed_illness].blank?
            total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date_and_confirmed_illness(rec.id, report_date, true).size
          else
            total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date(rec.id, report_date).size
          end
          @csv_data = "#{@csv_data}#{rec.display_name},#{rec.tea_id},#{total_absent},#{total_enrolled},#{report_date}\n"
        end
      end
    end
    newfile            = File.join(Rails.root,'tmp',"#{filename}.csv")
    file_result        = File.open(newfile, 'wb') {|f| f.write(@csv_data) }
    file               = File.new(newfile, "r")
    @document          = user_obj.documents.build({:folder_id => nil, :file => file})
    @document.owner_id = user_obj.id
    @document.save!
    #DocumentMailer.deliver_document_addition(@document, user_obj) if @document.folder.notify_of_document_addition
    #return @csv_data
    return true
  end

  private

  def self.graph rrd_file, image_file, graph_title, params
    test_data_date = Time.parse("08/31/2010")
    rrd_image_path = Dir.pwd << "/public/rrd/"
    rrd_path       = Dir.pwd << "/rrd/"
    rrd_tool       = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
      YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
    end
    if params[:startdt].blank? || params[:startdt].index('...')
      start_date = test_data_date
    else
      start_date = Time.parse(params[:startdt])
    end
    if params[:enddt].blank? || params[:enddt].index('...')
      end_date = Time.now
    else
      end_date = Time.parse(params[:enddt]) + 1.day
    end
    File.delete("#{rrd_image_path}#{image_file}") if File.exist?("#{rrd_image_path}#{image_file}")
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
        :vlabel     => "percent absent",
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
    alpha          = ["A","B","C","D","E","F"]
    numeric        = ["0","1","2","3","4","5","6","7","8","9"]
    alpha_numeric  = [alpha,numeric]
    school_color   = ""

    for c in 0..5
      alpha_or_numeric = rand(2)
      school_color    += alpha_numeric[alpha_or_numeric][rand(alpha_numeric[alpha_or_numeric].length)]
    end
    if options[:data_func] == "Standard+Deviation"
      elements.push({
          :key     => 'a',
          :element => "AREA",
          :color   => school_color,
          :text    => "Total Absent"
        })
        school_color = ""
        for c in 0..5
          alpha_or_numeric = rand(2)
          school_color    += alpha_numeric[alpha_or_numeric][rand(alpha_numeric[alpha_or_numeric].length)]
        end
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
          :text    => "Total Absent"
        })
        school_color = ""
        for c in 0..5
          alpha_or_numeric = rand(2)
          school_color    += alpha_numeric[alpha_or_numeric][rand(alpha_numeric[alpha_or_numeric].length)]
        end
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
          :text    => "Total Absent"
        })
        school_color = ""
        for c in 0..5
          alpha_or_numeric = rand(2)
          school_color    += alpha_numeric[alpha_or_numeric][rand(alpha_numeric[alpha_or_numeric].length)]
        end
        elements.push({
          :key     => 'b',
          :element => "LINE1",
          :color   => school_color,
          :text    => "Total Enrolled"
        }) if options[:enrolled_base_line] == "on"
      end
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
      when "absent"
        if value == "Confirmed+Illness"
          filename                       = "AB_#{filename}"
          conditions[:confirmed_illness] = true
        end
      when "gender"
        if value == "Male"
          conditions[:gender] = true
          filename            = "G-#{conditions[:gender]}_#{filename}"
        elsif value == "Female"
          conditions[:gender] = false
          filename            = "G-#{conditions[:gender]}_#{filename}"
        end        
      when "startdt"
        if value.index('...').blank?
          conditions[:startdt] = value
          filename             = "SD-#{Time.parse(conditions[:startdt]).strftime("%s")}_#{filename}"
        end
      when "enddt"
        if value.index('...').blank?
          conditions[:enddt] = value
          filename           = "ED-#{Time.parse(conditions[:enddt]).strftime("%s")}_#{filename}"
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
          start_date = Time.parse(conditions[:startdt]) - 1.day
        else
          start_date = Time.local(2010,"aug",31,0,0)
        end

        RRD.create "#{rrd_path}#{filename}.rrd",
        {
          :step  => 24.hours.seconds,
          :start => start_date.to_i,
          :ds    => [
            {
              :name => "Absent", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
            },
            {
              :name => "Enrolled", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
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
            :type => "LAST", :xff => 0, :steps => 1, :rows => 366
          }]
        } , "#{rrd_tool}"

        school_id  = Rollcall::School.find_by_tea_id(tea_id).id
        unless conditions[:startdt].blank? && conditions[:enddt].blank?
          start_date = Time.parse(conditions[:startdt])
          end_date   = Time.parse(conditions[:enddt])
        else
          start_date = Time.parse("08/31/2010")
          end_date   = Time.now
        end
        days           = ((end_date - start_date) / 86400)
        total_enrolled = Rollcall::SchoolDailyInfo.find_by_school_id(school_id).total_enrolled
        (0..days).each do |i|
          report_date = start_date + i.days
          if report_date.strftime("%a").downcase == "sat" || report_date.strftime("%a").downcase == "sun"
              #Dev Note: Running an update with a zero absent rate will show, what I feel to be, a very true
              #absent pattern in which we see dips in absentee rate on expected days such as Sat and Sunday.
              #Subsequently, RRD will average upwards of 3 days of unreported data and treat any other dates
              #beyond this threshold as unknown data points which may or not result in dips in absentee data.
              #As an example, seeing an averaged out data set between the days of thurs, friday, saturday,
              #and sunday on a 3 day week before some sort of Holiday.
              RRD.update("#{rrd_path}#{filename}.rrd",[report_date.to_i.to_s,0,total_enrolled], "#{rrd_tool}")
          else
            unless conditions[:confirmed_illness].blank?
              total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date_and_confirmed_illness(school_id, report_date, true).size
            else
              total_absent = Rollcall::StudentDailyInfo.find_all_by_school_id_and_report_date(school_id, report_date).size
            end
            begin
              RRD.update "#{rrd_path}#{filename}.rrd",[report_date.to_i.to_s,total_absent, total_enrolled],"#{rrd_tool}"
            rescue
            end
          end         
        end
        create_results = create :file_name => "#{filename}.rrd"
        rrd_id         = create_results.id
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