class AddStartDateToAlarmQuery < ActiveRecord::Migration
  def change
    add_column :rollcall_alarm_queries, :start_date, :date
  end
end
