json.success true
json.results @results do |json, user|
  json.partial! 'rollcall_user', user: user
end