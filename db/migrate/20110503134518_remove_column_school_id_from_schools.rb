class RemoveColumnSchoolIdFromSchools < ActiveRecord::Migration
  def self.up
    remove_index :schools, :school_id
    remove_column :rollcall_schools, :school_id
  end

  def self.down
    add_column :rollcall_schools, :school_id, :integer
    add_index :schools, :school_id
  end
end