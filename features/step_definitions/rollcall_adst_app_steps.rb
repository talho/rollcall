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
  image_files.split(',').each do |value|
    end_time = Time.now + 10.seconds
    begin
      graph = page.find(:xpath, ".//img[contains(concat(' ', @src, ' '), '#{value}')]")
    rescue Selenium::WebDriver::Error::ObsoleteElementError, Capybara::ElementNotFound
    end while graph.blank?
    graph.should_not be_nil
  end
end

Then /^"([^\"]*)" graphs has done loading$/ do |schools|
  And %{I should see graphs "#{schools}" within the results}
end

Then /^I close the "([^\"]*)" window$/ do |title|
  window_title = "Query Result for #{title}"
  page.find(:xpath, ".//div[contains(concat(' ', @class, ' '), 'x-tool x-tool-close') and ../span[text() = '#{window_title}']]").click 
end

Then /^I click the "([^\"]*)" tool on the "([^\"]*)" window$/ do |tool, title|
  window_title = "Query Result for #{title}"
  page.find(:xpath, ".//div[contains(concat(' ', @class, ' '), 'x-tool x-tool-#{tool}') and ../span[text() = '#{window_title}']]").click
end

Then /^I should not see the "([^\"]*)" window$/ do |window_title|
  page.should_not have_xpath(".//span[contains(text() = 'Query Result for #{window_title}')]")
end

Then /^I wait for documents to be processed$/ do
  sleep 5
end

Then /^the "([^\"]*)" graph result is pinned$/ do |title|
  page.find(:xpath, ".//div[contains(concat(' ', @class, ' '), 'x-panel-pinned')]")
end