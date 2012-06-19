# == Schema Information
#
# Table name: school_district_daily_infos
#
#  id                 :integer(4)      not null, primary key
#  report_date        :date
#  absentee_rate      :float
#  total_enrollment   :integer(4)
#  total_absent       :integer(4)
#  school_district_id :integer(4)
# 
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

class Rollcall::SchoolDistrictDailyInfo < ActiveRecord::Base
  belongs_to :school_district, :class_name => "Rollcall::SchoolDistrict", :foreign_key => "school_district_id"

  validates_presence_of :school_district
  validates_presence_of :report_date

  self.table_name = "rollcall_school_district_daily_infos"

  def self.for_date(date)
    where(:report_date => date)
  end
  

  # Method will update school district daily info
  #
  # Method updates school district daily info
  def update_stats date, district_id
    schools = Rollcall::School.where(:district_id => district_id).pluck(:id)
    
    base = Rollcall::SchoolDailyInfo
      .for_date(date)
      .where("school_id in (?)",schools)
      
    total_enrolled = base
      .sum("total_enrolled")
      .to_i
      
    if total_enrolled > 0
      total_absent = base
        .sum("total_absent")
        .to_i
      
      rate = base
        .where("total_enrolled is not null")
        .where("total_enrolled <> 0")
        .average("CAST(total_absent as FLOAT)/CAST(total_enrolled as FLOAT)")
        .to_f

      write_attribute :absentee_rate, rate.nil? || rate == 0  ? nil : rate.round(4)*100
      write_attribute :total_enrollment, total_enrolled
      write_attribute :total_absent, total_absent
    end
  end
end