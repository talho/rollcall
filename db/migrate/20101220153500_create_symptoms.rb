class CreateSymptoms < ActiveRecord::Migration
  def self.up
    create_table :rollcall_symptoms do |t|
      t.string :icd9_code
    end
  end

  def self.down
    drop_table :rollcall_symptoms
  end
end
