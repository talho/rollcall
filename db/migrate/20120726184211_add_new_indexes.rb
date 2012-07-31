class AddNewIndexes < ActiveRecord::Migration
  def up
    create_index :rollcall_students, :school_id
  end

  def down
    remove_index :rollcall_students, :school_id
  end
end
