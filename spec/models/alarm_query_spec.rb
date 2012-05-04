# == Schema Information
#
# Table name: alarm_queries
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  school_id           :integer(4)
#  query_params        :string(255)
#  name                :string(255)
#  severity_min        :integer(4)
#  severity_max        :integer(4)
#  deviation_threshold :integer(4)
#  deviation_min       :integer(4)
#  deviation_max       :integer(4)
#  alarm_set           :boolean
#  created_at          :datetime
#  updated_at          :datetime
require 'spec/spec_helper'
require File.dirname(__FILE__) + "/../factories.rb"

describe Rollcall::AlarmQuery do
  describe "validations" do
    before(:each) do
      @alarm_query = FactoryGirl.create(:rollcall_alarm_query)
    end
    it "should be valid" do
      @alarm_query.should be_valid
    end
  end

  describe "belongs to" do
    before(:each) do
      @alarm_query = FactoryGirl.create(:rollcall_alarm_query)
    end
    context "user" do
      it "returns a user object" do
        @alarm_query.user.should_not be_blank
      end
    end
  end

  describe "generate_alarm" do
    before(:each) do
      @school               = FactoryGirl.create(:rollcall_school)
      @student              = FactoryGirl.create(:rollcall_student, :school => @school)
      @school_daily_info    = FactoryGirl.create(:rollcall_school_daily_info, :school => @school)
      @student_daily_info   = FactoryGirl.create(:rollcall_student_daily_info, :student => @student)
      @user                 = FactoryGirl.create(:user)
      @user_school          = FactoryGirl.create(:rollcall_user_school, :user => @user, :school => @school)
      @user_school_district = FactoryGirl.create(:rollcall_user_school_district, :user => @user, :school_district => @school.district)
      @role_membership      = FactoryGirl.create(:role_membership, :user => @user, :jurisdiction => @school.district.jurisdiction)
      @alarm_query          = FactoryGirl.create(:rollcall_alarm_query, :alarm_set => true, :user => @user)
    end
    it "returns true if alarms are set" do
      @alarm_query.generate_alarm.should be_true
    end
    it "returns false if alarms are not set" do
      @alarm_query       = FactoryGirl.create(:rollcall_alarm_query, :user => @user)
      @alarm_query.generate_alarm.should be_false 
    end
    it "creates alarms" do
      Rollcall::Alarm.all.should be_blank
      @alarm_query.generate_alarm
      Rollcall::Alarm.all.should_not be_blank
    end
  end
end