json.partial! 'application/success', success: true
json.data @alarm_query do |json, query|
  json.(query, :id, :name, :alarm_set)
  json.severity query.severity_min
  json.deviation query.deviation_min
  json.schools query.schools do |json, s|
    json.(s, :id, :display_name)
  end
end