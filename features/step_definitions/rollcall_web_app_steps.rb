Then /^I set "([^\"]*)" to "([^\"]*)" days from origin date$/ do |date_field_name,days|
  current_time = Time.gm(Date.today.year, Date.today.month, Date.today.day,0,0).at_beginning_of_week - 1.week
  date         = current_time - days.to_i.days
  And %{I fill in "#{date_field_name}" with "#{date.month}/#{date.day}/#{date.year}"}
end

Then /^I should see dated graphs for schools "([^\"]*)" starting "([^\"]*)" days and ending "([^\"]*)" days from origin date$/ do |schools,start_days,end_days|
  current_time      = Time.gm(Date.today.year, Date.today.month, Date.today.day,0,0).at_beginning_of_week - 1.week
  start_date        = current_time - start_days.to_i.days
  end_date          = current_time - end_days.to_i.days
  string_start_date = Time.parse("#{start_date.month}/#{start_date.day}/#{start_date.year}").strftime("%s")
  string_end_date   = Time.parse("#{end_date.month}/#{end_date.day}/#{end_date.year}").strftime("%s")
  schools.split(',').each do |value|
    image_name = "DF-Raw_ED-#{string_end_date.to_i}_SD-#{string_start_date.to_i}_#{value}_c_absenteeism.png"
    page.should have_xpath(".//img[contains(concat(' ', @src, ' '), '#{image_name}')]")
  end
end

Then /^I should see graphs "([^\"]*)" within the results$/ do |image_files|
  sleep 2
  image_files.split(',').each do |value|
    page.should have_xpath(".//img[contains(concat(' ', @src, ' '), '#{value}')]")
  end
end