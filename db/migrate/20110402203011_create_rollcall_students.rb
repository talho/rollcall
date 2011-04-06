class CreateRollcallStudents < ActiveRecord::Migration
  def self.up
    create_table :rollcall_students do |t|
      t.string  :first_name
      t.string  :last_name
      t.string  :contact_first_name
      t.string  :contact_last_name
      t.string  :address
      t.string  :zip
      t.string  :gender, :limit => 1
      t.string  :phone
      t.integer :race
      t.integer :school_id
      t.integer :student_number
      t.integer :user_id
      t.date    :dob
      t.timestamps
    end
    add_index :rollcall_students, :id
    add_index :rollcall_students, :user_id
  end

  def self.down
    remove_index :rollcall_students, :user_id
    remove_index :rollcall_students, :id
    drop_table :rollcall_students
  end
end
