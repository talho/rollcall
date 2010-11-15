class Rollcall::QueriesController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required

  def get_options
    @absenteeism_options = [
      {:id => 1, :value => 'Gross'},
      {:id => 2, :value => 'Confirmed Illness'}
    ]
    @age = [
      {:id => 1, :value => '3-4'},
      {:id => 2, :value => '5-6'},
      {:id => 3, :value => '7-8'},
      {:id => 4, :value => '9-10'},
      {:id => 5, :value => '11-12'},
      {:id => 6, :value => '13-14'},
      {:id => 7, :value => '15-16'},
      {:id => 8, :value => '17-18'}
    ]
    @gender = [
      {:id => 1, :value => 'Male'},
      {:id => 2, :value => 'Female'}  
    ]
    @grade = [
      {:id => 1, :value => 'Kindergarden'},
      {:id => 2, :value => '1st Grade'},
      {:id => 3, :value => '2nd Grade'},
      {:id => 4, :value => '3rd Grade'},
      {:id => 5, :value => '4th Grade'},
      {:id => 6, :value => '5th Grade'},
      {:id => 7, :value => '6th Grade'},
      {:id => 8, :value => '7th Grade'},
      {:id => 9, :value => '8th Grade'},
      {:id => 10,:value => '9th Grade'},
      {:id => 11,:value => '10th Grade'},
      {:id => 12,:value => '11th Grade'},
      {:id => 13,:value => '12th Grade'}  
    ]
    @symptons = [
      {:id => 1, :value => 'High Fever'},
      {:id => 2, :value => 'Nausea'},
      {:id => 3, :value => 'Headache'},
      {:id => 4, :value => 'Extreme Headache'}  
    ]
    @temperature = [
      {:id => 1, :value => '98 - 99'},
      {:id => 2, :value => '100'},
      {:id => 3, :value => '101'},
      {:id => 4, :value => '102'},
      {:id => 5, :value => '103'},
      {:id => 6, :value => '104'},
      {:id => 7, :value => '105'},
      {:id => 8, :value => '106'},
      {:id => 9, :value => '107'},
      {:id => 10,:value => '108'}  
    ]
    @zipcode = [
      {:id => 1, :value => '77007'},
      {:id => 2, :value => '77001'},
      {:id => 3, :value => '77559'},
      {:id => 4, :value => '77076'}
    ]
    @data_functions = [
      {:id => 1, :value => 'Raw'},
      {:id => 2, :value => 'Average'},
      {:id => 3, :value => 'Standard Deviation'}
    ] if params[:type] == 'simple' || params[:type].blank?
    @data_functions = [
      {:id => 1, :value => 'Raw'},
      {:id => 2, :value => 'Average'},
      {:id => 3, :value => 'Moving Average 30 Day'},
      {:id => 4, :value => 'Moving Average 60 Day'},
      {:id => 5, :value => 'Standard Deviation'},
      {:id => 6, :value => 'Cusum'}
    ] if params[:type] == 'advanced'
    @school_type_options = [
      {:id => 1, :value => 'Elementary'},
      {:id => 2, :value => 'High School'}
    ]
    @schools = current_user.schools(:order => "display_name")

    respond_to do |format|
      format.json do
        original_included_root = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        render :json => {
          :options => [
            {:absenteeism    => @absenteeism_options.as_json},
            {:data_functions => @data_functions.as_json},
            {:school_type    => @school_type_options.as_json},
            {:schools        => @schools.as_json}
          ]
        }
        ActiveRecord::Base.include_root_in_json = original_included_root
      end
    end
  end

  def search
    rrd_path = Dir.pwd << "/rrd/"
    rrd_tool =  if RAILS_ENV=="development"
      "/opt/local/bin/rrdtool"
    else
      "rrdtool"
    end
    rrd_image_path = Dir.pwd << "/public/rrd/"

    RRD.create("#{rrd_path}school_absenteeism.rrd",
      {
        :step => 24.hours.seconds,
        :start => Time.local(2010,"aug",1,0,0).to_i,
        :ds => [
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
    @result_set = build_fake_data

    @result_set = build_fake_data
    @result_set.each do |rec|
      RRD.update("#{rrd_path}school_absenteeism.rrd", [rec[:date],rec[:absent], rec[:total]], "#{rrd_tool}")      
    end

    @cmd = RRD.graph("#{rrd_path}school_absenteeism.rrd","#{rrd_image_path}school_absenteeism_woodson.png",
      {
        #:ago => Time.now.advance(:hours => -12),
        :start => Time.local(2010,"aug",1,0,0),
        :end   => Time.local(2011,"sep",30,23,59),
        :width => 500,
        :height => 120,
        :image_type => "PNG",
        :title => "Absenteeism Rate for Woodson Middle School",
        :defs => [{
          :key => "a",
          :cf => "AVERAGE",
          :ds_name => "Absent"
        },{
          :key => "b",
          :cf => "AVERAGE",
          :ds_name => "Enrolled"
        }],
        :elements => [{
          :key => "a",
          :element => "AREA",
          :color => "CC9966",
          :text => "Total Enrolled"
        },{
          :key => "b",
          :element => "LINE1",
          :color => "FF9900",
          :text => "Total Absent"
        }],
        #:base => 1,
        :vlabel => "percent absent",
        :lowerlimit => 0
      }, "#{rrd_tool}")
    @image_name = [
      :id => 1, :value => "/rrd/school_absenteeism_woodson.png"
    ]
    respond_to do |format|
      format.json do
        render :json => {
          :total_results => 1,
          :results => @image_name.as_json
        }
      end
    end
  end

  def build_fake_data
    fake_data = [
      {
        :date => Time.local(2010,"aug",1,0,0).to_i.to_s,
        :absent => 100,
        :total => 500
      },
      {
        :date => Time.local(2010,"aug",2,0,0).to_i.to_s,
        :absent => 95,
        :total => 500
      },
      {
        :date => Time.local(2010,"aug",3,0,0).to_i.to_s,
        :absent => 108,
        :total => 500
      },
      {
        :date => Time.local(2010,"aug",4,0,0).to_i.to_s,
        :absent => 90,
        :total => 500
      },
      {
        :date => Time.local(2010,"aug",5,0,0).to_i.to_s,
        :absent => 97,
        :total => 500
      },
      {
        :date => Time.local(2010,"aug",6,0,0).to_i.to_s,
        :absent => 101,
        :total => 500
      }
    ]
    return fake_data
  end
  
end