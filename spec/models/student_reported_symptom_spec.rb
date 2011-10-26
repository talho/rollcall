# == Schema Information
#
# Table name: rollcall_student_reported_symptoms
#
#  id,                    :integer(4) not null, primary key
#  symptom_id,             :integer(4)  not null, foreign key
#  student_daily_info_id,  :integer(4)  not null, foreign key
#
require 'spec/spec_helper'
require File.dirname(__FILE__) + "/../factories.rb"

describe Rollcall::StudentReportedSymptom do
  before(:each) do
    @student_reported_symptom = Factory(:rollcall_student_reported_symptoms)
  end

  describe "validations" do
    it "should be valid" do
      @student_reported_symptom.should be_valid
    end
  end

  describe "belongs_to" do
    context "symptom" do
      it "returns the symptom associated with the student" do
        Rollcall::Symptom.all.should include(@student_reported_symptom.symptom)
      end
    end
    context "student_daily_info" do
      it "returns the student daily information record associated with the reported symptom" do
        Rollcall::StudentDailyInfo.all.should include(@student_reported_symptom.student_daily_info)
      end
    end
  end
end