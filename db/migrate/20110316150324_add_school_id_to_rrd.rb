class AddSchoolIdToRrd < ActiveRecord::Migration
  def self.up
    add_column :rollcall_rrds, :school_id, :integer
    add_index :rollcall_rrds, :school_id
  end

  def self.down
    remove_index :rollcall_rrds, :school_id
    remove_column :rollcall_rrds, :school_id
  end
end
