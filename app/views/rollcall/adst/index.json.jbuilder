json.partial! 'application/success', success: true
json.total_results @length
json.results @results do |json, obj|
  if obj.is_a? Rollcall::SchoolDistrict
    json.(obj, :name)
  else
    json.(obj, :tea_id, :gmap_lat, :gmap_lng, :gmap_addr)
    json.name = obj.display_name
    json.school_id = obj.id
  end
  json.results obj.result
end
