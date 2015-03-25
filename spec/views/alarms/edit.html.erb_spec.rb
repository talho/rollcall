require 'rails_helper'

RSpec.describe "alarms/edit", type: :view do
  before(:each) do
    @alarm = assign(:alarm, Alarm.create!(
      :user => nil,
      :attendance_deviation => false,
      :ili_threshold => 1,
      :confirmed_ili_threshold => 1,
      :measles_threshold => 1
    ))
  end

  it "renders the edit alarm form" do
    render

    assert_select "form[action=?][method=?]", alarm_path(@alarm), "post" do

      assert_select "input#alarm_user_id[name=?]", "alarm[user_id]"

      assert_select "input#alarm_attendance_deviation[name=?]", "alarm[attendance_deviation]"

      assert_select "input#alarm_ili_threshold[name=?]", "alarm[ili_threshold]"

      assert_select "input#alarm_confirmed_ili_threshold[name=?]", "alarm[confirmed_ili_threshold]"

      assert_select "input#alarm_measles_threshold[name=?]", "alarm[measles_threshold]"
    end
  end
end
