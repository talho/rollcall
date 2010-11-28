require 'fastercsv'
@district = SchoolDistrict.find_or_create_by_name(:name => "Houston ISD") { |district|
  district.jurisdiction=Jurisdiction.find_or_create_by_name("Harris")
}

FasterCSV.open(File.dirname(__FILE__) + '/schools.csv', :headers => true) do |schools|
  schools.each do |row|
    if row["name"].blank?
      puts "Could not create a school for #{row["tea_id"]}; incomplete information"
      next
    end
    puts "seeding #{row["name"]}" unless row["tea_id"].blank? || School.find_by_tea_id(row["tea_id"].strip)
    School.find_or_create_by_tea_id(:display_name => row["name"].strip, :tea_id => row["tea_id"], :district => @district, :school_id => row["school_id"].strip)
  end
end