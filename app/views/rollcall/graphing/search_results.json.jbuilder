json.partial! 'application/success', success: true
json.total_results @results.length
json.results @results do |json, obj|  
  if obj.is_a? Rollcall::SchoolDistrict
    json.(obj, :name, :id)
  else
    json.(obj, :tea_id, :gmap_lat, :gmap_lng, :gmap_addr, :id)
    json.name obj.display_name
  end
end