Given /^I have a rollcall user$/ do
  step %Q{the following users exist:}, table(%{
    | Roll User    | user@example.com        | Rollcall       | Harris  | rollcall |})    
end

Then /^I see a video$/ do
  step %Q{I navigate to "Apps>Rollcall>Tutorials"}
  page.should have_selector('object[data]')
end

When /^I click on a video$/ do
  step %Q{I navigate to "Apps>Rollcall>Tutorials"}  
  @og_video = page.first('object[data]')['data']
  page.all(:css, '.youtubelistitem')[3].click    
end

Then /^I see a new video$/ do
  new_video = page.first('object[data]')['data']
  @og_video.should_not == new_video
end

When /^I click on a new video$/ do
  @second_video = page.first('object[data]')['data']
  page.all(:css, '.youtubelistitem')[2].click
end

Then /^the new video plays$/ do
  new_video = page.first('object[data]')['data']
  @og_video.should_not == new_video
  @second_video.should_not == new_video
end
