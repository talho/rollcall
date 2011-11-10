require 'csv'
#run through the symptoms file
CSV.open(File.dirname(__FILE__) + '/symptoms.csv', :headers => true) do |symptoms|
  symptoms.each do |row|
    #if icd9_code is blank, skip record
    if row["icd9_code"].blank?
      puts "Could not create a symptoms for #{row["icd9_code"]}; incomplete information"
      next
    end
    puts "seeding #{row["name"]}" unless row["icd9_code"].blank? || Rollcall::Symptom.find_by_icd9_code(row["icd9_code"].strip)
    #create symptom
    symptoms = Rollcall::Symptom.find_or_create_by_icd9_code(:icd9_code => row["icd9_code"], :name => row["name"].strip)
  end
end