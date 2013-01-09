class AddSchoolsToAlarmQueries < ActiveRecord::Migration
  def change
    create_table :rollcall_alarm_queries_schools, :id => false do |t|
      t.integer :alarm_query_id, :null => false
      t.integer :school_id, :null => false
    end
  end
end
