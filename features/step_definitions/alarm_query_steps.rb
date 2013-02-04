Given /^I have alarm query data$/ do
  step %Q{the following entities exist:}, table(%{
    | Role         | Epidemiologist  | rollcall |
    | Jurisdiction | Texas           |          |
    | Jurisdiction | Harris          |          |
  })
  step %Q{Texas is the parent jurisdiction of:}, table(%{
    | Harris |
  })
  step %Q{Harris has the following school districts:}, table(%{
    | Houston | 101912 |
  })
  step %Q{"Houston" has the following schools:}, table(%{
    | name                | school_number | tea_id    | school_type       | postal_code | gmap_lat   | gmap_lng    | gmap_addr                                                                      |
    | Anderson Elementary | 105           | 101912105 | Elementary School | 77035       | 29.6496766 | -95.4879978 | "Anderson Elementary School, 5727 Ludington Dr, Houston, TX 77035-4399, USA"   |
    | Ashford Elementary  | 273           | 101912273 | Elementary School | 77077       | 29.7477296 | -95.5988336 | "Ashford Elementary School, 1815 Shannon Valley Dr, Houston, TX 77077, USA"    |
    | Yates High School   | 20            | 101912020 | High School       | 77004       | 29.7232848 | -95.3546602 | "Yates High School: School Buildings, 3703 Sampson St, Houston, TX 77004, USA" |
  })
  step %Q{the following symptoms exist:}, table(%{
    | icd9_code | name                    |
    | 032.9     | Diphtheria              |
    | 034.0     | Strep Throat            |
    | 034.1     | Scarlet Fever           |
    | 038.11    | Staph Aureus            |
    | 041.00    | Streptococcal Infection |
    | 052.9     | Chicken Pox             |
    | 056.9     | Rubella                 |
    | 055.9     | Measles                 |
    | 072.9     | Mumps                   |
    | 322.9     | Meningitis              |
    | 323.9     | Encephalitis            |
    | 462       | Sore Throat             |
    | 478.19    | Congestion              |
    | 487.1     | Influenza               |
    | 573.3     | Hepatitis               |
    | 780.60    | Temperature             |
    | 780.64    | Chills                  |
    | 780.79    | Lethargy                |
    | 784.0     | Headache                |
    | 786.2     | Cough                   |
    | 787.03    | Vomiting                |
    | 787.91    | Diarrhea                |
    | 0         | None                    |
  })
  step %Q{the following users exist:}, table(%{
    | Nurse Betty  | nurse.betty@example.com | Epidemiologist    | Harris | rollcall |
  })
  step %Q{rollcall user "nurse.betty@example.com" has the following school districts assigned:}, table(%{
    | Houston |
  })
  step %Q{rollcall user "nurse.betty@example.com" has the following schools assigned:}, table(%{
    | Anderson Elementary |
    | Ashford Elementary  |
    | Yates High School   |
  })
  step %Q{"Houston" has the following current school absenteeism data:}, table(%{
    | day | school_name         | total_enrolled | total_absent |
    | 1   | Anderson Elementary | 100            | 5            |
    | 2   | Anderson Elementary | 100            | 4            |
    | 3   | Anderson Elementary | 100            | 3            |
    | 4   | Anderson Elementary | 100            | 2            |
    | 1   | Ashford Elementary  | 100            | 1            |
    | 2   | Ashford Elementary  | 100            | 4            |
    | 3   | Ashford Elementary  | 100            | 5            |
    | 4   | Ashford Elementary  | 100            | 3            |
    | 1   | Yates High School   | 200            | 10           |
    | 2   | Yates High School   | 200            | 5            |
    | 3   | Yates High School   | 200            | 4            |
    | 4   | Yates High School   | 200            | 4            |
  })
  step %Q{"Houston" has the following current student absenteeism data:}, table(%{
    | day | school_name         | age      | first_name | last_name | dob        | grade | gender | confirmed_ill | symptoms                    | student_number |
    | 1   | Anderson Elementary | 8        | John       | Dorian    | 02/13/2003 | 2     | M      | true          | Cough,Temperature,Chills    | 10055500       |
    | 1   | Anderson Elementary | 6        |            |           | 12/01/2005 | 1     | F      | false         |                             |                |
    | 1   | Anderson Elementary | 6        |            |           | 09/11/2005 | 1     | F      | false         |                             |                |
    | 1   | Anderson Elementary | 8        |            |           | 05/01/2003 | 2     | M      | true          | Congestion,Cough,Headache   |                |
    | 1   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 8        | John       | Dorian    | 02/13/2003 | 2     | M      | true          | Cough,Temperature,Chills    | 10055500       |
    | 2   | Anderson Elementary | 6        |            |           | 12/01/2005 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 6        |            |           | 09/11/2005 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 8        |            |           | 05/01/2003 | 2     | M      | true          | Congestion,Cough,Headache   |                |
    | 3   | Anderson Elementary | 7        |            |           | 02/15/2004 | 1     | M      | true          | Cough                       |                |
    | 3   | Anderson Elementary | 7        |            |           | 04/05/2004 | 1     | M      | true          | Cough                       |                |
    | 3   | Anderson Elementary | 7        |            |           | 03/25/2004 | 1     | F      | false         |                             |                |
    | 4   | Anderson Elementary | 8        |            |           | 02/13/2003 | 2     | M      | true          | Cough,Temperature           |                |
    | 4   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |    
    | 1   | Ashford Elementary  | 9        |            |           | 05/12/2002 | 3     | F      | true          | Influenza                   |                |
    | 2   | Ashford Elementary  | 8        |            |           | 01/02/2003 | 2     | F      | true          | Temperature                 |                |
    | 2   | Ashford Elementary  | 7        |            |           | 01/22/2004 | 2     | M      | true          | None                        |                |
    | 2   | Ashford Elementary  | 7        | Chris      | Turk      | 08/27/2004 | 2     | F      | true          | Temperature                 | 900800700      |
    | 2   | Ashford Elementary  | 8        |            |           | 02/12/2003 | 2     | M      | true          | Temperature,Cough           |                |
    | 3   | Ashford Elementary  | 8        |            |           | 01/02/2003 | 2     | F      | true          | Temperature                 |                |
    | 3   | Ashford Elementary  | 7        |            |           | 01/22/2004 | 2     | M      | true          | None                        |                |
    | 3   | Ashford Elementary  | 7        | Chris      | Turk      | 08/27/2004 | 2     | F      | true          | Temperature                 | 900800700      |
    | 3   | Ashford Elementary  | 8        |            |           | 02/12/2003 | 2     | M      | true          | Temperature,Cough           |                |
    | 3   | Ashford Elementary  | 8        |            |           | 02/12/2003 | 2     | M      | true          | Temperature,Cough           |                |
    | 4   | Ashford Elementary  | 8        |            |           | 04/22/2003 | 2     | F      | false         |                             |                |
    | 4   | Ashford Elementary  | 7        |            |           | 01/12/2004 | 1     | M      | false         |                             |                |
    | 4   | Ashford Elementary  | 8        |            |           | 05/12/2003 | 2     | M      | true          | Cough,Temperature           |                |
    | 1   | Yates High School   | 16       |            |           | 06/16/1995 | 10    | M      | false         |                             |                |
    | 1   | Yates High School   | 18       |            |           | 04/26/1993 | 12    | F      | false         |                             |                |
    | 1   | Yates High School   | 18       |            |           | 02/19/1993 | 12    | M      | false         |                             |                |
    | 1   | Yates High School   | 15       |            |           | 08/26/1996 | 09    | M      | true          | Lethargy,Headache           |                |
    | 1   | Yates High School   | 15       |            |           | 06/30/1996 | 09    | F      | false         |                             |                |
    | 1   | Yates High School   | 14       |            |           | 01/02/1997 | 09    | M      | false         |                             |                |
    | 1   | Yates High School   | 16       |            |           | 03/13/1995 | 10    | M      | true          | Sore Throat,Cough           |                |
    | 1   | Yates High School   | 16       | Elliot     | Reid      | 11/17/1995 | 10    | M      | true          | Diarrhea,Vomiting           | 101202303      |
    | 1   | Yates High School   | 17       |            |           | 09/24/1994 | 10    | M      | false         |                             |                |
    | 1   | Yates High School   | 16       |            |           | 02/08/1995 | 10    | F      | true          | None                        |                |
    | 2   | Yates High School   | 15       |            |           | 08/04/1996 | 09    | F      | false         |                             |                |
    | 2   | Yates High School   | 17       |            |           | 12/13/1994 | 11    | M      | false         |                             |                |
    | 2   | Yates High School   | 17       |            |           | 04/23/1994 | 10    | F      | false         |                             |                |
    | 2   | Yates High School   | 18       |            |           | 10/17/1993 | 12    | M      | true          | Chills,Cough,Headache       |                |
    | 2   | Yates High School   | 18       |            |           | 07/23/1993 | 12    | M      | true          | Chills,Temperature,Headache |                |
    | 3   | Yates High School   | 15       |            |           | 08/04/1996 | 09    | F      | false         |                             |                |
    | 3   | Yates High School   | 17       |            |           | 12/13/1994 | 11    | M      | false         |                             |                |
    | 3   | Yates High School   | 17       |            |           | 04/23/1994 | 10    | F      | false         |                             |                |
    | 3   | Yates High School   | 18       |            |           | 10/17/1993 | 12    | M      | true          | Chills,Cough,Headache       |                |
    | 4   | Yates High School   | 16       |            |           | 03/08/1995 | 10    | M      | true          | Chills,Cough                |                |
    | 4   | Yates High School   | 17       |            |           | 06/21/1994 | 10    | F      | true          | Lethargy,Headache           |                |
    | 4   | Yates High School   | 17       |            |           | 02/11/1994 | 10    | F      | false         |                             |                |
    | 4   | Yates High School   | 18       |            |           | 11/09/1993 | 12    | F      | true          | Temperature,Cough           |                |
  })
  step %Q{I am logged in as "nurse.betty@example.com"}
  step %Q{I navigate to the ext dashboard page}
  step %Q{I navigate to "Apps > Rollcall > Alarms"}
  step %Q{I wait for the panel to load}
end

When /^I create a new alarm query$/ do
  step %Q{I press "Create New Alarm Query"}
  step %Q{I fill in "Name" with "Example Query"}
  step %Q{I click school-name-list-item "Anderson Elementary"}    
  page.execute_script("Ext.getCmp('querydeviation').setValue(0,1,false);")  
  step %Q{I press "Create Alarm Query"}
end

Then /^I see a new alarm query$/ do
  step %Q{I should see "Example Query"}
end

Given /^I have an alarm query$/ do
  aq = Rollcall::AlarmQuery.new(:deviation => 1, :name => "Example Query", :user_id => current_user.id, :start_date => 60.days.ago, :school_ids => [Rollcall::School.find_by_display_name("Anderson Elementary").id])
  aq.save
  step %Q{I press "Refresh"}
end

Then /^I delete an alarm query$/ do
  step %Q{I click ".query-delete"}
  step %Q{I press "Yes"}  
end

Then /^I should not see an alarm query$/ do
  step %Q{I should not see "Example Query"}
end

When /^edit an alarm query$/ do
  step %Q{I click ".query-edit"}
  step %Q{I click school-name-list-item "Yates High School"}
  step %Q{I press "Submit Edits"}
end

Given /^I have an active alarm query$/ do
  aq = Rollcall::AlarmQuery.new(:deviation => 1, :name => "Example Query", :user_id => current_user.id, :start_date => 60.days.ago, :school_ids => [Rollcall::School.find_by_display_name("Anderson Elementary").id])
  aq.save
  step %Q{I press "Refresh"}
  step %Q{I click ".query-toggle"}
  step %Q{I press "OK"}  
end
