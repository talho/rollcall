# == Schema Information
#
# Table name: rollcall_student_daily_infos
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
#  symptoms,         :string
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


=begin
    OpenPHIN is an opensource implementation of the CDC guidelines for
    a public health information network.

    Copyright (C) 2009  Texas Association of Local Health Officials

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=end
class Rollcall::StudentDailyInfo < ActiveRecord::Base
  self.table_name = "rollcall_student_daily_infos"

  has_many :student_reported_symptoms, :class_name => "Rollcall::StudentReportedSymptom"
  has_many :symptoms, :through => :student_reported_symptoms, :class_name=>"Rollcall::Symptom"
  belongs_to :student, :class_name => "Rollcall::Student", :foreign_key => "student_id"

  scope :for_date, lambda{|date|{
    :conditions => {:report_date => date}
  }}
end
