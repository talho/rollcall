# == Schema Information
#
# Table name: schools
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

class School < ActiveRecord::Base
  belongs_to :school_district
  has_many :school_users
  has_many :user, through: :school_users

  alias_attribute :name, :display_name

  validates :tea_id, presence: true, uniqueness: true

  def self.for_user(user)
    user_id = user.class == User ? user.id : user
    School.joins(%Q{
      LEFT JOIN school_users ON schools.id = school_users.school_id
      LEFT JOIN school_district_users USING (school_district_id)
    }).where("school_users.user_id = :user_id OR school_district_users.user_id = :user_id", {user_id: user.id}).distinct
  end

  has_and_belongs_to_many :alarm_queries
  has_many :school_daily_infos
  has_many :students
  has_many :student_daily_infos, :through => :students
  before_create :set_display_name

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
