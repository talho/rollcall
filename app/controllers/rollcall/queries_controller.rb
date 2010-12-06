class Rollcall::QueriesController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required

  def get_options
    @absenteeism = [
      {:id => 0, :value => 'Gross'},
      {:id => 1, :value => 'Confirmed Illness'}
    ]
    @age = [
      {:id => 0, :value => '3-4'},
      {:id => 1, :value => '5-6'},
      {:id => 2, :value => '7-8'},
      {:id => 3, :value => '9-10'},
      {:id => 4, :value => '11-12'},
      {:id => 5, :value => '13-14'},
      {:id => 6, :value => '15-16'},
      {:id => 7, :value => '17-18'}
    ]
    @gender = [
      {:id => 0, :value => 'Male'},
      {:id => 1, :value => 'Female'}
    ]
    @grade = [
      {:id => 0, :value => 'Kindergarten (Pre-K)'},
      {:id => 1, :value => '1st Grade'},
      {:id => 2, :value => '2nd Grade'},
      {:id => 3, :value => '3rd Grade'},
      {:id => 4, :value => '4th Grade'},
      {:id => 5, :value => '5th Grade'},
      {:id => 6, :value => '6th Grade'},
      {:id => 7, :value => '7th Grade'},
      {:id => 8, :value => '8th Grade'},
      {:id => 9, :value => '9th Grade'},
      {:id => 10,:value => '10th Grade'},
      {:id => 11,:value => '11th Grade'},
      {:id => 12,:value => '12th Grade'}
    ]
    @symptons = [
      {:id => 0, :value => 'Temperature'},
      {:id => 1, :value => 'Lethargy'},
      {:id => 2, :value => 'Sore Throat'},
      {:id => 3, :value => 'Congestion'},
      {:id => 4, :value => 'Diarrhea'},
      {:id => 5, :value => 'Headache'},
      {:id => 6, :value => 'Cough'},
      {:id => 7, :value => 'Body Ache'},
      {:id => 8, :value => 'Vomiting'},
      {:id => 9, :value => 'Rhinorrhea'}
    ]
    @temperature = [
      {:id => 0, :value => '98 - 99'},
      {:id => 1, :value => '100'},
      {:id => 2, :value => '101'},
      {:id => 3, :value => '102'},
      {:id => 4, :value => '103'},
      {:id => 5, :value => '104'},
      {:id => 6, :value => '105'},
      {:id => 7, :value => '106'},
      {:id => 8, :value => '107'},
      {:id => 9, :value => '108'}
    ]
    @data_functions = if params[:type] == 'simple' || params[:type].blank?
      [
        {:id => 0, :value => 'Raw'},
        {:id => 1, :value => 'Average'},
        {:id => 2, :value => 'Standard Deviation'}
      ]
    elsif params[:type] == 'advanced'
      [
        {:id => 0, :value => 'Raw'},
        {:id => 1, :value => 'Average'},
        {:id => 2, :value => 'Moving Average 30 Day'},
        {:id => 3, :value => 'Moving Average 60 Day'},
        {:id => 4, :value => 'Standard Deviation'},
        {:id => 5, :value => 'Cusum'}
      ]
    end
    @schools     = current_user.schools(:order => "display_name")
    @zipcode     = @schools.map{|s| s.postal_code}.uniq.each_with_index.map{|sc, index| {:id => index, :value => sc}}
    @school_type = @schools.map{|s| s.school_type}.uniq.each_with_index.map{|sc, index| {:id => index, :value => sc}}
    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :options => [
            {:absenteeism    => @absenteeism.as_json},
            {:age            => @age.as_json},
            {:data_functions => @data_functions.as_json},
            {:gender         => @gender.as_json},
            {:grade          => @grade.as_json},
            {:school_type    => @school_type.as_json},
            {:schools        => @schools.as_json},
            {:symptons       => @symptons.as_json},
            {:temperature    => @temperature.as_json},
            {:zipcode        => @zipcode.as_json}
          ]
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

  def search
    if params[:adv] == 'true'
      param_switch = 'adv'
    else
      param_switch = 'simple'
    end

    school_name = params['school_'+param_switch].index('...').blank? ? CGI::unescape(params['school_'+param_switch]) : ""
    school_type = params['school_type_'+param_switch].index('...').blank? ? CGI::unescape(params['school_type_'+param_switch]) : ""
    schools     = School.search("#{school_name}").concat(School.search("#{school_type}"))
    schools.concat(School.search("#{params['zip_'+param_switch]}")) unless params['zip_'+param_switch].blank?


    options = {:page => params[:page] || 1, :per_page => params[:limit] || 6}
    
    @schools = schools.uniq.map {|v| (schools-[v]).size < (schools.size - 1) ? v : nil}.compact
    @school_length = @schools.blank? ? schools.length : @schools.length
    @schools = @schools.blank? ? schools.paginate(options) : @schools.paginate(options)
    
    rrd_path = Dir.pwd << "/rrd/"
    rrd_tool =  if RAILS_ENV=="development"
      "/opt/local/bin/rrdtool"
    else
      "rrdtool"
    end

    rrd_image_path = Dir.pwd << "/public/rrd/"
    @image_names = []
    @alpha = ["A","B","C","D","E","F"]
    @numeric = ["0","1","2","3","4","5","6","7","8","9"]
    @alpha_numeric = [@alpha,@numeric]

    @schools.each do |school, index|
      school_name = school.display_name.gsub(" ", "_")
      school_color_a = ""
      school_color_b = ""
      for c in 0..5
        alpha_or_numeric = rand(2)
        school_color_a += @alpha_numeric[alpha_or_numeric][rand(@alpha_numeric[alpha_or_numeric].length)]
      end
      for c in 0..5
        alpha_or_numeric = rand(2)
        school_color_b += @alpha_numeric[alpha_or_numeric][rand(@alpha_numeric[alpha_or_numeric].length)]
      end
      build_rrd rrd_path, rrd_tool, params, school_name unless File.exists?("#{rrd_path}#{school_name}_absenteeism.rrd")
      @result_set = []
      @total_enrolled = (2..5).to_a[rand((2..5).to_a.length - 1)] * 100
      @fake_data = "temperature:100,lethargy:10,sore_throat:21,congestion:8,diarrhea:2,headache:34,cough:5,body_aches:6,vomiting:2,rhinorrhea:11"
      for i in 0..29
        @total_absent = (20..150).to_a[rand((20..150).to_a.length - 1)]
        @report_date = Time.local(2010,Time.now().strftime("%b").downcase,(i + 1),0,0)
        @absentee_rate = (@total_absent / @total_enrolled) * 100
        unless params['symptoms_'+param_switch].blank?
          if params['symptoms_'+param_switch].index("...").blank?
            @symptom = params['symptoms_'+param_switch]
            @fake_data.split(",").each do |data|
              if data.split(":").first == @symptom.downcase.gsub(" ","_")
                @total_absent = data.split(":").last.to_i
              end
            end
          end  
        end
        RRD.send_later(:update, "#{rrd_path}#{school_name}_absenteeism.rrd", [@report_date.to_i.to_s,@total_absent, @total_enrolled], "#{rrd_tool}")
      end
      @graph_title = "Absenteeism Rate for #{school_name}"
      unless params['symptoms_'+param_switch].blank?
        if params['symptoms_'+param_switch].index("...").blank?
          @graph_title = "Absenteeism Rate for #{school_name} based on #{params['symptoms_'+param_switch]}"
        end   
      end

      File.delete("#{rrd_image_path}school_absenteeism_#{school_name}.png") if File.exist?("#{rrd_image_path}school_absenteeism_#{school_name}.png")

      RRD.send_later(:graph, 
        "#{rrd_path}#{school_name}_absenteeism.rrd","#{rrd_image_path}school_absenteeism_#{school_name}.png",
        {
          :start      => Time.local(2010,"aug",1,0,0),
          :end        => Time.local(2011,"sep",30,23,59),
          :width      => 500,
          :height     => 120,
          :image_type => "PNG",
          :title      => @graph_title,
          :vlabel     => "percent absent",
          :lowerlimit => 0,
          :defs       => [{
            :key     => "a",
            :cf      => "AVERAGE",
            :ds_name => "Absent"
          },{
            :key     => "b",
            :cf      => "AVERAGE",
            :ds_name => "Enrolled"
          }],
          :elements   => [{
            :key     => "a",
            :element => "AREA",
            :color   => school_color_a,
            :text    => "Total Enrolled"
          },{
            :key     => "b",
            :element => "LINE1",
            :color   => school_color_b,
            :text    => "Total Absent"
          }]
        }, "#{rrd_tool}")

      @image_names.push(
        :value => "/rrd/school_absenteeism_#{school_name}.png"
      )
    end
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => @school_length,
          :results       => @image_names.as_json
        }
      end
    end
  end

  private

  def build_rrd(rrd_path,rrd_tool,params, school_name)
    RRD.create("#{rrd_path}#{school_name}_absenteeism.rrd",
      {
        :step  => 24.hours.seconds,
        :start => Time.local(2010,"aug",1,0,0).to_i,
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
    return true
  end
end