# == Schema Information
#
# Table name: rollcall_alarms
#
#  id                 :integer(4)      not null, primary key
#  school_id          :integer(4)
#  alarm_query_id     :integer(4)
#  alarm_severity     :string
#  deviation          :float
#  severity           :float
#  absentee_rate      :float
#  report_date        :date
#  created_at         :datetime
#  updated_at         :datetime
#  alarm_severity     :string
#  ignore_alarm       :boolean

require 'spec/spec_helper'

describe Rollcall::Alarm do
  describe "validations" do
    before(:each) do
      @alarm=Factory(:rollcall_alarm)
    end
    it "should be valid" do
      @alarm.should be_valid
    end
  end

  describe "belongs_to" do
    before(:each) do
      @alarm=Factory(:rollcall_alarm)
    end
    context "school" do
      it "returns a school object" do
        @alarm.school.should_not be_blank
      end
    end
    context "alarm_query" do
      it "returns an alarm query object" do
        @alarm.alarm_query.should_not be_blank
      end
    end
  end
end