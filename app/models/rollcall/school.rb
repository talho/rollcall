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

class Rollcall::School < ActiveRecord::Base
  belongs_to :district, :class_name => "Rollcall::SchoolDistrict"
  has_many :school_daily_infos, :class_name => "Rollcall::SchoolDailyInfo"
  has_many :alarms, :class_name => "Rollcall::Alarm"
  has_many :students, :class_name => "Rollcall::Student"
  before_create :set_display_name
  include Rollcall::DataModule
    
  self.table_name = "rollcall_schools"

  def self.in_alert
    include(:school_daily_infos)
      .where("(CAST(rollcall_school_daily_infos.total_absent as FLOAT)/CAST(rollcall_school_daily_infos.total_enrolled as FLOAT)) >= 0.10 AND rollcall_school_daily_infos.report_date >= ?", 30.days.ago)
      .order("(CAST(rollcall_school_daily_infos.total_absent as FLOAT)/CAST(rollcall_school_daily_infos.total_enrolled as FLOAT)) desc")
      .uniq
  end
  
  def self.with_alarms
    include(:alarms)
      .where("rollcall_alarms.school_id = rollcall_schools.id")
      .uniq
  end

  # Method returns the average absence rate of school
  #
  # Method returns the average absence rate of a school based on date
  def average_absence_rate(date=nil)    
    date = Date.today if date.nil?
    school_daily_infos
      .for_date(date)
      .where("rollcall_school_daily_infos.total_enrolled is not null")
      .where("rollcall_school_daily_infos.total_enrolled <> 0")
      .average("(Cast(rollcall_school_daily_infos.total_absent as float) /" +
        "Cast(rollcall_school_daily_infos.total_enrolled as float))")
      .to_f
  end
  
  def self.for_user(user)
    user = user.class == User ? user : User.find(user)    
    roles = Role.admin('rollcall').id.to_s + ',' + Role.superadmin('rollcall').id.to_s
    schools = self                  
      .joins("left join rollcall_user_schools US on US.school_id = rollcall_schools.id")
      .joins("left join (rollcall_school_districts SD " +
        "inner join Jurisdictions J2 on SD.jurisdiction_id = J2.id " +
        "inner join Jurisdictions J1 on J2.lft between J1.lft and J1.rgt " +
        "inner join role_memberships RM on RM.jurisdiction_id = J1.id) on rollcall_schools.district_id = SD.id")
      .where("(SD.id is not null and RM.role_id in (#{roles}) and RM.user_id = #{user.id}) or (US.id is not null and US.user_id = #{user.id})")
      .uniq
    schools
  end
  
  def get_graph_data(params)    
    graph_data = Rollcall::School        
      .where('rollcall_schools.id' => id)
  
    build_graph_query(graph_data, params) 
  end
  
  private

  # Method sets display name for school
  def set_display_name
    self.display_name = self.name if self.display_name.nil? || self.display_name.strip.blank?
  end
end
