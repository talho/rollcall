class RemoveRollcallTablePrefix < ActiveRecord::Migration
  def change
    rename_table :rollcall_alarm_queries, :alarm_queries
    rename_table :rollcall_alarm_queries_school_districts, :alarm_queries_school_districts
    rename_table :rollcall_alarm_queries_schools, :alarm_queries_schools
    rename_table :rollcall_alarms, :alarms
    drop_table :rollcall_bases
    rename_table :rollcall_school_daily_infos, :school_daily_infos
    rename_table :rollcall_school_district_daily_infos, :school_district_daily_infos
    rename_table :rollcall_school_districts, :school_districts
    rename_table :rollcall_schools, :schools
    rename_table :rollcall_student_daily_infos, :student_daily_infos
    rename_table :rollcall_student_reported_symptoms, :student_reported_symptoms
    rename_table :rollcall_students, :students
    rename_table :rollcall_symptom_tags, :symptom_tags
    rename_table :rollcall_symptoms, :symptoms
    rename_table :rollcall_user_school_districts, :school_district_users
    rename_table :rollcall_user_schools, :school_users
  end
end
