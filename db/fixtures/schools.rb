require 'csv'
#run through the school districts file
CSV.open(File.dirname(__FILE__) + '/school_districts.csv', :headers => true) do |school_districts|
  school_districts.each do |row|
    #if school district id blank, skip to next record
    if row["school_district_id"].blank?
      puts "Could not create a school district for #{row["school_district_name"]}; incomplete information"
      next
    end
    puts "seeding #{row["school_district_name"]}"
    #create school district
    r = Rollcall::SchoolDistrict.find_or_create_by_district_id(
      :district_id  => row["school_district_id"],
      :name         => row["school_district_name"],
      :jurisdiction => Jurisdiction.find_by_name(row['jurisdiction_name'])
    )
    Rollcall::Rrd.build_rrd(r.district_id, r.id, Time.gm(Time.now.year,"aug",01,0,0), "district")
  end
end

#Run through the schools.csv file, create a new schools
CSV.open(File.dirname(__FILE__) + '/schools.csv', :headers => true) do |schools|
  schools.each do |row|
    #if school name blank, skip to next record
    if row["name"].blank?
      puts "Could not create a school for #{row["tea_id"]}; incomplete information"
      next
    end
    puts "seeding #{row["name"]}"
    #create school
    school = Rollcall::School.find_by_tea_id(row["tea_id"])
    school = Rollcall::School.create(
      :display_name  => row["name"],
      :tea_id        => row["tea_id"],
      :district      => Rollcall::SchoolDistrict.find_by_district_id(row["district_id"]),
      :school_number => row["school_number"]
    ) if school.blank?
    school.update_attributes(
      :school_type   => row["school_type"],
      :postal_code   => row["postal_code"],
      :gmap_lat      => row["gmap_lat"],
      :gmap_lng      => row["gmap_lng"],
      :gmap_addr     => row["gmap_addr"]
    )
    #create rrd file for school
    Rollcall::Rrd.build_rrd(school.tea_id, school.id, Time.gm(Time.now.year,"aug",01,0,0))
  end
end