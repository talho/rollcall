class AddDistrictIdToSchoolDistrict < ActiveRecord::Migration
  def self.up
    tbl = :rollcall_school_districts
    add_column tbl, :district_id, :integer
    add_index tbl,  :district_id
  end

  def self.down
    tbl = :rollcall_school_districts
    remove_index tbl, :district_id
    remove_column tbl, :district_id
  end
end
