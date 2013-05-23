json.array! @results do |json, sd|
  json.partial! 'rollcall/school_districts/school_district', school_district: sd
end
