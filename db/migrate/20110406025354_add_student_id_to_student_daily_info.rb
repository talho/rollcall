class AddStudentIdToStudentDailyInfo < ActiveRecord::Migration
  def self.up
    tbl = :rollcall_student_daily_infos
    add_column tbl, :student_id, :integer

    add_index tbl, :student_id
  end

  def self.down
    tbl = :rollcall_student_daily_infos

    remove_index tbl, :student_id
    remove_column tbl, :student_id
  end
end
