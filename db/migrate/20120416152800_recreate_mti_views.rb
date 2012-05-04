class RecreateMtiViews < ActiveRecord::Migration
  def self.up    
    DropMTIFor(RollcallAlert)
    CreateMTIFor(RollcallAlert)
  end

  def self.down
  end
end
