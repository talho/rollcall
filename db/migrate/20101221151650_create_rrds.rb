class CreateRrds < ActiveRecord::Migration
  def self.up
    create_table :rollcall_rrds do |t|
      t.integer :saved_query_id
      t.string  :file_name
      t.timestamps
    end
    add_index :rollcall_rrds, :saved_query_id
  end

  def self.down
    remove_index :rollcall_rrds, :saved_query_id
    drop_table :rrds
  end

end
