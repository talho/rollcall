Given /^rollcall user "([^\"]*)" has the following schools assigned:$/ do |user, table|
  table.raw.each do |row|
    Rollcall::UserSchool.create(
      :user_id   => User.find_by_email(user).id,
      :school_id => Rollcall::School.find_by_display_name(row[0]).id
    )
  end
end

Given /^rollcall user "([^\"]*)" has the following school districts assigned:$/ do |user, table|
  table.raw.each do |row|
    Rollcall::UserSchoolDistrict.create(
      :user_id            => User.find_by_email(user).id,
      :school_district_id => Rollcall::SchoolDistrict.find_by_name(row[0]).id
    )
  end
end

Then /^rollcall user "([^\"]*)" should not receive an email$/ do |email|
  find_email(email).should be_nil
end

Given /^I am logged in as a nonpublic rollcall user$/ do
  step %Q{the following entities exists:}, table([
    %w{ Jurisdiction Texas}
  ])
  step %Q{the following users exist:}, table(%{
    | Its Me |  me@example.com | Health Officer | Texas | rollcall |
  })

  step %Q{I am logged in as "me@example.com"}
end
