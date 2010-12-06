# == Schema Information
#
# Table name: school_districts
#
#  id              :integer(4)      not null, primary key
#  name            :string(255)
#  jurisdiction_id :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#

class SchoolDistrict < ActiveRecord::Base
  belongs_to  :jurisdiction
  has_many    :schools, :foreign_key => "district_id"
  has_many    :absentee_reports, :through => :schools
  has_many    :daily_infos, :class_name => "SchoolDistrictDailyInfo", :foreign_key => "school_district_id", :order => "report_date asc"

  def average_absence_rate(date=nil)
    date=Date.today if date.nil?

    di=daily_infos.for_date(date).first
    di = update_daily_info(date) if di.nil? || di.absentee_rate.nil?
    di.absentee_rate 
  end

  def update_daily_info(date)
    di = daily_infos.find_by_report_date(date)
    if di.nil?
      di = daily_infos.create(:report_date => date)
    else
      di.update_stats
    end
    di
  end

  def recent_absentee_rates(days)
    avgs=Array.new
    (Date.today-(days-1).days).upto Date.today do |date|
      avgs.push(average_absence_rate(date))
    end
    avgs
  end

  def by_zipcodes
    schools.scoped(:select => "DISTINCT id,postal_code", :order => "postal_code")
  end

  def by_school_types
    schools.scoped(:select => "DISTINCT id,school_type", :order => "school_type")
  end
end
