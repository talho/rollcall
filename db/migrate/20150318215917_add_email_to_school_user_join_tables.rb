class AddEmailToSchoolUserJoinTables < ActiveRecord::Migration
  def change
    add_column :school_district_users, :email, :string
    add_column :school_users, :email, :string
  end
end
