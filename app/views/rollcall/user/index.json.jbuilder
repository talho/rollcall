json.success true
json.total_results @results.total_entries
json.results @results do |json, user|
  json.partial! 'rollcall_user', user: user
end