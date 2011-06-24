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


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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

  describe "has_many" do
    before(:each) do
      @school=Factory(:rollcall_school)
    end
    context "school_daily_infos" do

    end
    context "student_daily_infos" do

    end
    context "alarms" do

    end
    context "alarm_queries" do

    end
    context "rrds" do

    end
    context "students" do

    end
  end

  describe "named scope" do
    @school=Factory(:rollcall_school)
    @school.school_daily_infos.create(
      :school_id => @school,
      :total_absent => 20,
      :total_enrolled => 100,
      :report_date => Date.today-1.days
    )
    @school.school_daily_infos.create(
      :school_id => @school,
      :total_absent => 10,
      :total_enrolled => 100,
      :report_date => Date.today-2.days
    )
    context "with_alarms" do
      it "returns schools with an alert" do
        Rollcall::School.in_alert.should include(@school)
        Rollcall::School.in_alert.size.should == 1
      end
      it "does not return schools that only have alerts older than 30 days" do
        oldschool=Factory(@school)
        oldschool.absentee_reports.create(:enrolled => 100, :absent => 20, :report_date => Date.today-31.days)
      end
    end
    context "in_alarms" do
      it "returns schools with alarms" do

      end
    end
  end
end
