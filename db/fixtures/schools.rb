require 'fastercsv'
#run through the school districts file
FasterCSV.open(File.dirname(__FILE__) + '/school_districts.csv', :headers => true) do |school_districts|
  school_districts.each do |row|
    #if school district id blank, skip to next record
    if row["school_district_id"].blank?
      puts "Could not create a school district for #{row["school_district_name"]}; incomplete information"
      next
    end
    puts "seeding #{row["school_district_name"]}"
    #create school district
    Rollcall::SchoolDistrict.find_or_create_by_district_id(
      :district_id  => row["school_district_id"],
      :name         => row["school_district_name"],
      :jurisdiction => Jurisdiction.find_by_name(row['jurisdiction_name'])
    )
  end
end

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
      :display_name  => row["name"],
      :tea_id        => row["tea_id"],
      :district      => Rollcall::SchoolDistrict.find_by_district_id(row["district_id"]),
      :school_number => row["school_number"],
      :school_type   => row["school_type"],
      :postal_code   => row["postal_code"],
      :gmap_lat      => row["gmap_lat"],
      :gmap_lng      => row["gmap_lng"],
      :gmap_addr     => row["gmap_addr"]
    )
    #create rrd file for school
    Rollcall::Rrd.build_rrd(school.tea_id, school.id, Time.gm(2010,"aug",01,0,0))
  end
end