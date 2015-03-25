require 'rails_helper'

RSpec.describe "alarms/new", type: :view do
  before(:each) do
    assign(:alarm, Alarm.new(
      :user => nil,
      :attendance_deviation => false,
      :ili_threshold => 1,
      :confirmed_ili_threshold => 1,
      :measles_threshold => 1
    ))
  end

  it "renders new alarm form" do
    render

    assert_select "form[action=?][method=?]", alarms_path, "post" do

      assert_select "input#alarm_user_id[name=?]", "alarm[user_id]"

      assert_select "input#alarm_attendance_deviation[name=?]", "alarm[attendance_deviation]"

      assert_select "input#alarm_ili_threshold[name=?]", "alarm[ili_threshold]"

      assert_select "input#alarm_confirmed_ili_threshold[name=?]", "alarm[confirmed_ili_threshold]"

      assert_select "input#alarm_measles_threshold[name=?]", "alarm[measles_threshold]"
    end
  end
end
