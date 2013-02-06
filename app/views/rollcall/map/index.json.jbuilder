json.partial! 'application/success', success: true
json.start @start
json.end @end
json.results @results do |json, date|
  json.date date[:record_date]
  json.schools date[:schools] do |json, school|
    json.(school, :id, :weight, :display_name, :gmap_lat, :gmap_lng)
  end
end