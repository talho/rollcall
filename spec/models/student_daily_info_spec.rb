# == Schema Information
#
# Table name: rollcall_student_daily_infos
#
#  id                :integer(4)      not null, primary key
#  cid               :string
#  report_date       :date
#  report_time       :datetime
#  health_year       :string(10)
#  grade             :integer(11)
#  student_id,       :integer
#  date_of_onset,    :date
#  temperature,      :float
#  symptoms,         :string
#  in_school,        :boolean
#  released,         :boolean
#  diagnosis,        :string
#  treatment,        :string
#  follow_up,        :date
#  doctor,           :string
#  doctor_address,   :string
#  confirmed_illness :tinyint(1)
#  created_at        :datetime
#  updated_at        :datetime
require 'spec/spec_helper'

describe Rollcall::StudentDailyInfo do
  before(:each) do
    @student_daily_info       = Factory(:rollcall_student_daily_info)
    @student_reported_symptom = Factory(:rollcall_student_reported_symptoms, :student_daily_info => @student_daily_info)
  end
  
  describe "validations" do
    it "should be valid" do
      @student_daily_info.should be_valid
    end
  end

  describe "has_and_belongs_to_many" do
    context "symptoms" do
      it "returns all of the symptoms associated with the student daily information record" do
        @student_daily_info.symptoms.each do |s| Rollcall::Symptom.all.should include(s) end
      end
    end
  end
  
  describe "belongs_to" do
    context "student" do
      it "returns the student associated with the student daily information record" do
        Rollcall::Student.all.should include(@student_daily_info.student)
      end
    end
  end
end
