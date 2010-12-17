class CreateStudentDailyInfos < ActiveRecord::Migration
  def self.up
    create_table :rollcall_student_daily_infos do |t|
      t.integer :school_id
      t.date    :date
      t.integer :age
      t.date    :dob
      t.string  :gender
      t.integer :grade
      t.string  :symptoms
      t.string  :confirmed_illness
      t.timestamps
    end
    add_index :rollcall_student_daily_infos, :id
    add_index :rollcall_student_daily_infos, :school_id
  end

  def self.down
    drop_table :rollcall_student_daily_infos
  end
end
