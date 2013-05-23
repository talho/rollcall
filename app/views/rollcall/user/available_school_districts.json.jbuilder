json.success true
json.total_results @results.length
json.results @results do |json, sd|
  json.partial! 'rollcall/school_districts/school_district', school_district: sd 
end