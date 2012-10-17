Given /^I have rollcall users in a variety of roles$/ do   
  step %Q{the following users exist:}, table(%{
    | Admin Super  | super@example.com       | SuperAdmin     | Harris  | rollcall |
    | Admin Joe    | admin@example.com       | Admin          | Harris  | rollcall |
    | Roll User    | user@example.com        | Rollcall       | Harris  | rollcall |})
end

Given /^I have schools with reported rollcall data$/ do
  step %Q{Harris has the following school districts:}, table(%{
    | Houston | 101912 |
    | Hoho    | 101953 |
  })
  step %Q{"Houston" has the following schools:}, table(%{
    | name                | school_number | tea_id    | school_type       | postal_code | gmap_lat   | gmap_lng    | gmap_addr                                                                      |
    | Anderson Elementary | 105           | 101912105 | Elementary School | 77035       | 29.6496766 | -95.4879978 | "Anderson Elementary School, 5727 Ludington Dr, Houston, TX 77035-4399, USA"   |
    | Ashford Elementary  | 273           | 101912273 | Elementary School | 77077       | 29.7477296 | -95.5988336 | "Ashford Elementary School, 1815 Shannon Valley Dr, Houston, TX 77077, USA"    |
    | Yates High School   | 20            | 101912020 | High School       | 77004       | 29.7232848 | -95.3546602 | "Yates High School: School Buildings, 3703 Sampson St, Houston, TX 77004, USA" |
  })
  step %Q{"Houston" has the following current district absenteeism data:}, table(%{
    | day | total_enrolled | total_absent |
    | 1   | 400            | 13           |
    | 2   | 400            | 14           |
    | 3   | 400            | 13           |
    | 4   | 400            | 14           |
    | 5   | 400            | 13           |
    | 6   | 400            | 13           |
    | 7   | 400            | 13           |
    | 8   | 400            | 13           |  
  })
  step %Q{"Hoho" has the following current district absenteeism data:}, table(%{
    | day | total_enrolled | total_absent |
    | 8   | 400            | 13           |
    | 9   | 400            | 14           |
    | 10  | 400            | 13           |
    | 11  | 400            | 14           |
    | 12  | 400            | 13           |
    | 13  | 400            | 14           |
  })
  step %Q{"Houston" has the following current school absenteeism data:}, table(%{
    | day | school_name         | total_enrolled | total_absent |
    | 7   | Anderson Elementary | 100            | 2            |
    | 6   | Anderson Elementary | 100            | 5            |
    | 1   | Ashford Elementary  | 100            | 1            |
    | 2   | Ashford Elementary  | 100            | 4            |
    | 3   | Ashford Elementary  | 100            | 1            |
    | 4   | Ashford Elementary  | 100            | 4            |
    | 5   | Ashford Elementary  | 100            | 1            |
    | 6   | Ashford Elementary  | 100            | 4            |
    | 7   | Ashford Elementary  | 100            | 4            |
    | 8   | Ashford Elementary  | 100            | 4            |
    | 10  | Yates High School   | 200            | 10           |
    | 12  | Yates High School   | 200            | 5            |
  })
end

When /^I am logged in as a rollcall (user|admin|superadmin)?$/ do |privilege|
  if privilege == "user"
    step %Q{I am logged in as "user@example.com"}
  elsif privilege == "admin"
    step %Q{I am logged in as "admin@example.com"} 
  elsif privilege == "superadmin"
    step %Q{I am logged in as "super@example.com"}
  end
end

Then /^I do( not)? see the status link$/ do |notvisible|
  menu_array = ["Apps", "Rollcall", "Admin"]

  tb_button = menu_array.delete_at(0)
  waiter do
    step %Q{I should see "#{tb_button.strip}"}
  end
  waiter do
    step %Q{I press "#{tb_button}"}
  end
  sleep 0.1
  menu_array.each do |menu|
    waiter do
      step %Q{I click x-menu-item "#{menu}"}
    end
  end
  if notvisible
    step %Q{I should not see "Status"}
  else
    step %Q{I should see "Status"}
  end
end

Then /^I see schools that have not reported$/ do  
  Rollcall::SchoolDailyInfo.where("school_id = (?)", Rollcall::School.find_by_display_name('Ashford Elementary').id).each_with_index do |school, index|
    school.report_date = Date.today - index - 1
    school.save!
  end
  step %Q{I click x-menu-item "Status"}
  step %Q{I should see "Hoho"}
  step %Q{I should see "Anderson Elementary"}  
  step %Q{I should see "Yates High School"}
  step %Q{I should not see "Ashford Elementary"}  
  step %Q{I should not see "Houston" within ".school_district_grid"}
end

Then /^I receive an emailed status report$/ do
  step %Q{"super@example.com" should receive the email:}, table(%{
    | subject       | Rollcall Status Report                            |
    | body contains | School Districts that have not reported in 5 days |
    | body contains | Schools that have not reported in 5 days          |})
end

When /^backgroundrb has run the rollcall status update$/ do
  require 'workers/rollcall_status_updater'
  RollcallStatusUpdater.new().mail_status()  
end