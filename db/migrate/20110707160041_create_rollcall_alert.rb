class CreateRollcallAlert < ActiveRecord::Migration
  def self.up
    create_table :rollcall_alerts do |tbl|
      tbl.integer :alarm_id
      tbl.integer :alert_id
    end
    add_index :rollcall_alerts, :alarm_id
    add_index :rollcall_alerts, :alert_id

    CreateMTIFor(RollcallAlert)
  end

  def self.down
    remove_index :rollcall_alerts, :alarm_id
    remove_index :rollcall_alerts, :alert_id

    DropMTIFor(RollcallAlert)
    drop_table :rollcall_alerts
  end
end
