class DropRollcallAbsenteeReport < ActiveRecord::Migration
  def self.up
    remove_index :rollcall_absentee_reports, :name => :absentee_reports_school_id_report_date

    drop_table :rollcall_absentee_reports
  end

  def self.down
    create_table :rollcall_absentee_reports do |t|
      t.integer :school_id
      t.date    :report_date
      t.integer :enrolled
      t.integer :absent
      t.timestamps
    end
    
    add_index :rollcall_absentee_reports, [:school_id, :report_date], :name => :absentee_reports_school_id_report_date
  end
end
