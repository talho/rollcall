# == Schema Information
#
# Table name: absentee_reports
#
#  id          :integer(4)      not null, primary key
#  school_id   :integer(4)
#  report_date :date
#  enrolled    :integer(4)
#  absent      :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#
require 'fastercsv'
  
class Rollcall::AbsenteeReport < Rollcall::Base

  set_table_name'rollcall_absentee_reports'
  
end