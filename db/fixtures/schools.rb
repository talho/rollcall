require 'fastercsv'
@district = SchoolDistrict.find_or_create_by_name(:name => "Houston ISD") { |district|
  district.jurisdiction=Jurisdiction.find_or_create_by_name("Harris")
}

FasterCSV.open(File.dirname(__FILE__) + '/schools.csv') do |schools|
  schools.each do |row|
    if row[0].nil?
      puts "Could not create a school for #{row[0]}; incomplete information"
      next
    end
    puts "seeding #{row[0]}" unless School.find_by_display_name(row[0])
    School.find_or_create_by_display_name(:display_name => row[0]) {|s|
      s.district=@district
      s.tea_id=row[1]
#    s.name=school[0]
#    s.region=school[1]
#    s.school_number = school[3]
#    s.display_name=school[0].strip.gsub(/(Elementary School$|Montessori$|Elementary$)/, "ES").
#          gsub(/High School$/, "HS").
#          gsub(/Middle School$/, "MS").
#          gsub(/Early Childhood Education Center$/,"ECC").upcase
    }
  end
end