class Rollcall::StudentReportedSymptoms < Rollcall::Base
  belongs_to :symptom, :class_name => "Rollcall::Symptom", :foreign_key => "symptom_id"
  belongs_to :student_daily_info, :class_name => "Rollcall::StudentDailyInfo", :foreign_key => "student_daily_info_id"
  
  set_table_name "rollcall_student_reported_symptoms"
end