class CreateStudentDailyInfos < ActiveRecord::Migration
  def self.up
    create_table :rollcall_student_daily_infos do |t|
      t.integer :school_id
      t.date    :date
      t.integer :age
      t.date    :dob
      t.boolean :gender
      t.integer :grade
      t.boolean :confirmed_illness
      t.timestamps
    end
    add_index :rollcall_student_daily_infos, :id
    add_index :rollcall_student_daily_infos, :school_id
  end

  def self.down
    remove_index :rollcall_student_daily_infos, :id
    remove_index :rollcall_student_daily_infos, :school_id
    drop_table :rollcall_student_daily_infos
  end
end
