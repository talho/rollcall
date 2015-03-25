# == Schema Information
#
# Table name: school_districts
#
#  id              :integer(4)      not null, primary key
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  city            :string
#  state           :string
#  county          :string
#  state_id        :string
#

class SchoolDistrict < ActiveRecord::Base
  has_many :school_district_users
  has_many :users, through: :school_district_users

  has_many :schools, -> { order 'display_name' }

  validates :state_id, presence: true, uniqueness: {scope: :state}

  has_many :students, :through => :schools
  has_many :student_daily_infos, :through => :students
  has_many :school_daily_infos, :through => :schools
end
