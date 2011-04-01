class AddIliColumnsToStudentDailyInfo < ActiveRecord::Migration
  def self.up
    tbl = :rollcall_student_daily_infos
    add_column tbl, :cid, :integer
    add_column tbl, :health_year, :string, :limit => 10
    add_column tbl, :tea_id, :string, :limit => 9
    add_column tbl, :campus_name, :string, :limit => 100
    add_column tbl, :date_of_onset, :date
    add_column tbl, :temperature, :float
    add_column tbl, :zip, :string, :limit => 10
    add_column tbl, :in_school, :boolean
    add_column tbl, :released, :boolean
    add_column tbl, :diagnosis, :string, :limit => 200
    add_column tbl, :treatment, :string, :limit => 200
    add_column tbl, :name, :string, :limit => 200
    add_column tbl, :contact, :string, :limit => 200
    add_column tbl, :phone, :string, :limit => 10
    add_column tbl, :race, :integer
    add_column tbl, :follow_up, :date
    add_column tbl, :doctor, :string, :limit => 200
    add_column tbl, :doctor_address, :string, :limit => 200
  end

  def self.down
    tbl = :rollcall_student_daily_infos
    remove_column tbl, :cid
    remove_column tbl, :health_year
    remove_column tbl, :tea_id
    remove_column tbl, :campus_name
    remove_column tbl, :date_of_onset
    remove_column tbl, :temperature
    remove_column tbl, :zip
    remove_column tbl, :in_school
    remove_column tbl, :released
    remove_column tbl, :diagnosis
    remove_column tbl, :treatment
    remove_column tbl, :name
    remove_column tbl, :contact
    remove_column tbl, :phone
    remove_column tbl, :race
    remove_column tbl, :follow_up
    remove_column tbl, :doctor
    remove_column tbl, :doctor_address
  end
end
