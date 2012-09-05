json.partial! 'application/success', success: true
json.total_results @students.total_entries
json.results @students do |json, student|
  json.id student.id
  json.grade student.grade
  json.first_name student.first_name.blank? ? "Unknown" : student.first_name
  json.last_name student.last_name.blank? ? "Unknown" : student.last_name
  json.contact_first_name student.contact_first_name.blank? ? "Unknown" : student.contact_first_name
  json.contact_last_name student.contact_last_name.blank? ? "Unknown" : student.contact_last_name
  json.address student.address.blank? ? "Unknown" : student.address
  json.zip student.zip.blank? ? "Unknown" : student.zip
  json.dob student.dob.blank? ? "Unknown" : student.dob
  json.student_number student.student_number.blank? ? "Unknown" : student.student_number
  json.phone student.phone.blank? ? "Unknown" : student.phone
  json.gender student.gender.blank? ? "Unknown" : student.gender
  json.race @race_array.select{|ra| ra[:id] == student.race}.map{|ra| ra[:value]}.first || "Unknown"
end