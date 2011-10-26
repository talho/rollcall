# == Schema Information
#
# Table name: rollcall_students
#
#  id                 :integer(4)      not null, primary key
#  first_name         :string(255)
#  last_name          :string(255)
#  contact_first_name :string(255)
#  contact_last_name  :string(255)
#  address            :string(255)
#  zip                :string(255)
#  address            :string(255)
#  gender             :string(1)
#  phone              :string(255)
#  race               :integer(4)
#  school_id          :integer(4)
#  student_number     :string(255)
#  dob                :date
#  created_at         :datetime
#  updated_at         :datetime
require 'spec/spec_helper'
require File.dirname(__FILE__) + "/../factories.rb"

describe Rollcall::Student do
  before(:each) do
    @student=Factory(:rollcall_student)
  end
  describe "validations" do
    it "should be valid" do
      @student.should be_valid
    end
  end

  describe "belongs_to" do
    context "school" do
      it "returns the school associated with the student" do
        Rollcall::School.all.should include(@student.school)
      end
    end
  end
end