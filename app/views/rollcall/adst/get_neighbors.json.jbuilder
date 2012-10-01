json.partial! 'application/success', success: true
json.total_results @length
json.results @school_district_array do |json, obj|  
  json.(obj, :name, :id, :title)
  json.results obj.result
end
