class AddSchoolDistrictsToAlarmQueries < ActiveRecord::Migration
  def change
    create_table :rollcall_alarm_queries_school_districts, :id => false do |t|
      t.integer :alarm_query_id, :null => false
      t.integer :school_district_id, :null => false
    end
  end
end
