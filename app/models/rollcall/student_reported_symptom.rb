# == Schema Information
#
# Table name: rollcall_student_reported_symptoms
#
#  id,                    :integer(4) not null, primary key
#  symptom_id,             :integer(4)  not null, foreign key
#  student_daily_info_id,  :integer(4)  not null, foreign key
#
class Rollcall::StudentReportedSymptom < Rollcall::Base
  belongs_to :symptom, :class_name => "Rollcall::Symptom", :foreign_key => "symptom_id"
  belongs_to :student_daily_info, :class_name => "Rollcall::StudentDailyInfo", :foreign_key => "student_daily_info_id"
  
  set_table_name :rollcall_student_reported_symptoms
end