class AddNameColumnToSymptoms < ActiveRecord::Migration
  def self.up
    add_column :rollcall_symptoms, :name, :string
  end

  def self.down
    remove_column :rollcall_symptoms, :name
  end
end
