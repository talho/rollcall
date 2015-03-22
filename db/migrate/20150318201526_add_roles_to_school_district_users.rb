class AddRolesToSchoolDistrictUsers < ActiveRecord::Migration
  def change
    add_column :school_users, :role, :integer, default: 0
    add_column :school_district_users, :role, :integer, default: 0
  end
end
