class ChangeColumnReportDateOnStudentDailyInfo < ActiveRecord::Migration
  def self.up
    change_column(:rollcall_student_daily_infos, :report_date, :datetime)
  end

  def self.down
    change_column(:rollcall_student_daily_infos, :report_date, :date)
  end
end
