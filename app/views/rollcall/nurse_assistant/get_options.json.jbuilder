json.race @default_options[:race]
json.age @default_options[:age]
json.gender @default_options[:gender]
json.grade @default_options[:grade]
json.symptoms @default_options[:symptoms]
json.zip @zipcodes
json.app_init @app_init
json.school_id @school.id
json.school_name @school.display_name
json.schools @schools do |json, school|
  json.(school, :id, :display_name)
end
