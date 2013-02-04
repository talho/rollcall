Feature: Graphing Search
  In order to find graph data
  As a rollcall user
  I should be able to search for data using filters
  
Background:
  Given I have graphing data
  
Scenario: User searches
  When I press "Submit"
  Then I should see all schools

Scenario: User filters on school
  When I filter on school
  Then I should see "Yates High School" within the results

Scenario: User filters on school type
  When I filter on school type
  Then I should see "Anderson Elementary,Ashford Elementary,Gale Pond Alamo Elementary School,Austin Elementary School" within the results

Scenario: User filters on school district
  When I filter on school district
  Then I should see "Austin Elementary School,Ector Junior High School,Gale Pond Alamo Elementary School" within the results

Scenario: User filters on absenteeism and school type
  When I filter on absenteeism and school type
  Then I should see "Anderson Elementary,Ashford Elementary,Gale Pond Alamo Elementary School,Austin Elementary School" within the results

Scenario: User filters on absenteeism and school type to view average
  When I filter on absenteeism and school type to view average
  Then I should see "Anderson Elementary,Ashford Elementary,Gale Pond Alamo Elementary School,Austin Elementary School" within the results

Scenario: User filters on absenteesim and school type to view standard deviation
  When I filter on absenteeism and school type to view standard deviation
  Then I should see "Anderson Elementary,Ashford Elementary,Gale Pond Alamo Elementary School,Austin Elementary School" within the results

Scenario: User filters on date
  When I filter on date
  Then I should see all schools

Scenario: User filters on school district in school district mode
  When I filter on school district in school district mode
  Then I should see "District2" within the results

Scenario: User filters on multiple schools
  When I filter on multiple schools
  Then I should see "Anderson Elementary,Yates High School" within the results

Scenario: User filters on multiple school types
  When I filter on multiple school types
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results

Scenario: User filters on multiple zips
  When I filter on multiple zips
  Then I should see "Ashford Elementary,Yates High School" within the results

Scenario: User filters on multiple ages
  When I filter on multiple ages
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results

Scenario: User filters on multiple grades
  When I filter on multiple grades
  Then I should see "Ector Junior High School,Gale Pond Alamo Elementary School,Austin Elementary School,Anderson Elementary,Ashford Elementary,Yates High School" within the results

Scenario: User filters on multiple symptoms
  When I filter on multiple symptoms
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  
Scenario: User filters on male
  When I filter on male
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  
Scenario: User filters on female
  When I filter on female
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  
Scenario: User filters on school type, age, grade, gender, and symptoms
  When I filter on school type, age, grade, gender, and symptoms
  Then I should see "Anderson Elementary,Ashford Elementary,Austin Elementary School,Gale Pond Alamo Elementary School" within the results
  
Scenario: User views average
  When I view average
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  
Scenario: User views average 30
  When I view average 30
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results

Scenario: User views average 60
  When I view average 60
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  
Scenario: User views cusum
  When I view cusum
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  
Scenario: User views standard deviation
  When I view standard deviation
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  