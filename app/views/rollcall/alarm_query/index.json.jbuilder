json.partial! 'application/success', success: true
json.total_results @alarm_queries.length
json.results @alarm_queries do |json, query|
  json.(query, :id, :user_id, :name, :severity_min, :severity_max, :deviation_threshold, :deviation_max, :deviation_min, :alarm_set, :created_at, :updated_at)
  json.schools query.schools do |json, s|
    json.(s, :id, :display_name)
  end
end