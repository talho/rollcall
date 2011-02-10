class AddIgnoreFlagToRollcallAlarms < ActiveRecord::Migration
  def self.up
    add_column :rollcall_alarms, :ignore_alarm, :boolean, :default => false
  end

  def self.down
    remove_column :rollcall_alarms, :ignore_alarm
  end
end
