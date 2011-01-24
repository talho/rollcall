class AddAlarmSeverityToRollcallAlarm < ActiveRecord::Migration
  def self.up
    add_column :rollcall_alarms, :alarm_severity, :string
  end

  def self.down
    remove_column :rollcall_alarms, :alarm_severity
  end
end
