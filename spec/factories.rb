require 'factory_girl'

Factory.define :rollcall_alarm, :class => Rollcall::Alarm do |m|
  m.association :school, :factory => :rollcall_school
  m.association :alarm_query, :factory => :rollcall_alarm_query
  m.deviation 1.0
  m.severity 1.0
  m.absentee_rate 1.0
  m.report_date Time.now
  m.alarm_severity "low"
  m.ignore_alarm false
end

Factory.define :rollcall_alarm_query, :class => Rollcall::AlarmQuery do |m|
  m.association :user, :factory => :user
  m.query_params "{type:simple,absent:gross}"
  m.sequence(:name){|t| "Name ##{t}"}
  m.severity_min 1
  m.severity_max 2
  m.deviation_min 1
  m.deviation_max 2
  m.alarm_set false
end

Factory.define :rollcall_alert, :class => RollcallAlert do |m|
  m.title "New Alarm for Test School[test]"
  m.message "A new alarm of test severity has been created for Test School on this day."
  m.association :author, :factory => :user
  m.association :alarm, :factory => :rollcall_alarm
end

Factory.define :rollcall_school , :class => Rollcall::School do |m|  
  m.sequence(:display_name){|t| "Display Name ##{t}"}
  m.tea_id 11111111
  m.school_type "Elementary School"
  m.sequence(:gmap_addr){|t| "#{t} Street Lane, City Name ST, 10101"}
  m.postal_code "10101"
  m.sequence(:school_number){|num| num}
  m.association :district, :factory => :rollcall_school_district
end

Factory.define :rollcall_school_daily_info, :class => Rollcall::SchoolDailyInfo do |m|
  m.association :school, :factory => :rollcall_school
  m.total_absent 10
  m.total_enrolled 100
  m.report_date Time.now
end

Factory.define :rollcall_school_district, :class => Rollcall::SchoolDistrict do |m|
  m.sequence(:name){|t| "Name ##{t}"}
  m.district_id 1000
  m.association :jurisdiction, :factory => :jurisdiction
end

Factory.define :rollcall_student, :class => Rollcall::Student do |m|
  m.first_name "Student"
  m.last_name "Name"
  m.contact_first_name "Contact"
  m.contact_last_name  "Name"
  m.address "101 Street Lane, City State, 10101"
  m.zip "10101"
  m.gender "M"
  m.phone "1112223333"
  m.race  1
  m.association :school, :factory => :rollcall_school
  m.student_number "01"
  m.dob(Time.now - 10.years)
end

Factory.define :rollcall_student_daily_info, :class => Rollcall::StudentDailyInfo do |m|
  m.report_date Time.now
  m.sequence(:grade){|num|num}
  m.confirmed_illness true
  m.cid '101010101'
  m.health_year Time.now.year
  m.date_of_onset(Time.now - 3.days)
  m.temperature 98.0
  m.in_school true
  m.released false
  m.follow_up nil
  m.doctor nil
  m.doctor_address nil
  m.association :student, :factory => :rollcall_student
  m.report_time Time.now
end

Factory.define :rollcall_student_reported_symptoms, :class => Rollcall::StudentReportedSymptom do |m|
 m.association :symptom, :factory => :rollcall_symptom
 m.association :student_daily_info, :factory => :rollcall_student_daily_info 
end

Factory.define :rollcall_symptom , :class => Rollcall::Symptom do |m|
  m.sequence(:id){|i| i}
  m.sequence(:name){|t| "Name ##{t}"}
  m.sequence(:icd9_code){|num| num}
end

Factory.define :rollcall_user_school, :class => Rollcall::UserSchool do |m|
  m.association :user, :factory => :user
  m.association :school, :factory => :rollcall_school
end

Factory.define :rollcall_user_school_district, :class => Rollcall::UserSchoolDistrict do |m|
  m.association :user, :factory => :user
  m.association :school_district, :factory => :rollcall_school_district
end