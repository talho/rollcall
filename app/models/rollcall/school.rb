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
  has_many :alarm_queries, :class_name => "Rollcall::AlarmQuery"
  has_many :rrds, :class_name => "Rollcall::Rrd"
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

  def self.search(params, user_obj)
    if params[:type] == "simple"
      results =  simple_search(params, user_obj)
    else
      results = adv_search(params, user_obj)
    end
    return results
  end

  private
  def set_display_name
    self.display_name = self.name if self.display_name.nil? || self.display_name.strip.blank?
  end

  def self.simple_search params, current_user
    unless params[:school_district].blank?
      district_id = Rollcall::SchoolDistrict.find_by_name(params[:school_district]).id
      current_user.schools.find{|s| s.district_id == district_id }
    else
      r = current_user.schools.find_all{|s| s.school_type == params[:school_type] } unless params[:school_type].blank?
      r = current_user.schools.find{|s| s.display_name == params[:school] } unless params[:school].blank?
      r = current_user.schools if params[:school].blank? && params[:school_type].blank?
      r = [r] unless r.kind_of?(Array)
      r
    end
  end

  def self.adv_search params, current_user
    r = []
    if !params[:school_type].blank? && !params[:zip].blank?
      r = current_user.schools.find_all{|s| params[:school_type].include?(s.school_type) && params[:zip].include?(s.postal_code)}
    elsif !params[:school_type].blank?
      r = current_user.schools.find_all{|s| params[:school_type].include?(s.school_type)}
    elsif !params[:zip].blank?
      r = current_user.schools.find_all{|s| params[:zip].include?(s.postal_code)}
    end
    if r.blank?
      r = []
      unless params[:school].blank?
        r.push(current_user.schools.find{|s| params[:school].include?(s.display_name)})
      else
        r = current_user.schools
      end
    else
      r.push(current_user.schools.find{|s| params[:school].include?(s.display_name)}) unless params[:school].blank?
    end
    r
  end

end
