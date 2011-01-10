class RemoveSavedQueryIdFromRrds < ActiveRecord::Migration
  def self.up
    remove_index :rollcall_rrds, :saved_query_id
    remove_column :rollcall_rrds, :saved_query_id
  end

  def self.down
    add_column :rollcall_rrds, :saved_query_id, :integer
    add_index :rollcall_rrds, :saved_query_id
  end
end
