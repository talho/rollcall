class CreateRollcallUserSchoolDistricts < ActiveRecord::Migration
  def self.up
    create_table :rollcall_user_school_districts do |t|
      t.integer :user_id
      t.integer :school_district_id
      t.timestamps
    end
    add_index :rollcall_user_school_districts, :id
    add_index :rollcall_user_school_districts, :user_id
    add_index :rollcall_user_school_districts, :school_district_id
  end

  def self.down
    remove_index :rollcall_user_school_districts, :id
    remove_index :rollcall_user_school_districts, :user_id
    remove_index :rollcall_user_school_districts, :school_district_id
    drop_table :rollcall_user_school_districts
  end
end
