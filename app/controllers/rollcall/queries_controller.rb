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
      {:id => 0, :value => 'High Fever'},
      {:id => 1, :value => 'Nausea'},
      {:id => 2, :value => 'Headache'},
      {:id => 3, :value => 'Extreme Headache'}
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
    rrd_path = Dir.pwd << "/rrd/"
    rrd_tool =  if RAILS_ENV=="development"
      "/opt/local/bin/rrdtool"
    else
      "rrdtool"
    end
    rrd_image_path = Dir.pwd << "/public/rrd/"
    RRD.create("#{rrd_path}school_absenteeism.rrd",
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
    
    @result_set = build_fake_data
    @result_set.each do |rec|
      RRD.update("#{rrd_path}school_absenteeism.rrd", [rec[:date],rec[:absent], rec[:total]], "#{rrd_tool}")      
    end

    @cmd = RRD.graph("#{rrd_path}school_absenteeism.rrd","#{rrd_image_path}school_absenteeism_woodson.png",
      {
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
        :vlabel => "percent absent",
        :lowerlimit => 0
      }, "#{rrd_tool}")
    @image_name = [
      :id => 1, :value => "/rrd/school_absenteeism_woodson.png"
    ]
    respond_to do |format|
      format.json do
        render :json => {
          :total_results => @image_name.length,
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