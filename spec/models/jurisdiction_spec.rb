require 'spec/spec_helper'
require File.dirname(__FILE__) + "/../factories.rb"

describe Jurisdiction do
  before(:each) do
    @jurisdiction = Factory(:jurisdiction)
  end

  describe "validations" do
    it "should be valid" do
      @jurisdiction.should be_valid
    end
  end

  describe "has_many" do
    context "school_districts" do
      before(:each) do
        @school_district = Factory(:rollcall_school_district, :jurisdiction => @jurisdiction)
      end
      it "returns a list of school district within selected jurisdiction" do
        @jurisdiction.school_districts.should include(@school_district)
      end
    end
  end
end