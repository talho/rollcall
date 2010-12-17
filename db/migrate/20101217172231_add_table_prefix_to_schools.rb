class AddTablePrefixToSchools < ActiveRecord::Migration
  def self.up
    rename_table :schools, :rollcall_schools
  end

  def self.down
    rename_table :rolcall_schools, :schools
  end
end
