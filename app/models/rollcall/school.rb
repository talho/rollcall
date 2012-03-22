# == Schema Information
#
# Table name: rollcall_schools
#
#  id            :integer(4)      not null, primary key
#  display_name  :string(255)
#  postal_code   :string(255)
#  school_number :integer(4)
#  district_id   :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  tea_id        :integer
#  school_type   :string(255)
#  gmap_lat      :float
#  gmap_lng      :float
#  gmap_addr     :string

class Rollcall::School < Rollcall::Base
  belongs_to :district, :class_name => "Rollcall::SchoolDistrict"
  has_many :school_daily_infos, :class_name => "Rollcall::SchoolDailyInfo"
  has_many :alarms, :class_name => "Rollcall::Alarm"
  has_many :students, :class_name => "Rollcall::Student"
  before_create :set_display_name

  named_scope :in_alert,
              :select     => "distinct schools.*",
              :include    => :school_daily_infos,
              :conditions => ["(CAST(rollcall_school_daily_infos.total_absent as FLOAT)/CAST(rollcall_school_daily_infos.total_enrolled as FLOAT))
                              >= 0.10 AND rollcall_school_daily_infos.report_date >= ?", 30.days.ago],
              :order      => "(CAST(rollcall_school_daily_infos.total_absent as FLOAT)/CAST(rollcall_school_daily_infos.total_enrolled as FLOAT)) desc"

  named_scope :with_alarms,
              :select     => "distinct schools.*",
              :include    => :alarms,
              :conditions => ["rollcall_alarms.school_id = rollcall_schools.id"]

  set_table_name "rollcall_schools"

  # Method returns the average absence rate of school
  #
  # Method returns the average absence rate of a school based on date
  def average_absence_rate(date=nil)
    date      = Date.today if date.nil?
    absentees = school_daily_infos.for_date(date).map do |report|
      unless report.total_enrolled.blank?
        report.total_absent.to_f/report.total_enrolled.to_f
      else
        0.to_f
      end
    end
    unless absentees.empty?
      absentees.inject(&:+)/absentees.size
    else
      0.to_f
    end
  end

  private

  # Method sets display name for school
  def set_display_name
    self.display_name = self.name if self.display_name.nil? || self.display_name.strip.blank?
  end
end
