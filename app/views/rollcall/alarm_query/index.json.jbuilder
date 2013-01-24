json.partial! 'application/success', success: true
json.total_results @alarm_queries.length
json.results @alarm_queries do |json, query|
  json.(query, :id, :user_id, :name, :severity, :deviation, :alarm_set, :created_at, :updated_at, :start_date)
  json.schools query.schools do |json, s|
    json.(s, :id, :display_name)
  end
  json.school_districts query.school_districts do |json, s|
    json.(s, :id, :name)
  end
end