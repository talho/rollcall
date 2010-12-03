class AddSerialDataToAbsenceReports < ActiveRecord::Migration
  def self.up
    add_column :absentee_reports, :data, :string
  end

  def self.down
    remove_column :absentee_reports, :data
  end
end
