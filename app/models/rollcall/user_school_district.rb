class Rollcall::UserSchoolDistrict < Rollcall::Base
  belongs_to :user
  belongs_to :school_district, :class_name => "Rollcall::SchoolDistrict", :foreign_key => "school_district_id"
  set_table_name "rollcall_user_school_districts"
end