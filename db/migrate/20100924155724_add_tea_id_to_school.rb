class AddTeaIdToSchool < ActiveRecord::Migration
  def self.up
    add_column :schools, :tea_id, :integer
    add_column :schools, :school_id, :integer
    add_index :schools, :tea_id
    add_index :schools, :school_id
  end

  def self.down
    remove_index :schools, :school_id
    remove_index :schools, :tea_id
    remove_column :schools, :school_id
    remove_column :schools, :tea_id
  end
end
