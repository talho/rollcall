class AddSchoolIdToAlarmQueries < ActiveRecord::Migration
  def self.up
    add_column :rollcall_alarm_queries, :school_id, :integer
    add_index :rollcall_alarm_queries, :school_id
  end

  def self.down
    remove_index :rollcall_alarm_queries, :school_id
    remove_column :rollcall_alarm_queries, :school_id
  end
end
