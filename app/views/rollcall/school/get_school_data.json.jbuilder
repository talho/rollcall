json.partial! 'application/success', success: true
json.total_results @info.length
json.results do |json|
  json.school_daily_infos @info
end