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
      @school=FactoryGirl.create(:rollcall_school)
    end
    it "should be valid" do
      @school.should be_valid
    end
  end

  describe "belongs_to" do
    before(:each) do
      @school=FactoryGirl.create(:rollcall_school)
    end
    context "district" do
      it "returns the district the school belongs to" do
        @school.district  
      end
    end
  end

  describe "has_many" do
    before(:each) do
      @school            = FactoryGirl.create(:rollcall_school)
      @school_daily_info = FactoryGirl.create(:rollcall_school_daily_info, :school_id => @school.id)
      @alarm             = FactoryGirl.create(:rollcall_alarm, :school_id => @school.id)
      @alarm_query       = FactoryGirl.create(:rollcall_alarm_query, :school_id => @school.id)
      @student           = FactoryGirl.create(:rollcall_student, :school_id => @school.id)
    end
    context "school_daily_infos" do
      it "returns a list of school daily info" do
        @school.school_daily_info.should include(@school_daily_info)
      end
    end
    context "alarms" do
      it "returns a list of alarms attached to this school" do
        @school.alarms.should include(@alarm)
      end
    end
    context "students" do
      it "returns a list of students associated with this school" do
        @school.students.should include(@student)
      end
    end
  end

  describe "before_create" do
    before(:each) do
      @school = FactoryGirl.create(:rollcall_school, :name => "School Name Number One", :display_name => '')
    end
    it "force set the display name" do
      @school.display_name.should == "School Name Number One"
    end
  end

  describe "named scope" do    
    context "in_alert" do
      it "returns schools with an alert" do
        @school=FactoryGirl.create(:rollcall_school)
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
        @school=FactoryGirl.create(:rollcall_school)
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
        @alarm = FactoryGirl.create(:rollcall_alarm)
        Rollcall::School.with_alarms.should include(@alarm.school)
      end
    end
  end

  describe "average_absence_rate" do
    before(:each) do
      @school_daily_info = FactoryGirl.create(:rollcall_school_daily_info)
    end
    it "returns a floating integer" do
      @school_daily_info.school.average_absence_rate.should be_kind_of(Float)
    end
    it "calculates the average absence rate for a school on a specific date" do
      avg_rate = @school_daily_info.total_absent.to_f/@school_daily_info.total_enrolled.to_f
      @school_daily_info.school.average_absence_rate.should == avg_rate
    end
  end
end
