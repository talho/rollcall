class RemoveSchoolIdRrdIdFromAlarmQuery < ActiveRecord::Migration
  def self.up
    remove_index :rollcall_alarm_queries, :school_id

    # must use old table name as the index name is still "index_rollcall_saved_queries_on_rrd_id"
    begin 
      remove_index :rollcall_saved_queries, :rrd_id
    rescue
    end
    begin 
      remove_index :rollcall_alarm_queries, :rrd_id
    rescue
    end

    remove_column :rollcall_alarm_queries, :school_id
    remove_column :rollcall_alarm_queries, :rrd_id
  end

  def self.down
    add_column :rollcall_alarm_queries, :school_id, :integer
    add_column :rollcall_alarm_queries, :rrd_id, :integer
    add_index :rollcall_alarm_queries, :school_id
    add_index :rollcall_alarm_queries, :rrd_id, :name => "index_rollcall_saved_queries_on_rrd_id"
  end
end
