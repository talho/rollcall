class ChangeColumnStudentIdOnStudent < ActiveRecord::Migration
  def self.up
    change_column(:rollcall_students, :student_number, :string)
  end

  def self.down
    change_column(:rollcall_students, :student_number, :integer)
  end
end
