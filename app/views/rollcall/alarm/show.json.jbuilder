json.partial! 'application/success', success: true
json.alarm @alarm do |json, alarm|
  json.school_name alarm.display_name
  json.school_id alarm.school_id
  json.report_date alarm.report_date
  json.id alarm.id
  json.reason alarm['reason']
  json.deviation alarm.deviation
  json.severity alarm.severity
  json.ignore_alarm alarm.ignore_alarm
  json.school_info alarm.school_info
  json.symptom_info alarm.symptom_info
  json.gmap_lat alarm.gmap_lat
  json.gmap_lng alarm.gmap_lng
  json.gmap_addr alarm.gmap_addr
  json.absentee_rate alarm.absentee_rate
end