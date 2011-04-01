# == Schema Information
#
# Table name: rollcall_student_daily_infos
#
#  id                :integer(4)      not null, primary key
#  school_id         :integer(11)
#  report_date       :date
#  age               :integer(11)
#  dob               :date
#  gender            :tinyint(1)
#  grade             :integer(11)
#  confirmed_illness :tinyint(1)

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
class Rollcall::StudentDailyInfo < Rollcall::Base
  set_table_name "rollcall_student_daily_infos"
  belongs_to :school, :class_name => "Rollcall::School", :foreign_key => "school_id"
  has_and_belongs_to_many :symptoms, :join_table => 'rollcall_student_reported_symptoms', :class_name => "Rollcall::Symptom"
end
