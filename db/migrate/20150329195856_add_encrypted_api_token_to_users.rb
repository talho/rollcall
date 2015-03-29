class AddEncryptedApiTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_api_token, :string
  end
end
