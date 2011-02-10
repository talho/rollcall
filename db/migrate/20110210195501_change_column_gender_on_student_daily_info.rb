class ChangeColumnGenderOnStudentDailyInfo < ActiveRecord::Migration
  def self.up
    change_column(:rollcall_student_daily_infos, :gender, :string, :limit => 1)
  end

  def self.down
    change_column(:rollcall_student_daily_infos, :gender, :boolean)
  end
end
