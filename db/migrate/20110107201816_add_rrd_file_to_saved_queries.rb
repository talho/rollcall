class AddRrdFileToSavedQueries < ActiveRecord::Migration
  def self.up
    add_column :rollcall_saved_queries, :rrd_id, :integer
    add_index :rollcall_saved_queries, :rrd_id
  end

  def self.down
    remove_index :rollcall_saved_queries, :rrd_id
    remove_column :rollcall_saved_queries, :rrd_id
  end
end
