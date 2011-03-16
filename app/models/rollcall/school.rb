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
  belongs_to :district, :class_name => "Rollcall::SchoolDistrict", :foreign_key => "district_id"
  has_many :school_daily_infos, :class_name => "Rollcall::SchoolDailyInfo"
  has_many :student_daily_infos, :class_name => "Rollcall::StudentDailyInfo"
  has_many :alarms, :class_name => "Rollcall::Alarm"

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
    search_param     = ""
    zipcode          = ""
    zipcode          = params[:zip].index('...').blank? ? CGI::unescape(params[:zip]) : "" unless params[:zip].blank?
    school_name      = params[:school].index('...').blank? ? CGI::unescape(params[:school]) : ""
    school_type      = params[:school_type].index('...').blank? ? CGI::unescape(params[:school_type]) : ""
    search_param     = school_name unless school_name.blank?
    search_param     = school_type unless school_type.blank?
    search_param     = zipcode unless zipcode.blank?
    search_condition = "%" + search_param + "%"
    return find(:all, :conditions => ['display_name LIKE ? OR postal_code LIKE ? OR school_type LIKE ?', search_condition, search_condition, search_condition])
  end

  private
  def set_display_name
    self.display_name = self.name if self.display_name.nil? || self.display_name.strip.blank?
  end
end
