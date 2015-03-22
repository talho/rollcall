# == Schema Information
#
# Table name: student_daily_infos
#
#  id                :integer(4)      not null, primary key
#  cid               :string
#  report_date       :date
#  report_time       :datetime
#  health_year       :string(10)
#  grade             :integer(11)
#  student_id,       :integer
#  date_of_onset,    :date
#  temperature,      :float
#  in_school,        :boolean
#  released,         :boolean
#  diagnosis,        :string
#  treatment,        :string
#  follow_up,        :date
#  doctor,           :string
#  doctor_address,   :string
#  confirmed_illness :tinyint(1)
#  created_at        :datetime
#  updated_at        :datetime

class StudentDailyInfo < ActiveRecord::Base
  has_many :student_reported_symptoms
  has_many :symptoms, :through => :student_reported_symptoms
  belongs_to :student

  accepts_nested_attributes_for :student, :student_reported_symptoms

  #Scopes
  def self.for_date(date)
    where(:report_date => date)
  end
end
