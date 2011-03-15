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

class Rollcall::SchoolDistrict < Rollcall::Base
  belongs_to  :jurisdiction
  has_many    :schools, :class_name => "Rollcall::School", :foreign_key => "district_id"
  has_many    :absentee_reports, :class_name => "Rollcall::AbsenteeReport", :through => :schools
  has_many    :daily_infos, :class_name => "Rollcall::SchoolDistrictDailyInfo", :foreign_key => "school_district_id", :order => "report_date asc"

  set_table_name "rollcall_school_districts"

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
    end
    di.update_stats
    di
  end

  def recent_absentee_rates(days)
    avgs=Array.new
    (Date.today-(days-1).days).upto Date.today do |date|
      avgs.push(average_absence_rate(date))
    end
    avgs
  end

  def zipcodes
    schools.find(:all, :select => "DISTINCT postal_code, display_name", :order => "postal_code").map(&:postal_code)
  end

  def school_types
    schools.find(:all, :select => "DISTINCT school_type, display_name", :order => "school_type").map(&:school_type)
  end
end