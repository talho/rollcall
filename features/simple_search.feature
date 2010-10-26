Feature: Execute Simple Search Queries
  In order to execute simple search queries
  As a Rollcall user
  I should be able to select from a list of simple search options, construct and execute my query

Background:
  Given the following entities exist:
    | Role         | SchoolNurse     |
    | Role         | Epidemiologist  |
    | Jurisdiction | Texas           |
    | Jurisdiction | Houston         |
    | Jurisdiction | Tarrant         |
  And Texas is the parent jurisdiction of:
    | Houston | Tarrant |
  And Houston has the following school districts:
    | Houston ISD |
  And "Houston ISD" has the following schools:
    | Name        | SchoolID | Level |
    | LEWIS ES    | 1        | ES    |
    | SOUTHMAYDES | 2        | ES    |
    | BERRY ES    | 3        | ES    |
  And the following users exist:
    | Nurse Betty  | nurse.betty@example.com | SchoolNurse    | Houston |
    | Nurse Betty  | nurse.betty@example.com | Rollcall       | Houston |
    | Epi Smith    | epi.smith@example.com   | Epidemiologist | Houston |
    | Epi Smith    | epi.smith@example.com   | Rollcall       | Houston |
    | Normal Epi   | normal.epi@example.com  | Epidemiologist | Houston |
    | No Schools   | noschools@example.com   | Rollcall       | Tarrant |
  And "Houston ISD" has the following current absenteeism data:
    | Day   | SchoolName  | Enrolled | Absent |
    | 0     | LEWIS ES    | 500      | 5      |
    | -1    | LEWIS ES    | 500      | 10     |
    | -2    | LEWIS ES    | 500      | 15     |
    | -3    | LEWIS ES    | 500      | 5      |
    | -4    | LEWIS ES    | 500      | 60     |
    | 0     | SOUTHMAYDES | 100      | 2      |
    | -1    | SOUTHMAYDES | 100      | 5      |
    | -2    | SOUTHMAYDES | 100      | 15     |
    | -3    | SOUTHMAYDES | 100      | 10     |
    | -4    | SOUTHMAYDES | 100      | 7      |
    | 0     | BERRY ES    | 200      | 10     |
    | -1    | BERRY ES    | 200      | 15     |
    | -2    | BERRY ES    | 200      | 5      |
    | -3    | BERRY ES    | 200      | 10     |
    | -4    | BERRY ES    | 200      | 10     |
  And I am logged in as "nurse.betty@example.com"  

Scenario: User runs a simple search against absenteeism to view the raw data
  When I navigate to the rollcall search page
  And I check "Absenteeism"
  And I fill in "Percentage" with "20"
  And I click "Submit"
  And I should see a graph called "all_abs_raw.png" within ext panel "Results"

Scenario: User runs a simple search against a school to view the raw data
  When I go to the rollcall search page
  And I click on "School"
  And I select "Lewis ES" from "School"
  And I click "Submit"
  And I should see a graph called "lewis_es_raw.png" within ext panel "Results"
  
Scenario: User runs a simple search against a school type to view the raw data
  When I go to the rollcall search page
  And I click on "School Type"
  And I select "Elementary" from "School Type"
  And I click "Submit"
  And I should see a graph called "es_raw.png" within ext panel "Results"

Scenario: User runs a comparison search against all schools using school
  When I go to the rollcall search page
  And I click on "School"
  And I select "Lewis ES" from "School"
  And I select "Ratio Compare" from "Data Function"
  And I click "Submit"
  And I should see a graph called "lewis_es_ratio.png"

Scenario: User runs a comparison search against all schools using school type
  When I go to the rollcall search page
  And I click on "School Type"
  And I select "Elementary" from "School Type"
  And I select "Ratio Compare" from "Data Function"
  And I click "Submit"
  And I should see a graph called "lewis_es_ratio.png"

Scenario: User runs a simple search using the time slider
  When I go to the rollcall search page
  And I click on "School Type"
  And I select "Elementary" from "School Type"
  And I click on "Set Time Range"
  And I set "Begin Time" to "0" days from start of school year
  And I set "End Time" to "10" days from start of school year
  And I click on "Submit"
  And I should see a graph called "es_time_raw.png"
  
Scenario: User runs a simple search against absenteeism and school type to view the raw data
  When I go to the rollcall search page
  And I click on "Absenteeism"
  And I select "Confirmed" from "Absenteeism"
  And I click on "School Type"
  And I select "Elementary" from "School Type"
  And I click "Submit"
  And I should see a graph called "es_abs_raw.png" within ext panel "Results"

Scenario: User runs a simple search against absenteeism and school type to view the average data
  When I go to the rollcall search page
  And I click on "Absenteeism"
  And I fill in "Confirmed" from "Absenteeism"
  And I click on "School Type"
  And I select "Elementary" from "School Type"
  And I select "Average" from "Data Function"
  And I click "Submit"
  And I should see a graph called "es_abs_avg.png" within ext panel "Results"


Scenario: User runs a simple search against absenteeism and scope to view the standard deviation
  When I go to the rollcall search page
  And I click on "Absenteeism"
  And I fill in "Confirmed" from "Absenteeism"
  And I click on "School Type"
  And I select "Elementary" from "School Type"
  And I select "Standard Deviation" from "Data Function"
  And I click "Submit"
  And I should see a graph called "es_abs_std.png" within ext panel "Results"