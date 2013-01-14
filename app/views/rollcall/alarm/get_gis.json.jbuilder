json.partial! 'application/success', success: true
json.total_results @alarms.length
json.results @alarms do |json, alarm|
  json.school_name alarm.display_name
  json.absentee_rate alarm.absentee_rate
  json.deviation alarm.deviation
  json.severity alarm.severity
  json.school_addr alarm.gmap_addr
  json.school_lat alarm.gmap_lat
  json.school_lng alarm.gmap_lng
end