class DropRrd < ActiveRecord::Migration
  def self.up
    #remove_index :rollcall_rrds, :school_id
    drop_table :rollcall_rrds
  end

  def self.down
    create_table :rollcall_rrds do |t|
      t.string  :file_name
      t.string  :rrd_type
      t.integer :record_id
      t.timestamps
    end
    #add_index :rollcall_rrds, :record_id
  end
end
