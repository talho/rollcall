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
end
