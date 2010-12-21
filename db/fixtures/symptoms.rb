FasterCSV.open(File.dirname(__FILE__) + '/symptoms.csv', :headers => true) do |symptoms|
  symptoms.each do |row|
    if row["icd9_code"].blank?
      puts "Could not create a symptoms for #{row["icd9_code"]}; incomplete information"
      next
    end
    puts "seeding #{row["name"]}" unless row["icd9_code"].blank? || Rollcall::Symptom.find_by_icd9_code(row["icd9_code"].strip)
    symptoms = Rollcall::Symptom.find_or_create_by_icd9_code(:icd9_code => row["icd9_code"], :name => row["name"].strip)
  end
end