class RemoveJurisdictionIdFromSchoolDistrict < ActiveRecord::Migration
  def change
    remove_column :school_districts, :jurisdiction_id, :integer
    add_column :school_districts, :city, :string
    add_column :school_districts, :county, :string
    add_column :school_districts, :state, :string
    change_column :school_districts, :district_id, :string
    rename_column :school_districts, :district_id, :state_id
  end
end
