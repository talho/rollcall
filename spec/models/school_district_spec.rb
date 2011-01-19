# == Schema Information
#
# Table name: rollcall_school_districts
#
#  id              :integer(4)      not null, primary key
#  name            :string(255)
#  jurisdiction_id :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Rollcall::SchoolDistrict do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Rollcall::SchoolDistrict.create!(@valid_attributes)
  end
end
