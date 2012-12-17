json.absenteeism @options[:default_options][:absenteeism] 
json.age @options[:default_options][:age] 
json.data_functions @options[:default_options][:data_functions]
json.gender @options[:default_options][:gender] 
json.symptoms @options[:default_options][:symptoms]   
json.zipcode @options[:zipcodes] do |json, zip|
  json.id zip
  json.value zip
end
json.school_type @options[:school_types] do |json, st|
  json.id st
  json.value st
end
i = 1
json.grade @options[:grades] do |json, g|
  json.id i
  i += 1
  json.value g
end
json.school_districts @options[:school_districts]
json.schools @options[:schools]

