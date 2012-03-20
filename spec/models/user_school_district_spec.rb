# == Schema Information
#
# Table name: rollcall_user_school_districts
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  school_district_id :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#
require 'spec/spec_helper'
require File.dirname(__FILE__) + "/../factories.rb"

describe Rollcall::UserSchoolDistrict do
  before(:each) do
    @user                 = Factory(:user)
    @school_district      = Factory(:rollcall_school_district)
    @user_school_district = Factory(:rollcall_user_school_district, :user => @user, :school_district => @school_district)
  end
  describe "validations" do
    it "should be valid" do
      @user_school_district.should be_valid
    end
  end

  describe "belongs_to" do
    context "user" do
      it "returns the user associated with the record" do
        @user_school_district.user.should == @user
      end
    end
    context "school_district" do
      it "returns the school district associated with the record" do
        @user_school_district.school_district.should == @school_district
      end
    end
  end

end