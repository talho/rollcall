require 'factory_girl'

FactoryGirl.define do

  factory :alarm do
    user nil
    attendance_deviation false
    ili_threshold 1
    confirmed_ili_threshold 1
    measles_threshold 1
  end

  factory :school do
    sequence(:display_name){|t| "Display Name ##{t}"}
    tea_id 11111111
    school_type "Elementary School"
    sequence(:gmap_addr){|t| "#{t} Street Lane, City Name ST, 10101"}
    postal_code "10101"
    sequence(:school_number){|num| num}
    association :district, :factory => :rollcall_school_district
  end

  factory :school_daily_info do
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

  factory :student do
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

  factory :student_daily_info do
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

  factory :student_reported_symptoms do
    association :symptom, :factory => :rollcall_symptom
    association :student_daily_info, :factory => :rollcall_student_daily_info
  end

  factory :symptom do
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
