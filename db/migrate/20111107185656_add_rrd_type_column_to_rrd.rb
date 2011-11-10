class AddRrdTypeColumnToRrd < ActiveRecord::Migration
  def self.up
    add_column :rollcall_rrds, :rrd_type, :string
    rename_column :rollcall_rrds, :school_id, :record_id
  end

  def self.down
    remove_column :rollcall_rrds, :rrd_type
    rename_column :rollcall_rrds, :record_id, :school_id
  end
end
