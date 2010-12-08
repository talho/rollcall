class AddTeaIdToSchools < ActiveRecord::Migration
  def self.up
    add_column :schools, :tea_id, :integer
    add_index :schools, :tea_id
  end

  def self.down
    remove_column :schools, :tea_id
    remove_index :tea_id
  end
end