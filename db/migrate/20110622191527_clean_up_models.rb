class CleanUpModels < ActiveRecord::Migration
  def self.up
    remove_index  :rollcall_schools, :name => :schools_name
    remove_column :rollcall_schools, :name
    remove_column :rollcall_schools, :level
    remove_column :rollcall_schools, :address
    remove_column :rollcall_schools, :region

    remove_column :rollcall_student_daily_infos, :tea_id
    remove_column :rollcall_student_daily_infos, :campus_name
    remove_column :rollcall_student_daily_infos, :age
    remove_column :rollcall_student_daily_infos, :school_id
    remove_column :rollcall_student_daily_infos, :dob
    remove_column :rollcall_student_daily_infos, :gender
    remove_column :rollcall_student_daily_infos, :zip
    remove_column :rollcall_student_daily_infos, :name
    remove_column :rollcall_student_daily_infos, :contact
    remove_column :rollcall_student_daily_infos, :phone
    remove_column :rollcall_student_daily_infos, :race

    remove_index :rollcall_students, :user_id
    remove_column :rollcall_students, :user_id
  end

  def self.down
    add_column :rollcall_schools, :name, :string
    add_column :rollcall_schools, :level, :string
    add_column :rollcall_schools, :address, :string
    add_column :rollcall_schools, :region, :string
    add_index  :rollcall_schools, :name, :name => :schools_name

    add_column :rollcall_student_daily_infos, :tea_id
    add_column :rollcall_student_daily_infos, :campus_name
    add_column :rollcall_student_daily_infos, :age
    add_column :rollcall_student_daily_infos, :school_id
    add_column :rollcall_student_daily_infos, :dob
    add_column :rollcall_student_daily_infos, :gender
    add_column :rollcall_student_daily_infos, :zip
    add_column :rollcall_student_daily_infos, :name
    add_column :rollcall_student_daily_infos, :contact
    add_column :rollcall_student_daily_infos, :phone
    add_column :rollcall_student_daily_infos, :race

    add_column :rollcall_students, :user_id
    add_index :rollcall_students, :user_id
  end
end
