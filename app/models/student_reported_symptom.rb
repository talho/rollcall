# == Schema Information
#
# Table name: student_reported_symptoms
#
#  id,                    :integer(4) not null, primary key
#  symptom_id,             :integer(4)  not null, foreign key
#  student_daily_info_id,  :integer(4)  not null, foreign key
#
class StudentReportedSymptom < ActiveRecord::Base
  belongs_to :symptom
  belongs_to :student_daily_info
end
