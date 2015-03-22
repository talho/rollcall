# == Schema Information
#
# Table name: school_users
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  school_id          :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#
class SchoolUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :school
  enum role: [:staff, :admin]
end
