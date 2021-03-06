Given /^I have graphing data$/ do
  step %Q{the following entities exist:}, table(%{
    | Role         | Epidemiologist | rollcall |
    | Jurisdiction | Texas          |          |
    | Jurisdiction | Collin         |          |
  })
  step %Q{Texas is the parent jurisdiction of:}, table(%{
    | Collin  |
  })
  step %Q{Collin has the following school districts:}, table(%{                 
    | District1 | 101912 |
    | District2 | 68901  |
  })
  step %Q{"District1" has the following schools:}, table(%{
    | name                | school_number | tea_id    | school_type       | postal_code | gmap_lat   | gmap_lng    | gmap_addr                                                                      |
    | Anderson Elementary | 105           | 101912105 | Elementary School | 77035       | 29.6496766 | -95.4879978 | "Anderson Elementary School, 5727 Ludington Dr, Houston, TX 77035-4399, USA"   |
    | Ashford Elementary  | 273           | 101912273 | Elementary School | 77077       | 29.7477296 | -95.5988336 | "Ashford Elementary School, 1815 Shannon Valley Dr, Houston, TX 77077, USA"    |
    | Yates High School   | 20            | 101912020 | High School       | 77004       | 29.7232848 | -95.3546602 | "Yates High School: School Buildings, 3703 Sampson St, Houston, TX 77004, USA" |
  })
  step %Q{"District2" has the following schools:}, table(%{  
    | name                              | school_number | tea_id    | school_type       | postal_code | gmap_lat   | gmap_lng    | gmap_addr                                                                        |
    | Ector Junior High School          | 047           | 68901047  | High School       | 79763       | 31.831847  | -102.373438 | "Ector Junior High School, 809 West Clements Street, Odessa, TX 79763-4600"      |
    | Gale Pond Alamo Elementary School | 101           | 68901101  | Elementary School | 79761       | 31.871289  | -102.371464 | "Gale Pond Alamo Elementary School, 801 East 23rd Street, Odessa, TX 79761-1356" |
    | Austin Elementary School          | 102           | 68901102  | Elementary School | 79761       | 31.853575  | -102.373352 | "Austin Elementary School, 200 West 9th Street, Odessa, TX 79761-3956"           |
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
    | Nurse Betty  | nurse.betty@example.com | Epidemiologist    | Collin | rollcall |
  })
  step %Q{rollcall user "nurse.betty@example.com" has the following school districts assigned:}, table(%{
    | District1  |
    | District2  |
  })
  step %Q{rollcall user "nurse.betty@example.com" has the following schools assigned:}, table(%{
    | Anderson Elementary               |
    | Ashford Elementary                |
    | Yates High School                 |
    | Ector Junior High School          |
    | Gale Pond Alamo Elementary School |
    | Austin Elementary School          |
  })
  step %Q{"District1" has the following current school absenteeism data:}, table(%{
    | day | school_name         | total_enrolled | total_absent |
    | 1   | Anderson Elementary | 100            | 2            |
    | 2   | Anderson Elementary | 100            | 5            |
    | 1   | Ashford Elementary  | 100            | 1            |
    | 2   | Ashford Elementary  | 100            | 4            |
    | 1   | Yates High School   | 200            | 10           |
    | 2   | Yates High School   | 200            | 5            |
  })
  step %Q{"District1" has the following current student absenteeism data:}, table(%{
    | day | school_name         | age      | first_name | last_name | dob        | grade | gender | confirmed_ill | symptoms                    | student_number |
    | 1   | Anderson Elementary | 8        |            |           | 02/13/2003 | 2     | M      | true          | Cough,Temperature           |                |
    | 1   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 8        | John       | Dorian    | 02/13/2003 | 2     | M      | true          | Cough,Temperature,Chills    | 10055500       |
    | 2   | Anderson Elementary | 6        |            |           | 12/01/2005 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 6        |            |           | 09/11/2005 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 8        |            |           | 05/01/2003 | 2     | M      | true          | Congestion,Cough,Headache   |                |
    | 2   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 1   | Ashford Elementary  | 9        |            |           | 05/12/2002 | 3     | F      | true          | Influenza                   |                |
    | 2   | Ashford Elementary  | 8        |            |           | 01/02/2003 | 2     | F      | true          | Temperature                 |                |
    | 2   | Ashford Elementary  | 7        |            |           | 01/22/2004 | 2     | M      | true          | None                        |                |
    | 2   | Ashford Elementary  | 7        | Chris      | Turk      | 08/27/2004 | 2     | F      | true          | Temperature                 | 900800700      |
    | 2   | Ashford Elementary  | 8        |            |           | 02/12/2003 | 2     | M      | true          | Temperature,Cough           |                |
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
  })
  step %Q{"District2" has the following current school absenteeism data:}, table(%{
    | day | school_name                       | total_enrolled | total_absent |
    | 1   | Ector Junior High School          | 150            | 2            |
    | 2   | Ector Junior High School          | 150            | 5            |
    | 1   | Gale Pond Alamo Elementary School | 125            | 1            |
    | 2   | Gale Pond Alamo Elementary School | 125            | 4            |
    | 1   | Austin Elementary School          | 225            | 10           |
    | 2   | Austin Elementary School          | 225            | 5            |
  })
  step %Q{"District2" has the following current student absenteeism data:}, table(%{
    | day | school_name                       | age      | first_name | last_name | dob        | grade | gender | confirmed_ill | symptoms                    | student_number |
    | 1   | Ector Junior High School          | 8        |            |           | 02/13/2003 | 2     | M      | true          | Cough,Temperature           |                |
    | 1   | Ector Junior High School          | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2   | Ector Junior High School          | 8        | John       | Dorian    | 02/13/2003 | 2     | M      | true          | Cough,Temperature,Chills    | 10055500       |
    | 2   | Ector Junior High School          | 6        |            |           | 12/01/2005 | 1     | F      | false         |                             |                |
    | 2   | Ector Junior High School          | 6        |            |           | 09/11/2005 | 1     | F      | false         |                             |                |
    | 2   | Ector Junior High School          | 8        |            |           | 05/01/2003 | 2     | M      | true          | Congestion,Cough,Headache   |                |
    | 2   | Ector Junior High School          | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 1   | Gale Pond Alamo Elementary School | 9        |            |           | 05/12/2002 | 3     | F      | true          | Influenza                   |                |
    | 2   | Gale Pond Alamo Elementary School | 8        |            |           | 01/02/2003 | 2     | F      | true          | Temperature                 |                |
    | 2   | Gale Pond Alamo Elementary School | 7        |            |           | 01/22/2004 | 2     | M      | true          | None                        |                |
    | 2   | Gale Pond Alamo Elementary School | 7        | Chris      | Turk      | 08/27/2004 | 2     | F      | true          | Temperature                 | 900800700      |
    | 2   | Gale Pond Alamo Elementary School | 8        |            |           | 02/12/2003 | 2     | M      | true          | Temperature,Cough           |                |
    | 1   | Austin Elementary School          | 16       |            |           | 06/16/1995 | 10    | M      | false         |                             |                |
    | 1   | Austin Elementary School          | 18       |            |           | 04/26/1993 | 12    | F      | false         |                             |                |
    | 1   | Austin Elementary School          | 18       |            |           | 02/19/1993 | 12    | M      | false         |                             |                |
    | 1   | Austin Elementary School          | 15       |            |           | 08/26/1996 | 09    | M      | true          | Lethargy,Headache           |                |
    | 1   | Austin Elementary School          | 15       |            |           | 06/30/1996 | 09    | F      | false         |                             |                |
    | 1   | Austin Elementary School          | 14       |            |           | 01/02/1997 | 09    | M      | false         |                             |                |
    | 1   | Austin Elementary School          | 16       |            |           | 03/13/1995 | 10    | M      | true          | Sore Throat,Cough           |                |
    | 1   | Austin Elementary School          | 16       | Elliot     | Reid      | 11/17/1995 | 10    | M      | true          | Diarrhea,Vomiting           | 101202303      |
    | 1   | Austin Elementary School          | 17       |            |           | 09/24/1994 | 10    | M      | false         |                             |                |
    | 1   | Austin Elementary School          | 16       |            |           | 02/08/1995 | 10    | F      | true          | None                        |                |
    | 2   | Austin Elementary School          | 15       |            |           | 08/04/1996 | 09    | F      | false         |                             |                |
    | 2   | Austin Elementary School          | 17       |            |           | 12/13/1994 | 11    | M      | false         |                             |                |
    | 2   | Austin Elementary School          | 17       |            |           | 04/23/1994 | 10    | F      | false         |                             |                |
    | 2   | Austin Elementary School          | 18       |            |           | 10/17/1993 | 12    | M      | true          | Chills,Cough,Headache       |                |
    | 2   | Austin Elementary School          | 18       |            |           | 07/23/1993 | 12    | M      | true          | Chills,Temperature,Headache |                |
  })
  step %Q{I am logged in as "nurse.betty@example.com"}
  step %Q{I navigate to "Apps > Rollcall > Graphing"}
end

Then /^I should see all schools$/ do
  step %Q{I should see "Anderson Elementary,Ashford Elementary,Gale Pond Alamo Elementary School,Austin Elementary School,Yates High School,Ector Junior High School" within the results}
end

When /^I filter on school$/ do  
  step %Q{I select "Yates High School" from ext combo "school"}
  step %Q{I press "Submit"}
end

When /^I filter on school district$/ do
  step %Q{I select "District2" from ext combo "school_district"}
  step %Q{I press "Submit"}
end

When /^I filter on school type$/ do
  step %Q{I select "Elementary School" from ext combo "school_type"}
  step %Q{I press "Submit"}
end

When /^I filter on absenteeism and school type$/ do
  step %Q{I select "Confirmed Illness" from ext combo "absent"}
  step %Q{I select "Elementary School" from ext combo "school_type"}
  step %Q{I press "Submit"}
end

When /^I filter on absenteeism and school type to view average$/ do
  step %Q{I select "Confirmed Illness" from ext combo "absent"}
  step %Q{I select "Elementary School" from ext combo "school_type"}
  step %Q{I select "Average" from ext combo "Data Function"}
  step %Q{I press "Submit"}
end

When /^I filter on absenteeism and school type to view standard deviation$/ do
  step %Q{I select "Confirmed Illness" from ext combo "absent"}
  step %Q{I select "Elementary School" from ext combo "school_type"}
  step %Q{I select "Standard Deviation" from ext combo "data_func"}
  step %Q{I press "Submit"}
end

When /^I filter on date$/ do
  step %Q{I set "startdt" to "5" days from origin date}
  step %Q{I set "enddt" to "0" days from origin date}  
  step %Q{I press "Submit"}
end

When /^I filter on school district in school district mode$/ do
  step %Q{I press "School District"}
  step %Q{I select "District2" from ext combo "school_district"}
  step %Q{I press "Submit"}  
end

When /^I filter on multiple schools$/ do
  step %Q{I click x-accordion-hd "School Filter"}
  step %Q{I click school-name-list-item "Anderson Elementary"}
  step %Q{I click school-name-list-item "Yates High School"}
  step %Q{I press "Submit"}
end

When /^I filter on multiple school types$/ do
  step %Q{I click x-accordion-hd "School Filter"}
  step %Q{I click school-type-list-item "Elementary School"}
  step %Q{I click school-type-list-item "High School"}
  step %Q{I press "Submit"}
end

When /^I filter on multiple zips$/ do
  step %Q{I click x-accordion-hd "School Filter"}
  step %Q{I click zipcode-list-item "77077"}
  step %Q{I click zipcode-list-item "77004"}
  step %Q{I press "Submit"}
end

When /^I filter on multiple ages$/ do
  step %Q{I click x-accordion-hd "Demographic Filter"}
  step %Q{I click age-list-item "8"}
  step %Q{I click age-list-item "17"}
  step %Q{I press "Submit"}
end

When /^I filter on multiple grades$/ do
  step %Q{I click x-accordion-hd "Demographic Filter"}
  step %Q{I click grade-list-item "2"}
  step %Q{I click grade-list-item "10"}
  step %Q{I press "Submit"}
end

When /^I filter on multiple symptoms$/ do
  step %Q{I click x-accordion-hd "Symptom Filter"}
  step %Q{I click symptom-list-item "Chills"}
  step %Q{I click symptom-list-item "Influenza"}
  step %Q{I press "Submit"}
end

When /^I filter on male$/ do
  step %Q{I click x-accordion-hd "Demographic Filter"}
  step %Q{I select "Male" from ext combo "gender"}
  step %Q{I press "Submit"}
end

When /^I filter on female$/ do
  step %Q{I click x-accordion-hd "Demographic Filter"}
  step %Q{I select "Female" from ext combo "gender"}
  step %Q{I press "Submit"}
end

When /^I filter on school type, age, grade, gender, and symptoms$/ do
  step %Q{I click x-accordion-hd "School Filter"}
  step %Q{I click school-type-list-item "Elementary School"}
  step %Q{I click x-accordion-hd "Demographic Filter"}
  step %Q{I click age-list-item "8"}
  step %Q{I click grade-list-item "10"}
  step %Q{I select "Male" from ext combo "gender"}
  step %Q{I click x-accordion-hd "Symptom Filter"}
  step %Q{I click symptom-list-item "Influenza"}  
  step %Q{I press "Submit"}
end

When /^I view average$/ do
  step %Q{I select "Average" from ext combo "data_func"}
  step %Q{I press "Submit"}
end

When /^I view average (\d+)$/ do |arg1|
  step %Q{I select "Average #{arg1}" from ext combo "data_func"}
  step %Q{I press "Submit"}
end

When /^I view cusum$/ do
  step %Q{I select "Cusum" from ext combo "data_func"}
  step %Q{I press "Submit"}
end

When /^I view standard deviation$/ do
  step %Q{I select "Standard Deviation" from ext combo "data_func"}
  step %Q{I press "Submit"}
end
