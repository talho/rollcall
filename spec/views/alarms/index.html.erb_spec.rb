require 'rails_helper'

RSpec.describe "alarms/index", type: :view do
  before(:each) do
    assign(:alarms, [
      Alarm.create!(
        :user => nil,
        :attendance_deviation => false,
        :ili_threshold => 1,
        :confirmed_ili_threshold => 2,
        :measles_threshold => 3
      ),
      Alarm.create!(
        :user => nil,
        :attendance_deviation => false,
        :ili_threshold => 1,
        :confirmed_ili_threshold => 2,
        :measles_threshold => 3
      )
    ])
  end

  it "renders a list of alarms" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
