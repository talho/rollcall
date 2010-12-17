class AddTablePrefixToSchoolDictricts < ActiveRecord::Migration
  def self.up
    rename_table :school_districts, :rollcall_school_districts
  end

  def self.down
    rename_table :rollcall_school_districts, :school_districts
  end
end
