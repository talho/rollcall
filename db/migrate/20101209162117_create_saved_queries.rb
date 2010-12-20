class CreateSavedQueries < ActiveRecord::Migration
  def self.up
    create_table :saved_queries do |t|
      t.integer :id
      t.integer :user_id
      t.string  :query_params
      t.string  :name
      t.integer :severity_min
      t.integer :severity_max
      t.integer :deviation_threshold
      t.integer :deviation_min
      t.integer :deviation_max
      t.timestamps
    end
    add_index :saved_queries, :user_id
    add_index :saved_queries, :name
  end

  def self.down
    remove_index :saved_queries, :user_id
    remove_index :saved_queries, :name
    drop_table :saved_queries
  end
end
