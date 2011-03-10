# == Schema Information
#
# Table name: rollcall_alarms
#
#  id                 :integer(4)      not null, primary key
#  school_id          :integer(4)
#  alarm_query_id     :integer(4)
#  deviation          :float
#  severity           :float
#  absentee_rate      :float
#  report_date        :date
#  created_at         :datetime
#  updated_at         :datetime
#

require 'spec_helper'

describe Alarm do
  before(:each) do
    @valid_attributes = {
      :absentee_report_id => 1,
      :severity => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Rollcall::Alarm.create!(@valid_attributes)
  end
end
