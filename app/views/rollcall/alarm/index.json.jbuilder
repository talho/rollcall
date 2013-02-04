json.partial! 'application/success', success: true
json.total_results @total
json.results @alarms do |json, alarm|
  json.school_name alarm.display_name
  json.report_date alarm.report_date
  json.id alarm.id
end