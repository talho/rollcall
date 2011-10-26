# == Schema Information
#
# Table name: rollcall_school_daily_infos
#
#  id              :integer      not null, primary key
#  school_id       :integer      not null, foreign key
#  total_absent    :integer      not null
#  total_enrolled  :integer      not null
#  report_date     :date         not null
#  created_at      :datetime
#  updated_at      :datetime
#
require 'spec/spec_helper'
require File.dirname(__FILE__) + "/../factories.rb"

describe Rollcall::SchoolDailyInfo do
  before(:each) do
    @student           = Factory(:rollcall_student)
    @school_daily_info = Factory(:rollcall_school_daily_info, :school => @student.school, :total_absent => 15)
  end
  describe "validations" do
    it "should be valid" do
      @school_daily_info.should be_valid
    end
  end

  describe "belongs_to" do
    context "school" do
      it "returns the associated school object" do
        Rollcall::School.all.should include(@school_daily_info.school)
      end
    end
  end

  describe "named_scope" do
    context "for_date" do
      it "returns a school daily info object for an existing date" do
        Rollcall::SchoolDailyInfo.for_date(Time.now).should include(@school_daily_info)
      end
    end
    context "for_date_range" do
      it "returns an array of daily school information for a specific date range" do
        Rollcall::SchoolDailyInfo.for_date_range((Time.now - 1.day), Time.now).should include(@school_daily_info)
      end
    end
    context "recent" do
      it "returns the most recent school daily information based off a limit value" do
        Rollcall::SchoolDailyInfo.recent(1).should include(@school_daily_info) 
      end
    end
    context "absences" do
      it "returns all school daily information whose absent rate is over 10%" do
        Rollcall::SchoolDailyInfo.absences.should include(@school_daily_info)
      end
    end
    context "with_severity" do
      it "returns all school daily information matching the passed severity level" do
        Rollcall::SchoolDailyInfo.with_severity(:medium).should include(@school_daily_info)
      end
    end
  end

  describe "absentee_percentage" do
    it "returns a floating integer" do
      @school_daily_info.absentee_percentage.should be_kind_of(Float)
    end
    it "returns the absentee_percentage of a specific date" do
      @school_daily_info.absentee_percentage.should == ((@school_daily_info.total_absent.to_f / @school_daily_info.total_enrolled.to_f) * 100).to_f.round(2)
    end
  end

  describe "severity" do
    it "returns a string specifying low severity" do
      @school_daily_info = Factory(:rollcall_school_daily_info, :school => @student.school, :total_absent => 5)
      @school_daily_info.severity.should == "low"
    end
    it "returns a string specifying medium severity" do
      @school_daily_info.severity.should == "medium"
    end
    it "returns a string specifying high severity" do
      @school_daily_info = Factory(:rollcall_school_daily_info, :school => @student.school, :total_absent => 25)
      @school_daily_info.severity.should == "high"
    end
  end
end