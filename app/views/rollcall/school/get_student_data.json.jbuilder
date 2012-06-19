json.partial! 'application/success', success: true
json.total_results @info.length
json.results do |json|
  json.student_daily_infos @info
end