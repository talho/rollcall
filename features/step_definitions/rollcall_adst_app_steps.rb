Then /^I set "([^\"]*)" to "([^\"]*)" days from origin date$/ do |date_field_name,days|
  current_time = Time.gm(Date.today.year, Date.today.month, Date.today.day,0,0).at_beginning_of_week - 1.week
  date         = current_time - days.to_i.days
  step %{I fill in "#{date_field_name}" with "#{date.month}/#{date.day}/#{date.year}"}
end

Then /^I should see dated graphs for schools "([^\"]*)" starting "([^\"]*)" days and ending "([^\"]*)" days from origin date$/ do |schools,start_days,end_days|
  sleep 5
  current_time      = Time.gm(Date.today.year, Date.today.month, Date.today.day,0,0).at_beginning_of_week - 1.week
  start_date        = current_time - start_days.to_i.days
  end_date          = current_time - end_days.to_i.days
  string_start_date = DateTime.strptime("#{start_date.month}/#{start_date.day}/#{start_date.year}", "%m/%d/%Y").strftime("%s")
  string_end_date   = DateTime.strptime("#{end_date.month}/#{end_date.day}/#{end_date.year}", "%m/%d/%Y").strftime("%s")
  schools.split(',').each do |value|
    page.body.should have_xpath(".//path[contains(concat(' ', @class, ' '), 'area')]")
  end
end


#Then /^I should not see graphs "([^\"]*)" within the results$/ do |image_files|
#  image_files.split(',').each do |value|
#    begin
#      #graph = page.find(:xpath, ".//img[contains(concat(' ', @src, ' '), '#{value}')]")
#      graph = page.find(:xpath, ".//object")
#    rescue Selenium::WebDriver::Error::ObsoleteElementError, Capybara::ElementNotFound
#    end while !graph.blank?
#    graph.should be_nil
#  end
#end

Then /^I should not see "([^\"]*)" within the results$/ do |result_name|
  result_name.split(',').each do |value|
    using_wait_time(5) do
      step %Q{I should not see "Query Result for #{value}"}
    end
  end
end

Then /^I should see "([^\"]*)" within the results$/ do |result_name|
  result_name.split(',').each do |value|
    using_wait_time(5) do
      step %Q{I should see "Query Result for #{value}"}
    end
  end
end

#Then /^I should see graphs "([^\"]*)" within the results$/ do |image_files|
#  image_files.split(',').each do |value|
#    begin
#      #graph = page.find(:xpath, ".//img[contains(concat(' ', @src, ' '), '#{value}')]")
#      graph = page.find(:xpath, ".//object")
#    rescue Selenium::WebDriver::Error::ObsoleteElementError, Capybara::ElementNotFound
#    end while graph.blank?
#    graph.should_not be_nil
#  end
#end

Then /^"([^\"]*)" graphs has done loading$/ do |schools|
  step %{I should see "#{schools}" within the results}
end

Then /^I close the "([^\"]*)" window$/ do |title|
  page.find(:xpath, ".//div[contains(concat(' ', @class, ' '), 'x-tool x-tool-close') and ../span[text() = '#{title}']]").click
end

Then /^I click the "([^\"]*)" tool on the "([^\"]*)" window$/ do |tool, title|
  page.find(:xpath, ".//div[contains(concat(' ', @class, ' '), 'x-tool x-tool-#{tool}') and ../span[text() = '#{title}']]").click
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

Then /^I wait for the panel to load$/ do
  sleep 2
end

When /^I click the "([^\"]*)" marker for school "([^\"]*)"$/ do |marker_type, school_name|
  page.execute_script("
    var gmap_window = Ext.getCmp('gmap_#{marker_type}_window').get(0);
    var marker = null
    Ext.each(gmap_window.markers, function(m){ if(m.title == '#{school_name}'){
      marker = m;
      return false;
    }});    
    google.maps.event.trigger(marker, 'click');
  ")
end

Then /^I should see "([^\"]*)" within grid "([^\"]*)" in column "([^\"]*)"$/ do |value, selector, column_id|
  e_o_r   = false
  begin
    step %{I should see "#{value.strip}" within ".#{selector}"}
    e_o_r = true
  rescue
    begin
      page.find(:css, ".#{selector} table .x-btn-icon.x-item-disabled .x-tbar-page-next")
      e_o_r = true
    rescue
      step %{I click x-tbar-page-next "" within ".#{selector}"}
      step %{I wait for the panel to load}
    end
  end while(e_o_r == false)
  step %{I should see "#{value.strip}" in column "#{column_id}" within "#{selector}"}
end

Then /^my rollcall export should be visible$/ do
  step %Q{I should see "rollcall_export.#{Time.now.strftime("%m-%d-%Y")}.csv" within ".document-file-icon-view"}
end

Then /^I Submit and wait$/ do
  page.driver.options[:resynchronize] = false
  click_button "Submit"
  sleep 20  
  page.driver.options[:resynchronize] = true
end

Then /^I malicously try to call neighbors$/ do
  script = "window.xhr = new XMLHttpRequest(); " +
    "window.xhr.open('GET','/rollcall/get_neighbors.json?school_districts[]=1&school_districts[]=2', true);" +
    "window.xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');" +    
    "window.xhr.send();"
  page.execute_script(script)
end

Then /^the malicious neighbor call fails$/ do
  resp = page.evaluate_script('window.xhr.responseText')
  resp.should =~ Regexp.new(/\"success\":false/)
end