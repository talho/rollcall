require 'fastercsv'

@district = Rollcall::SchoolDistrict.find_or_create_by_name(:name => "Houston ISD") { |district|
  district.jurisdiction=Jurisdiction.find_or_create_by_name("Harris")
}

FasterCSV.open(File.dirname(__FILE__) + '/schools.csv', :headers => true) do |schools|
  rrd_path = Dir.pwd << "/rrd/"
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
        :school_number => row["school_number"].strip,
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
        :school_number => row["school_number"].strip,
        :school_type => row["school_type"].strip,
        :postal_code => row["postal_code"].strip,
        :gmap_lat => row["gmap_lat"],
        :gmap_lng => row["gmap_lng"],
        :gmap_addr => row["gmap_addr"].strip)
    end
    File.delete("#{rrd_path}#{school.tea_id}_absenteeism.rrd") if File.exist?("#{rrd_path}#{school.tea_id}_absenteeism.rrd")
    Rollcall::Rrd.build_rrd(school.tea_id, school.id, Time.gm(2010,"aug",01,0,0))
  end
end