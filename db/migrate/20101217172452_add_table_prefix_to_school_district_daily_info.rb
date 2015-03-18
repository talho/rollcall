class AddTablePrefixToSchoolDistrictDailyInfo < ActiveRecord::Migration
  def self.up
    rename_index :school_district_daily_infos, :index_school_district_daily_infos_on_school_district_id, :idx_daily_infos_on_school_district_id
    rename_table :school_district_daily_infos, :rollcall_school_district_daily_infos
  end

  def self.down
    rename_index :rollcall_school_district_daily_infos, :idx_daily_infos_on_school_district_id, :index_school_district_daily_infos_on_school_district_id
    rename_table :rollcall_school_district_daily_infos, :school_district_daily_infos
  end
end
