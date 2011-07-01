# == Schema Information
#
# Table name: school_district_daily_infos
#
#  id                 :integer(4)      not null, primary key
#  report_date        :date
#  absentee_rate      :float
#  total_enrollment   :integer(4)
#  total_absent       :integer(4)
#  school_district_id :integer(4)
#
require 'spec/spec_helper'

describe Rollcall::SchoolDistrictDailyInfo do
  before(:each) do
    @school_district_daily_info = Factory(:rollcall_school_district_daily_info)
  end
  describe "validations" do
    it "should be valid" do
      @school_district_daily_info.should be_valid
    end
  end

  describe "belongs_to" do
    context "school_district" do
      it "returns the associated school district" do
        Rollcall::SchoolDistrict.all.should include(@school_district_daily_info.school_district)
      end
    end
  end

  describe "validates_presence_of" do
    context "school_district" do
      it "validates the existence of school_district_id when creating a SchoolDistrictDailyInfo object" do
        result = Rollcall::SchoolDistrictDailyInfo.create(
          :report_date => Time.now,
          :absentee_rate => 0.0,
          :total_enrollment => 100,
          :total_absent => 10
        )
        result.save.should == false
      end
    end
    context "report_date" do
      it "validates the existence of report_date when creating a SchoolDistrictDailyInfo object" do
        result = Rollcall::SchoolDistrictDailyInfo.create(
          :school_district_id => 1,
          :absentee_rate => 0.0,
          :total_enrollment => 100,
          :total_absent => 10
        )
        result.save.should == false
      end
    end
  end

  describe "named_scope" do
    context "for_date" do
      it "returns school district absentee information for a specific date" do
        Rollcall::SchoolDistrictDailyInfo.for_date(Time.now).should include(@school_district_daily_info)
      end
    end
  end

  describe "update_stats" do
    it "updates total_enrollment, total_absent and absentee_rate by date and school district id" do
      @school = Factory(:rollcall_school)
      @school_daily_info = Factory(:rollcall_school_daily_info, :school => @school)
      @school_district_daily_info = Factory(:rollcall_school_district_daily_info,
                                            :total_enrollment => nil,
                                            :total_absent => nil,
                                            :absentee_rate => nil,
                                            :school_district_id => @school.district_id,
                                            :report_date => Time.now)
      @school_district_daily_info.total_enrollment.should be_blank
      @school_district_daily_info.total_absent.should be_blank
      @school_district_daily_info.absentee_rate.should be_blank
      @school_district_daily_info.update_stats Time.now, @school.district_id
      @school_district_daily_info.total_enrollment.should_not be_blank
      @school_district_daily_info.total_absent.should_not be_blank
      @school_district_daily_info.absentee_rate.should_not be_blank
      Rollcall::SchoolDistrictDailyInfo.all.should include(@school_district_daily_info)
    end
  end
end