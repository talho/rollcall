json.partial! 'application/success', success: true
json.total_results @student_infos.total_entries
json.results @student_infos do |json, student_info|
  json.(student_info, :cid, :confirmed_illness, :date_of_onset, :diagnosis, :doctor, :doctor_address, :follow_up, :grade, :health_year, :id, :in_school, :student_id, :temperature, :treatment, :report_date, :report_time)
  student = student_info.student
  json.address student.address.blank? ? "Unknown" : student.address
  json.contact_first_name student.contact_first_name.blank? ? "Unknown" : student.contact_first_name
  json.contact_last_name student.contact_last_name.blank? ? "Unknown" : student.contact_last_name
  json.dob student.dob.blank? ? "Unknown" : student.dob
  json.first_name student.first_name.blank? ? "Unknown" : student.first_name
  json.gender student.gender.blank? ? "Unknown" : student.gender
  json.last_name student.last_name.blank? ? "Unknown" : student.last_name
  json.phone student.phone.blank? ? "Unknown" : student.phone
  json.race student.race
  json.student_number student.student_number.blank? ? "Unknown" : student.student_number
  json.symptom student_info.symptoms.map(&:name).join(",")
  json.zip student.zip.blank? ? "Unknown" : student.zip
end
