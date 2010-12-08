require 'fastercsv'

def build_rrd(identifier)
  rrd_path = Dir.pwd << "/rrd/"

  rrd_tool = if File.exist?(doc_yml = RAILS_ROOT+"/config/rrdtool.yml")
    YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
  end

  RRD.create("#{rrd_path}#{identifier}_absenteeism.rrd",
    {
      :step  => 24.hours.seconds,
      :start => Time.local(2010,"nov",1,0,0).to_i,
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

@district = SchoolDistrict.find_or_create_by_name(:name => "Houston ISD") { |district|
  district.jurisdiction=Jurisdiction.find_or_create_by_name("Harris")
}
FasterCSV.open(File.dirname(__FILE__) + '/schools.csv') do |schools|
  schools.each do |row|
    if row[0].nil?
      puts "Could not create a school for #{row[0]}; incomplete information"
      next
    end
    puts "seeding #{row[0]}" unless row[1] && School.find_by_tea_id(row[1])
    unless row[1].blank?
      school = School.find_or_create_by_tea_id(:tea_id => row[1]) {|s|
        s.district      = @district
        s.school_number = row[1].blank? ? null : row[1][6,3]
        s.tea_id        = row[1]
        s.school_type   = row[2]
        s.postal_code   = row[3]
      }
      build_rrd(school.tea_id)
    end
  end
end

SchoolDistrict.find_or_create_by_name(:name => "Houston ISD").school_types.each do |school_type|
  build_rrd(school_type.gsub(/\s/,'').underscore)
end