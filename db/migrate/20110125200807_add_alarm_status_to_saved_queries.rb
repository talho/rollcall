class AddAlarmStatusToSavedQueries < ActiveRecord::Migration
  def self.up
    add_column :rollcall_saved_queries, :alarm, :boolean
  end

  def self.down
    remove_column :rollcall_saved_queries, :alarm
  end
end