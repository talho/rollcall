require 'fastercsv'

def build_rrd(identifier)
  rrd_path = Dir.pwd << "/rrd/"
  rrd_tool = ROLLCALL_RRDTOOL_CONFIG["rrdtool_path"] + "/rrdtool"

  rrd_start_date = Time.gm(2010,"sep",01,0,0) - 1.day
  File.delete("#{rrd_path}#{identifier}_absenteeism.rrd") if File.exist?("#{rrd_path}#{identifier}_absenteeism.rrd")
  RRD.create("#{rrd_path}#{identifier}_absenteeism.rrd",
    {
      :step  => 24.hours.seconds,
      :start => rrd_start_date.to_i,
      :ds    => [{
        :name => "Absent", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
      },{
        :name => "Enrolled", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
      }],
      :rra => [{
        :type => "AVERAGE", :xff => 0.5, :steps => 5, :rows => 366
      },{
        :type => "HWPREDICT", :rows => 366, :alpha=> 0.5, :beta => 0.5, :period => 366, :rra_num => 3
      },{
        :type => "SEASONAL", :period => 365, :gamma => 0.5, :rra_num => 2
      },{
        :type => "DEVSEASONAL", :period => 366, :gamma => 0.5, :rra_num => 2
      },{
        :type => "DEVPREDICT", :rows => 366, :rra_num => 4
      },{
        :type => "MAX", :xff => 0.5, :steps => 1, :rows => 366
      },{
        :type => "LAST", :xff => 0.5, :steps => 1, :rows => 366
      }]
    } , "#{rrd_tool}") unless File.exists?("#{rrd_path}#{identifier}_absenteeism.rrd")
  return true
end

@district = Rollcall::SchoolDistrict.find_or_create_by_name(:name => "Houston ISD") { |district|
  district.jurisdiction=Jurisdiction.find_or_create_by_name("Harris")
}

FasterCSV.open(File.dirname(__FILE__) + '/schools.csv', :headers => true) do |schools|
  schools.each do |row|
    if row["name"].blank?
      puts "Could not create a school for #{row["tea_id"]}; incomplete information"
      next
    end
    puts "seeding #{row["name"]}" unless row["tea_id"].blank? || Rollcall::School.find_by_tea_id(row["tea_id"].strip)
    school = Rollcall::School.find_by_tea_id(row["tea_id"])
    if school
      school.update_attributes(
        :display_name => row["name"].strip,
        :district => @district,
        :school_id => row["school_id"].strip,
        :school_type => row["school_type"].strip,
        :postal_code => row["postal_code"].strip,
        :gmap_lat => row["gmap_lat"],
        :gmap_lng => row["gmap_lng"],
        :gmap_addr => row["gmap_addr"].strip)
    else
      school = Rollcall::School.find_or_create_by_tea_id(
        :display_name => row["name"].strip,
        :tea_id => row["tea_id"],
        :district => @district,
        :school_id => row["school_id"].strip,
        :school_type => row["school_type"].strip,
        :postal_code => row["postal_code"].strip,
        :gmap_lat => row["gmap_lat"],
        :gmap_lng => row["gmap_lng"],
        :gmap_addr => row["gmap_addr"].strip)
    end
    build_rrd(school.tea_id)
    Rollcall::Rrd.find_or_create_by_file_name(
      :file_name => "#{school.tea_id}_absenteeism.rrd"  
    )
  end
end

Rollcall::SchoolDistrict.find_or_create_by_name(:name => "Houston ISD").school_types.each do |school_type|
  build_rrd(school_type.gsub(/\s/,'').underscore)
end
