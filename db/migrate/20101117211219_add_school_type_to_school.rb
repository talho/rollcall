class AddSchoolTypeToSchool < ActiveRecord::Migration
  def self.up
    add_column :schools, :school_type, :string
  end

  def self.down
    remove_column :schools, :school_type
  end
end
