# == Schema Information
#
# Table name: schools
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  display_name  :string(255)
#  level         :string(255)
#  address       :string(255)
#  postal_code   :string(255)
#  school_number :integer(4)
#  district_id   :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  region        :string(255)
#  school_type   :string(255)
#

class Rollcall::School < Rollcall::Base
  belongs_to :district, :class_name => "Rollcall::SchoolDistrict"
  has_many :school_daily_infos, :class_name => "Rollcall::SchoolDailyInfo"
  has_many :student_daily_infos, :class_name => "Rollcall::StudentDailyInfo"
  has_many :alarms, :class_name => "Rollcall::Alarm"
  has_many :alarm_queries, :class_name => "Rollcall::AlarmQuery"
  has_many :rrds, :class_name => "Rollcall::Rrd"
  has_many :students, :class_name => "Rollcall::Student"
  before_create :set_display_name
  #default_scope :order => "display_name"

  named_scope :in_alert,
              :select     => "distinct schools.*",
              :include    => :school_daily_infos,
              :conditions => ["(rollcall_school_daily_infos.total_absent / rollcall_school_daily_infos.total_enrolled)
                              >= 0.10 AND rollcall_school_daily_infos.report_date >= ?", 30.days.ago],
              :order      => "(rollcall_school_daily_infos.total_absent/rollcall_school_daily_infos.total_enrolled) desc"

  named_scope :with_alarms,
              :select     => "distinct schools.*",
              :include    => :alarms,
              :conditions => ["rollcall_alarms.school_id = rollcall_schools.id"]

  set_table_name "rollcall_schools"

  def average_absence_rate(date=nil)
    date      = Date.today if date.nil?
    absentees = rollcall_absentee_reports.for_date(date).map do |report|
      unless report.enrolled.blank?
        report.absent.to_f/report.enrolled.to_f
      else
        0
      end
    end
    unless absentees.empty?
      absentees.inject(&:+)/absentees.size
    else
      0
    end
  end

  def self.search(params)
    school_type_qstr = "school_type IN ('#{params["school_type"].join("','")}')" unless params["school_type"].blank?
    postal_code_qstr = "postal_code IN ('#{params["zip"].join("','")}')" unless params["zip"].blank?
    school_qstr = "display_name IN ('#{params["school"].join("','")}')" unless params["school"].blank?

    cond_part1 = case
    when school_type_qstr && postal_code_qstr
      "(#{school_type_qstr} AND #{postal_code_qstr})"
    when school_type_qstr
      school_type_qstr
    when postal_code_qstr
      postal_code_qstr
    end

    condition = case
    when cond_part1 && school_qstr
      "#{cond_part1} OR #{school_qstr}"
    when cond_part1
      cond_part1
    when school_qstr
      school_qstr
    end

    find(:all, :conditions => [condition])
  end

  private
  def set_display_name
    self.display_name = self.name if self.display_name.nil? || self.display_name.strip.blank?
  end
end
