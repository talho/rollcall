class Rollcall::StudentDailyInfo < Rollcall::Base
  set_table_name "rollcall_student_daily_infos"
  has_and_belongs_to_many :symptoms, :join_table => 'rollcall_student_reported_symptoms', :class_name => "Rollcall::Symptom"
end