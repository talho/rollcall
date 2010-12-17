class AddTablePrefixToAbsenteeReport < ActiveRecord::Migration
  def self.up
    rename_table :absentee_reports, :rollcall_absentee_reports
  end

  def self.down
    rename_table :rollcall_absentee_reports, :absentee_reports
  end
end
