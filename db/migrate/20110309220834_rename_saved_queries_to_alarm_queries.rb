class RenameSavedQueriesToAlarmQueries < ActiveRecord::Migration
  def self.up
    rename_table :rollcall_saved_queries, :rollcall_alarm_queries
  end

  def self.down
    rename_table :rollcall_alarm_queries, :rollcall_saved_queries
  end
end