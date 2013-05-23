json.array! @results do |json, s|
  json.partial! 'rollcall/school/school', school: s
end
