Given /^I have a rollcall user$/ do
  step %Q{the following users exist:}, table(%{
    | Roll User    | user@example.com        | Rollcall       | Harris  | rollcall |})    
end

Then /^I see a video$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I click on a video$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I see a new video$/ do
  pending # express the regexp above with the code you wish you had
end
