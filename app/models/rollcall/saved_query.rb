# == Schema Information
#
# Table name: saved_queries
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  query_params        :string(255)
#  name                :string(255)
#  severity_min        :integer(4)
#  severity_max        :integer(4)
#  deviation_threshold :integer(4)
#  deviation_min       :integer(4)
#  deviation_max       :integer(4)
#

class Rollcall::SavedQuery < Rollcall::Base
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"

  set_table_name "rollcall_saved_queries"  
end