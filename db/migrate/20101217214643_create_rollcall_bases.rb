class CreateRollcallBases < ActiveRecord::Migration
  def self.up
    create_table :rollcall_bases do |t|
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :rollcall_bases
  end
end
