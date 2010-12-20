class CreateSchoolDailyInfos < ActiveRecord::Migration
  def self.up
    create_table :rollcall_school_daily_infos do |t|
      t.integer :school_id
      t.integer :total_absent
      t.integer :total_enrolled
      t.date    :report_date
      t.timestamps
    end
    add_index :rollcall_school_daily_infos, :id
    add_index :rollcall_school_daily_infos, :school_id
  end

  def self.down
    drop_table :rollcall_school_daily_infos
  end
end
