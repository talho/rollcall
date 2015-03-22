require 'factory_girl'

FactoryGirl.define do
  factory :rollcall_alarm, :class => Rollcall::Alarm do
    association :school, :factory => :rollcall_school
    association :alarm_query, :factory => :rollcall_alarm_query
    deviation 1.0
    severity 1.0
    absentee_rate 1.0
    report_date Time.now
    alarm_severity "low"
    ignore_alarm false
  end

  factory :rollcall_alarm_query, :class => Rollcall::AlarmQuery do
    association :user, :factory => :user
    query_params "{type:simple,absent:gross}"
    sequence(:name){|t| "Name ##{t}"}
    severity_min 1
    severity_max 2
    deviation_min 1
    deviation_max 2
    alarm_set false
  end
=begin
  factory :rollcall_alert, :class => RollcallAlert do
    title "New Alarm for Test School[test]"
    message "A new alarm of test severity has been created for Test School on this day."
    association :author, :factory => :user
    association :alarm, :factory => :rollcall_alarm
  end
=end
  factory :school do
    sequence(:display_name){|t| "Display Name ##{t}"}
    tea_id 11111111
    school_type "Elementary School"
    sequence(:gmap_addr){|t| "#{t} Street Lane, City Name ST, 10101"}
    postal_code "10101"
    sequence(:school_number){|num| num}
    association :district, :factory => :rollcall_school_district
  end

  factory :rollcall_school_daily_info, :class => Rollcall::SchoolDailyInfo do
    association :school, :factory => :rollcall_school
    total_absent 10
    total_enrolled 100
    report_date Time.now
  end

  factory :school_district do
    sequence(:name){|t| "Name ##{t}"}
    district_id 1000
    association :jurisdiction, :factory => :jurisdiction
  end

  factory :rollcall_student, :class => Rollcall::Student do
    first_name "Student"
    last_name "Name"
    contact_first_name "Contact"
    contact_last_name  "Name"
    address "101 Street Lane, City State, 10101"
    zip "10101"
    gender "M"
    phone "1112223333"
    race  1
    association :school, :factory => :rollcall_school
    student_number "01"
    dob(Time.now - 10.years)
  end

  factory :rollcall_student_daily_info, :class => Rollcall::StudentDailyInfo do
    report_date Time.now
    sequence(:grade){|num|num}
    confirmed_illness true
    cid '101010101'
    health_year Time.now.year
    date_of_onset(Time.now - 3.days)
    temperature 98.0
    in_school true
    released false
    follow_up nil
    doctor nil
    doctor_address nil
    association :student, :factory => :rollcall_student
    report_time Time.now
  end

  factory :rollcall_student_reported_symptoms, :class => Rollcall::StudentReportedSymptom do
    association :symptom, :factory => :rollcall_symptom
    association :student_daily_info, :factory => :rollcall_student_daily_info
  end

  factory :rollcall_symptom , :class => Rollcall::Symptom do
    sequence(:id){|i| i}
    sequence(:name){|t| "Name ##{t}"}
    sequence(:icd9_code){|num| num}
  end

  factory :school_user do
    association :user, :factory => :user
    association :school, :factory => :rollcall_school
  end

  factory :school_district_user do
    association :user, :factory => :user
    association :school_district, :factory => :rollcall_school_district
  end
end
