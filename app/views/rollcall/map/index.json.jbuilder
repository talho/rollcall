json.partial! 'application/success', success: true
json.results @schools do |json, school|
  json.(school, :id, :weight, :display_name, :gmap_lat, :gmap_lng)
end