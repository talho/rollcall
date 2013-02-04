json.partial! 'application/success', success: true
json.data do |json|
  json.(@alarm_query, :id, :name, :alarm_set, :start_date)
  json.severity @alarm_query.severity
  json.deviation @alarm_query.deviation
  json.schools @alarm_query.schools do |json, s|
    json.(s, :id, :display_name)
  end
  json.school_districts @alarm_query.school_districts do |json, s|
    json.(s, :id, :name)
  end
end