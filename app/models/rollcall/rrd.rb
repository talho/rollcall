# == Schema Information
#
# Table name: rollcall_rrd
#
#  id                 :integer(4)      not null, primary key
#  saved_query_id     :integer(4)      not null, foreign key
#  file_name          :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class Rollcall::Rrd < Rollcall::Base
  set_table_name "rollcall_rrd" 
end
