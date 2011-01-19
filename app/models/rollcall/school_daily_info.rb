class Rollcall::SchoolDailyInfo < Rollcall::Base
  belongs_to :school, :class_name => "Rollcall::School", :foreign_key => "school_id"
  
  set_table_name "rollcall_school_daily_infos"  
end