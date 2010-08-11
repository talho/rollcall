When /^I drop the following file in the rollcall directory\:$/ do |erb_file_template|
  rollcall_drop_dir=File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'rollcall')
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
  within(:css, ".school") { page.should_not have_content(school) }
end

Then /^I should see an "([^\"]*)" rollcall summary for "([^\"]*)" with (.*) absenteeism$/ do |severity, school, percent|
  school_node = find(:css, ".rollcall_summary .school", :content => school)
  assert school_node.find(:css, ".#{severity} .absence").text == percent
end

Then /^I should see school data for "([^\"]*)"$/ do |school|
  assert find(:css, ".school_data .school", :content => school) != nil
end
