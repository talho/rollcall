# == Schema Information
#
# Table name: rollcall_user_schools
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  school_id          :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#
class Rollcall::UserSchool < Rollcall::Base
  belongs_to :user
  belongs_to :school, :class_name => "Rollcall::School", :foreign_key => "school_id"
  set_table_name "rollcall_user_schools"
end