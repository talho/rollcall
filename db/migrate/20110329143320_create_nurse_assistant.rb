class CreateNurseAssistant < ActiveRecord::Migration
  def self.up
    create_table :rollcall_nurse_assistant do |t|
      t.integer :school_id,          :null => false
      t.integer :user_id,            :null => false
      t.integer :zip_code,           :null => false
      t.integer :phone_number,       :null => false
      t.string  :student_first_name, :null => false
      t.string  :student_last_name,  :null => false
      t.string  :parent_first_name,  :null => false
      t.string  :parent_last_name,   :null => false
      t.string  :address,            :null => false
      t.string  :action,             :null => false, :limit => 400
      t.date    :report_date,        :null => false
      t.timestamps
    end
    add_index :rollcall_nurse_assistant, :id
    add_index :rollcall_nurse_assistant, :school_id
  end

  def self.down
    remove_index :rollcall_nurse_assistant, :id
    remove_index :rollcall_nurse_assistant, :school_id
    drop_table   :rollcall_nurse_assistant
  end
end
