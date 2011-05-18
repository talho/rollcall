# == Schema Information
#
# Table name: rollcall_students
#
#  id                 :integer(4)      not null, primary key
#  first_name         :string(255)
#  last_name          :string(255)
#  contact_first_name :string(255)
#  contact_last_name  :string(255)
#  address            :string(255)
#  zip                :string(255)
#  address            :string(255)
#  phone              :string(255)
#  race               :integer(4)
#  school_id          :integer(4)
#  student_number     :string(255)
#  created_at         :datetime
#  updated_at         :datetime


class Rollcall::Student < Rollcall::Base
  belongs_to :school, :class_name => "Rollcall::School"
  has_many :student_daily_info, :class_name => "Rollcall::StudentDailyInfo"

  set_table_name "rollcall_students"
end