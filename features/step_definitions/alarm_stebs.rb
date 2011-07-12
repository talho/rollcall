Then /^I click the alarm group "([^\"]*)"$/ do |title|
  page.find(:xpath, ".//div[contains(concat(' ', @class, ' '), 'rollcall_alarm_icon') and text() = '#{title}']").click
end

Then /^I click the last alarm within the "([^\"]*)" alarm group$/ do |title|
  page.find(:xpath, ".//div[contains(concat(' ', @class, ' '), 'x-grid-group-body') and ..//div[contains(concat(' ', @class, ' '), 'rollcall_alarm_icon') and text() = '#{title}']]/div[last()]").click
  #page.find(:xpath, ".//div[contains(concat(' ', @class, ' '), 'x-grid3-row x-grid3-row-alt x-grid3-row-last') and ../../div[contains(concat(' ', @class, ' '), 'rollcall_alarm_icon') and text() = '#{title}']]").click
end