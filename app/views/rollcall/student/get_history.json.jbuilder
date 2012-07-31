json.partial! 'application/success', success: true
json.total_results @daily_records.length
json.results @daily_records do |json, rec|
  json.(rec, :cid, :confirmed_illness, :created_at, :date_of_onset, :diagnosis, :doctor, :doctor_address, :follow_up, :grade, :health_year, :id, :in_school,
             :released, :report_date, :report_time, :student_id, :temperature, :treatment, :updated_at)
  json.symptom rec.symptoms.map(&:name).join(",")
end
