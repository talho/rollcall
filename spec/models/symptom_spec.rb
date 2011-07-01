# == Schema Information
#
# Table name: rollcall_symptoms
#
# id,         :integer not null, primary
# icd9_code,  :string(255)
# name,       :string(255)
require 'spec/spec_helper'

describe Rollcall::Symptom do 
  before(:each) do
    @symptom=Factory(:rollcall_symptom)
  end
  describe "validations" do
    it "should be valid" do
      @symptom.should be_valid
    end
  end
end