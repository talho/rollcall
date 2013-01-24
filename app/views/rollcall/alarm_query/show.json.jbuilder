json.partial! 'application/success', success: true
json.data @alarm_query do |json, query|
  json.(query, :id, :name, :alarm_set, :start_date)
  json.severity query.severity
  json.deviation query.deviation
  json.schools query.schools do |json, s|
    json.(s, :id, :display_name)
  end
end