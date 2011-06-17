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