class AddLockVersionToRollcallTables < ActiveRecord::Migration
  def self.up
		add_column :absentee_reports, :lock_version, :integer, :default => 0, :null => false
		add_column :rollcall_alerts, :lock_version, :integer, :default => 0, :null => false
		add_column :school_district_daily_infos, :lock_version, :integer, :default => 0, :null => false
		add_column :school_districts, :lock_version, :integer, :default => 0, :null => false
		add_column :schools, :lock_version, :integer, :default => 0, :null => false
  end

  def self.down
		remove_column :absentee_reports, :lock_version
		remove_column :rollcall_alerts, :lock_version
		remove_column :school_district_daily_infos, :lock_version
		remove_column :school_districts, :lock_version
		remove_column :schools, :lock_version
  end
end
