json.success true
json.total_results @results.length
json.results @results do |json, user|
  json.partial! 'rollcall_user', user: user
end