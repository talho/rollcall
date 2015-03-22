require 'csv'
#run through the symptoms file
CSV.open(File.dirname(__FILE__) + '/symptoms.csv', :headers => true) do |symptoms|
  symptoms.each do |row|
    symptom = Symptom.where(:icd9_code => row["icd9_code"], :name => row["name"]).first_or_create
    row["matches"].split(';').each do |match|
      SymptomTag.where(symptom_id: symptom.id, match: match).first_or_create
    end if row["matches"]
  end
end
