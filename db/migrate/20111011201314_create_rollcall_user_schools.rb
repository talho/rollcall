class CreateRollcallUserSchools < ActiveRecord::Migration
  def self.up
    create_table :rollcall_user_schools do |t|
      t.integer :id
      t.integer :user_id
      t.integer :school_id
      t.timestamps
    end
    add_index :rollcall_user_schools, :id
    add_index :rollcall_user_schools, :user_id
    add_index :rollcall_user_schools, :school_id
  end

  def self.down
    remove_index :rollcall_user_schools, :id
    remove_index :rollcall_user_schools, :user_id
    remove_index :rollcall_user_schools, :school_id
    drop_table :rollcall_user_schools
  end
end
