class CreateAlarms < ActiveRecord::Migration
  def change
    drop_table :alarms
    drop_table :alarm_queries

    create_table :alarms do |t|
      t.references :user, index: true
      t.boolean :attendance_deviation
      t.integer :ili_threshold
      t.integer :confirmed_ili_threshold
      t.integer :measles_threshold

      t.timestamps null: false
    end
    add_foreign_key :alarms, :users
  end
end
