class DeviseCreateUsers < ActiveRecord::Migration
  def up
    unless table_exists? :users
      create_table(:users) do |t|
        ## Database authenticatable
        t.string :email,              null: false, default: ""
        t.string :encrypted_password, null: false, default: ""
        t.string :name,               null: false, default: ""

        ## Recoverable
        t.string   :reset_password_token
        t.datetime :reset_password_sent_at

        ## Rememberable
        t.datetime :remember_created_at

        ## Trackable
        t.integer  :sign_in_count, default: 0, null: false
        t.datetime :current_sign_in_at
        t.datetime :last_sign_in_at
        t.inet     :current_sign_in_ip
        t.inet     :last_sign_in_ip

        t.timestamps
      end

      add_index :users, :email,                unique: true
      add_index :users, :reset_password_token, unique: true
    else
      # change users table from clearance to devise
      change_table(:users) do |t|
        t.rename :display_name, :name
        t.string   :reset_password_token
        t.datetime :reset_password_sent_at
        t.datetime :remember_created_at
        t.integer  :sign_in_count, default: 0, null: false
        t.datetime :current_sign_in_at
        t.rename :last_signed_in_at, :last_sign_in_at
        t.inet     :current_sign_in_ip
        t.inet     :last_sign_in_ip
      end
      add_index :users, :reset_password_token, unique: true
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
