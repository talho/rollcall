class RenameSavedQueryIdColumnForAlarmQueries < ActiveRecord::Migration
  def self.up
    rename_column :rollcall_alarms, :saved_query_id, :alarm_query_id
    remove_index :rollcall_alarms, :saved_query_id
    add_index :rollcall_alarms, :alarm_query_id
  end

  def self.down
    rename_column :rollcall_alarms, :alarm_query_id, :saved_query_id
    add_index :rollcall_alarms, :saved_query_id
    remove_index :rollcall_alarms, :alarm_query_id
  end
end
