Then /^I click the alarm group "([^\"]*)"$/ do |title|
  page.find(:xpath, ".//div[contains(concat(' ', @class, ' '), 'rollcall_alarm_icon') and text() = '#{title}']").click
end

Then /^I click the last alarm within the "([^\"]*)" alarm group$/ do |title|
  page.find(:xpath, ".//div[contains(concat(' ', @class, ' '), 'x-grid-group-body') and ..//div[contains(concat(' ', @class, ' '), 'rollcall_alarm_icon') and text() = '#{title}']]/div[last()]").click
end

Then /^I delete the alarms for "([^\"]*)"$/ do |alarm_group_name|
  e_o_r  = false
  begin
    step %{I click the last alarm within the "#{alarm_group_name}" alarm group}
    step %{I wait for the panel to load}
    step %{I should see "Delete Alarm"}
    step %{I press "Delete Alarm"}
    step %{I should see "Are you sure you want to delete this alarm?"}
    step %{I press "Yes"}
    step %{I wait for the panel to load}
  rescue
    e_o_r = true
  end while(e_o_r == false)
end