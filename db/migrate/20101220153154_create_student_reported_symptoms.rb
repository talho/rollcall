class CreateStudentReportedSymptoms < ActiveRecord::Migration
  def self.up
    create_table :rollcall_student_reported_symptoms do |t|
      t.integer :symptom_id
      t.integer :student_daily_info_id
    end
    add_index :rollcall_student_reported_symptoms, :id
    add_index :rollcall_student_reported_symptoms, :symptom_id, :name => :rollcall_srs_symptom_id
    add_index :rollcall_student_reported_symptoms, :student_daily_info_id, :name => :rollcall_srs_sdi_id
  end

  def self.down
    remove_index :rollcall_student_reported_symptoms, :id
    remove_index :rollcall_student_reported_symptoms, :name => :rollcall_srs_symptom_id
    remove_index :rollcall_student_reported_symptoms, :name => :rollcall_srs_sdi_id
    drop_table :rollcall_student_reported_symptoms
  end
end
