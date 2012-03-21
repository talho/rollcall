# == Schema Information
#
# Table name: rollcall_user_schools
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  school_id          :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#
require 'spec/spec_helper'
require File.dirname(__FILE__) + "/../factories.rb"

describe Rollcall::UserSchool do
  before(:each) do
    @user        = Factory(:user)
    @school      = Factory(:rollcall_school)
    @user_school = Factory(:rollcall_user_school, :school => @school, :user => @user)
  end
  describe "validations" do
    it "should be valid" do
      @user_school.should be_valid
    end
  end

  describe "belongs_to" do
    context "user" do
      it "returns the user associated with the record" do
        @user_school.user.should == @user
      end
    end
    context "school" do
      it "returns the school associated with the record" do
        @user_school.school.should == @school
      end
    end
  end

end