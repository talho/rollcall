class FixReportDateAndAddReportTimeColumnToStudentInfos < ActiveRecord::Migration
  def self.up
    change_column :rollcall_student_daily_infos, :report_date, :date
    add_column :rollcall_student_daily_infos, :report_time, :datetime
  end

  def self.down
    change_column :rollcall_student_daily_infos, :report_date, :datetime
    remove_column :rollcall_student_daily_infos, :report_time
  end
end
