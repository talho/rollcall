require 'rails_helper'

RSpec.describe "alarms/show", type: :view do
  before(:each) do
    @alarm = assign(:alarm, Alarm.create!(
      :user => nil,
      :attendance_deviation => false,
      :ili_threshold => 1,
      :confirmed_ili_threshold => 2,
      :measles_threshold => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
