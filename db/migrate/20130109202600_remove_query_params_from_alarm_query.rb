class RemoveQueryParamsFromAlarmQuery < ActiveRecord::Migration
  def up
    remove_column :rollcall_alarm_queries, :query_params
  end
 
  def down
    add_column :rollcall_alarm_queries, :query_params, :string
  end
end
