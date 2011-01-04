require 'fastercsv'

def build_rrd(identifier)
  rrd_path = Dir.pwd << "/rrd/"

  rrd_tool = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
    YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
  end

  RRD.create("#{rrd_path}#{identifier}_absenteeism.rrd",
    {
      :step  => 24.hours.seconds,
      :start => Time.local(2010,"oct",1,0,0).to_i,
      :ds    => [{
        :name => "Absent", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
      },{
        :name => "Enrolled", :type => "GAUGE", :heartbeat => 72.hours.seconds, :min => 0, :max => 768000
      }],
      :rra => [{
        :type => "AVERAGE", :xff => 0.5, :steps => 1, :rows => 366
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
    school = Rollcall::School.find_or_create_by_tea_id(
      :display_name => row["name"].strip,
      :tea_id => row["tea_id"],
      :district => @district,
      :school_id => row["school_id"].strip,
      :school_type => row["school_type"].strip,
      :postal_code => row["postal_code"].strip)
    build_rrd(school.tea_id)
    Rollcall::Rrd.find_or_create_by_file_name(
      :file_name => "#{school.tea_id}_absenteeism.rrd"  
    )
  end
end

Rollcall::SchoolDistrict.find_or_create_by_name(:name => "Houston ISD").school_types.each do |school_type|
  build_rrd(school_type.gsub(/\s/,'').underscore)
end
