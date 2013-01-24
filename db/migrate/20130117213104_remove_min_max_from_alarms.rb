class RemoveMinMaxFromAlarms < ActiveRecord::Migration
  def up
    change_table :rollcall_alarm_queries do |t|
      t.remove :deviation_max, :severity_max
      t.rename :deviation_min, :deviation
      t.rename :severity_min, :severity      
    end
  end

  def down  
    change_table :rollcall_alarm_queries do |t|
      t.integer :deviation_max
      t.integer :severity_max
      t.rename :deviation, :deviation_min
      t.rename :severity, :severity_min      
    end
  end
end
