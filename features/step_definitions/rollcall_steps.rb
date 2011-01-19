When /^I drop the following file in the rollcall directory\:$/ do |erb_file_template|
  rollcall_drop_dir = File.join(Rails.root, "tmp", "rollcall")
  Dir.ensure_exists(rollcall_drop_dir)
  file=ERB.new(erb_file_template.gsub(",", "\t")).result
  f=File.open(File.join(rollcall_drop_dir, 'Attendance_test.txt'), 'w')
  f.write(file)
  f.close
end

When /^the rollcall background worker processes$/ do
  RollcallDataImporter.process_uploads
end

Then /^I should not see a rollcall alert for "([^\"]*)"$/ do |school|
  page.should_not have_xpath(".//li[@class='school']", :text => school)
  #response.should_not have_selector(".school", :content => school)
end

Then /^I should see an "([^\"]*)" rollcall summary for "([^\"]*)" with (.*) absenteeism$/ do |severity, school, percent|
  page.should have_xpath(".//ul[@class='rollcall_summary']")
  page.should have_xpath(".//li[@class='school']", :text => school)
  page.should have_xpath(".//li[@class='school_alert #{severity}']")
  page.should have_xpath(".//span[@class='absence']", :text => percent)
end

Then /^I should see school data for "([^\"]*)"$/ do |school|
  page.find(".school_data") do |elm|
    elm.find(".school", :content => school)
  end
#  response.should have_selector(".school_data") do |elm|
#    elm.should have_selector(".school", :content => school)
#  end
end