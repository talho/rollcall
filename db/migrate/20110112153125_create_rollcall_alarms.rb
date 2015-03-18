class CreateRollcallAlarms < ActiveRecord::Migration
  def self.up
    create_table :rollcall_alarms do |t|
      t.integer :school_id
      t.integer :saved_query_id
      t.float   :deviation
      t.float   :severity
      t.float   :absentee_rate
      t.date    :report_date

      t.timestamps
    end
    add_index :rollcall_alarms, :school_id
    add_index :rollcall_alarms, :saved_query_id
  end

  def self.down
    remove_index :rollcall_alarms, :school_id
    remove_index :rollcall_alarms, :saved_query_id
    drop_table :rollcall_alarams
  end
end
