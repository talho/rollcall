class AddSerialDataToDailyInfo < ActiveRecord::Migration
  def self.up
    add_column :school_district_daily_infos, :data, :string
  end

  def self.down
    remove_column :school_district_daily_infos, :data
  end
end
