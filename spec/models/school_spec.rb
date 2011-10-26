# == Schema Information
#
# Table name: rollcall_schools
#
#  id            :integer(4)      not null, primary key
#  display_name  :string(255)
#  postal_code   :string(255)
#  school_number :integer(4)
#  district_id   :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  tea_id        :integer
#  school_type   :string(255)
#  gmap_lat      :float
#  gmap_lng      :float
#  gmap_addr     :string

require 'spec/spec_helper'
require File.dirname(__FILE__) + "/../factories.rb"

describe Rollcall::School do

  describe "validations" do
    before(:each) do
      @school=Factory(:rollcall_school)
    end
    it "should be valid" do
      @school.should be_valid
    end
  end

  describe "belongs_to" do
    before(:each) do
      @school=Factory(:rollcall_school)
    end
    context "district" do
      it "returns the district the school belongs to" do
        @school.district  
      end
    end
  end

  describe "named scope" do    
    context "in_alert" do
      it "returns schools with an alert" do
        @school=Factory(:rollcall_school)
        @school.school_daily_infos.create(
          :school_id => @school,
          :total_absent => 50,
          :total_enrolled => 100,
          :report_date => Date.today-1.days
        )
        @school.school_daily_infos.create(
          :school_id => @school,
          :total_absent => 50,
          :total_enrolled => 100,
          :report_date => Date.today-2.days
        )
        Rollcall::School.in_alert.should include(@school)
        Rollcall::School.in_alert.size.should == 1
      end
      it "does not return schools that only have alerts older than 30 days" do
        @school=Factory(:rollcall_school)
        @school.school_daily_infos.create(
          :school_id => @school,
          :total_absent => 50,
          :total_enrolled => 100,
          :report_date => Date.today-31.days
        )
        Rollcall::School.in_alert.should_not include(@school)  
      end
    end
    context "with_alarms" do
      it "returns schools with alarms" do
        @alarm = Factory(:rollcall_alarm)
        Rollcall::School.with_alarms.should include(@alarm.school)
      end
    end
  end

  describe "average_absence_rate" do
    before(:each) do
      @school_daily_info = Factory(:rollcall_school_daily_info)
    end
    it "returns a floating integer" do
      @school_daily_info.school.average_absence_rate.should be_kind_of(Float)
    end
    it "calculates the average absence rate for a school on a specific date" do
      avg_rate = @school_daily_info.total_absent.to_f/@school_daily_info.total_enrolled.to_f
      @school_daily_info.school.average_absence_rate.should == avg_rate
    end
  end

  describe "search" do
    before(:each) do
      @school               = Factory(:rollcall_school)
      @user                 = Factory(:user)
      @user_school          = Factory(:rollcall_user_school, :user => @user, :school => @school)
      @user_school_district = Factory(:rollcall_user_school_district, :user => @user, :school_district => @school.district)
      @role_membership      = Factory(:role_membership, :user => @user, :jurisdiction => @school.district.jurisdiction)
    end
    it "returns a set of schools based on simple search" do
      Rollcall::School.search({:type => 'simple'}, @user).should_not be_blank
    end
    it "returns a set of schools based on advanced search" do
      Rollcall::School.search({:type => 'adv'}, @user).should_not be_blank
    end
  end
end
