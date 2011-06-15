require 'fastercsv'
#Run through the schools.csv file, create a new schools
FasterCSV.open(File.dirname(__FILE__) + '/schools.csv', :headers => true) do |schools|
  #we will use this to create the corresponding rrd file for the school
  rrd_path = Dir.pwd << "/rrd/"
  schools.each do |row|
    #if school name blank, skip to next record
    if row["name"].blank?
      puts "Could not create a school for #{row["tea_id"]}; incomplete information"
      next
    end
    puts "seeding #{row["name"]}"
    #create school
    school = Rollcall::School.find_or_create_by_tea_id(
      :display_name  => row["name"].strip,
      :tea_id        => row["tea_id"],
      :district      => Rollcall::SchoolDistrict.find_by_district_id(row["district_id"]),
      :school_number => row["school_number"].strip,
      :school_type   => row["school_type"].strip,
      :postal_code   => row["postal_code"].strip,
      :gmap_lat      => row["gmap_lat"],
      :gmap_lng      => row["gmap_lng"],
      :gmap_addr     => row["gmap_addr"].strip
    )
    #create rrd file for school
    Rollcall::Rrd.build_rrd(school.tea_id, school.id, Time.gm(2010,"aug",01,0,0))
  end
end