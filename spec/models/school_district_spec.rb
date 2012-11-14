# == Schema Information
#
# Table name: school_districts
#
#  id              :integer(4)      not null, primary key
#  name            :string(255)
#  jurisdiction_id :integer(4)
#  district_id     :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec/spec_helper'
require File.dirname(__FILE__) + "/../factories.rb"

describe Rollcall::SchoolDistrict do
  describe "validations" do
    before(:each) do
      @school_district=FactoryGirl.create(:rollcall_school_district)
    end
    it "should be valid" do
      @school_district.should be_valid
    end
  end

  describe "belongs_to" do
    before(:each) do
      @school_district=FactoryGirl.create(:rollcall_school_district)
    end
    context "jurisdiction" do
      it "returns a jurisdiction" do
        @school_district.jurisdiction.should_not be_blank
      end
    end
  end

  desribe "has_many" do
    before(:each) do
      @school_district=FactoryGirl.create(:rollcall_school_district)
      @school=FactoryGirl.create(:rollcall_school, :district_id => @school_district.id)
      @daily_info=FactoryGirl.create(:rollcall_school_district_daily_info, :school_district_id => @school_district.id)
    end
    context "schools" do
      it "returns a list of schools for this school district" do
        @school_district.schools.should include(@school)
      end
    end    
  end
  describe "average_absence_rate" do
    before(:each) do
      @school_district_daily_info = FactoryGirl.create(:rollcall_school_district_daily_info)
    end
    it "returns a floating integer" do
      @school_district_daily_info.school_district.average_absence_rate.should be_kind_of(Float)
    end
    it "calculates the average absence rate on an entire school district based on a specific date" do
      @school_district_daily_info.school_district.average_absence_rate.should == @school_district_daily_info.absentee_rate  
    end
  end


  describe "recent_absentee_rates" do
    before(:each) do
      @school           = FactoryGirl.create(:rollcall_school)
      @schoo_daily_info = FactoryGirl.create(:rollcall_school_daily_info, :school => @school)
    end
    it "returns an array of absentee rates(average) for a specific number of days" do
      avg = @school.district.recent_absentee_rates 1
      avg.should_not be_blank
      avg.length.should == 1
      avg.first.should == 10
    end
  end

  describe "zipcodes" do
    before(:each) do
      @school = FactoryGirl.create(:rollcall_school)
    end
    it "returns an array of unique zipcodes within a school district" do
      @school.district.zipcodes.should be_kind_of(Array)
      @school.district.zipcodes.should_not be_blank
      @school.district.zipcodes.should include(@school.postal_code)
    end
  end

  describe "school_types" do
    before(:each) do
      @school = FactoryGirl.create(:rollcall_school)
    end
    it "returns an array of unique school types within a school district" do
      @school.district.school_types.should be_kind_of(Array)
      @school.district.school_types.should_not be_blank
      @school.district.school_types.should include(@school.school_type)
    end
  end

end
