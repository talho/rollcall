class AddTablePrefixToSavedQueries < ActiveRecord::Migration
  def self.up
    rename_table :saved_queries, :rollcall_saved_queries
  end

  def self.down
    rename_table :rollcall_saved_queries, :saved_queries
  end
end
