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
require File.dirname(__FILE__) + "/../factories.rb"

describe User do
  before(:each) do
    @user                = FactoryGirl.create(:user)
    @school              = FactoryGirl.create(:rollcall_school)
    @user_schools        = FactoryGirl.create(:rollcall_user_school, :user => @user, :school => @school)
    @user_school_district= FactoryGirl.create(:rollcall_user_school_district, :user => @user, :school_district => @school.district)
    @role_membership     = FactoryGirl.create(:role_membership, :user => @user, :jurisdiction => @school.district.jurisdiction, :role => Role.admin('rollcall'))
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
      @alarm_query = FactoryGirl.create(:rollcall_alarm_query, :user => @user)
      @user.alarm_queries.should include(@alarm_query)
    end
  end

  describe "to_json_results_rollcall" do
    it "returns a user object with school and school district information to fit json document model" do
      @user.to_json_results_rollcall[:schools].should include(@school)
    end
    end
    
  describe "is_rollcall_admin?" do
    before(:each) do
      @admin_role = FactoryGirl.create(:role, :name => "Admin", :application => "rollcall")
      @user.role_memberships.create(:jurisdiction => @school.district.jurisdiction, :role => @admin_role)
    end
    it "returns a boolean indicating if user is a rollcall admin or not" do
      @user.is_rollcall_admin?.should == true
    end
  end

  describe "is_rollcall_user?" do
    before(:each) do
      @rollcall_role = FactoryGirl.create(:role, :name => "Rollcall", :application => "rollcall")
      @user.role_memberships.create(:jurisdiction => @school.district.jurisdiction, :role => @rollcall_role)
    end
    it "returns a boolean indicating if user has access to rollcall application" do
      @user.is_rollcall_user?.should == true
    end
  end

  describe "is_rollcall_nurse?" do
    before(:each) do
      @nurse_role = FactoryGirl.create(:role, :name => "Nurse", :application => "rollcall")
      @user.role_memberships.create(:jurisdiction => @school.district.jurisdiction, :role => @nurse_role)
    end
    it "returns a boolean indicating if user has the nurse role attached to them" do
      @user.is_rollcall_nurse?.should == true
    end
  end

  describe "is_rollcall_epi?" do
    before(:each) do
      @epi_role = FactoryGirl.create(:role, :name => "Epidemiologist", :application => "rollcall")
      @user.role_memberships.create(:jurisdiction => @school.district.jurisdiction, :role => @epi_role)
    end
    it "returns a boolean indicating if user has the epidemiologist role attached to them" do
      @user.is_rollcall_epi?.should == true
    end
  end

  describe "is_rollcall_health_officer?" do
    before(:each) do
      @health_officer = FactoryGirl.create(:role, :name => "Health Officer", :application => "rollcall")
      @user.role_memberships.create(:jurisdiction => @school.district.jurisdiction, :role => @health_officer)
    end
    it "returns a boolean indicating if user has the health officer role attached to them" do
      @user.is_rollcall_health_officer?.should == true
    end
  end

  describe "school_search" do
    it "performs a search against schools attached to user" do
      @user.school_search({:type => "simple"}).should include(@school)
      @user.school_search({:type => "adv"}).should include(@school)
    end
  end

  describe "students" do
    before(:each) do
      @student = FactoryGirl.create(:rollcall_student, :school => @school)
    end
    it "returns a list of students for the schools associated with user" do
      @user.students.should include(@student)
    end
  end
end