# == Schema Information
#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
#  last_name          :string(255)
#  phin_oid           :string(255)
#  description        :text
#  display_name       :string(255)
#  first_name         :string(255)
#  email              :string(255)
#  preferred_language :string(255)
#  title              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(128)
#  salt               :string(128)
#  token              :string(128)
#  token_expires_at   :datetime
#  email_confirmed    :boolean(1)      default(FALSE), not null
#  phone              :string(255)
#  delta              :boolean(1)      default(TRUE), not null
#  credentials        :text
#  bio                :text
#  experience         :text
#  employer           :string(255)
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  public             :boolean(1)
#  photo_file_size    :integer(4)
#  photo_updated_at   :datetime
#  deleted_at         :datetime
#  deleted_by         :string(255)
#  deleted_from       :string(24)
#  home_phone         :string(255)
#  mobile_phone       :string(255)
#  fax                :string(255)
#
require 'spec/spec_helper'

describe User do
  before(:each) do
    @user               = Factory(:user)
    @school             = Factory(:rollcall_school)
    @role_membership    = Factory(:role_membership, :user => @user, :jurisdiction => @school.district.jurisdiction)
  end
  describe "validations" do
    it "should be valid" do
      @user.should be_valid
    end
  end

  describe "school_districts" do
    it "returns all school districts associated via user jurisdiction" do
      @user.school_districts.each do |sd| Rollcall::SchoolDistrict.all.should include(sd) end
    end
  end

  describe "schools" do
    it "returns all schools associated to the user" do
      @user.schools.should include(@school)
    end
  end

  describe "alarm_queries" do
    it "returns all alarm queries associated with the user" do
      @alarm_query = Factory(:rollcall_alarm_query, :user => @user)
      @user.alarm_queries.should include(@alarm_query)
    end
  end
end