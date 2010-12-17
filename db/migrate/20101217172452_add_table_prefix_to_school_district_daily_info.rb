class AddTablePrefixToSchoolDistrictDailyInfo < ActiveRecord::Migration
  def self.up
    rename_table :school_district_daily_infos, :rollcall_school_district_daily_infos
  end

  def self.down
    rename_table :rollcall_school_district_daily_infos, :school_district_daily_infos
  end
end
