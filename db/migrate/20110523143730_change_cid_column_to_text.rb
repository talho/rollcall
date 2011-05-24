class ChangeCidColumnToText < ActiveRecord::Migration
  def self.up
    change_column(:rollcall_student_daily_infos, :cid, :text)
  end

  def self.down
    change_column(:rollcall_student_daily_infos, :cid, :integer)  
  end
end
