json.success true
json.total_results @results.count
json.results @results do |json, user|
  json.partial! 'rollcall_user', user: user
end
