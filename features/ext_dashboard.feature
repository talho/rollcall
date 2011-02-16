Feature: Displaying User Specified queries in a dashboard
  In order to view commonly accessed queries
  As a Rollcall user
  I should see the queries I specified on the dashboard

#TODO: Add more given data for
Background:
  Given the following entities exist:
    | Role         | SchoolNurse     |
    | Role         | Epidemiologist  |
    | Jurisdiction | Texas           |
    | Jurisdiction | Houston         |
  And Texas is the parent jurisdiction of:
    | Houston |
  And Houston has the following school districts:
    | Houston ISD |
  And "Houston ISD" has the following schools:
    | Name        | SchoolID | Level |
    | LEWIS ES    | 1        | ES    |
    | BERRY ES    | 3        | ES    |
  And the following users exist:
    | Nurse Betty  | nurse.betty@example.com | Rollcall    | Houston |
  And "Houston ISD" has the following current absenteeism data:
    | Day   | SchoolName  | Enrolled | Absent |
    | -1    | LEWIS ES    | 500      | 10     |
    | -2    | LEWIS ES    | 500      | 15     |
    | -3    | LEWIS ES    | 500      | 5      |
    | -4    | LEWIS ES    | 500      | 60     |
    | -1    | BERRY ES    | 200      | 20     |
    | -2    | BERRY ES    | 200      | 10     |
    | -3    | BERRY ES    | 200      | 10     |
    | -4    | BERRY ES    | 200      | 10     |
  And the school "BERRY ES" has a 30 day average absenteeism "Saved Query One Graph" graph on the dashboard
  And the school "BERRY ES" has a 30 day raw absenteeism "Saved Query Two Graph" graph on the dashboard
  And the school "LEWIS ES" has a 30 day average absenteeism "Saved Query Three Graph" graph on the dashboard
  And the school "LEWIS ES" has a 30 day raw absenteeism "Saved Query Four Graph" graph on the dashboard
  And I am logged in as "nurse.betty@example.com"

Scenario: User sees their saved queries on dashboard
  When I go to the rollcall page
  Then I should see "Saved Query One Graph"
  And I should see "Saved Query Two Graph"
  And I should see "Saved Query Three Graph"
  And I should see "Saved Query Four Graph"

Scenario: User can jump from graph on dashboard to query interface
  Given this should be implemented

Scenario: User can close and remove graphs from the dashboard
  When I go to the rollcall dashboard page
  Then I should see "Saved Query One Graph"
  And I close ext panel "Saved Query One Graph"
  And I am on the rollcall dashboard page
  And I should not see "Saved Query One graph"

Scenario: User can collapse and expand graphs on the dashboard
  When I go to the rollcall dashboard page
  Then I should see "Saved Query One Graph"
  And I can see the graph image for "Saved Query One Graph"
  And I collapse ext panel "Saved Query One Graph"
  And I am on the rollcall dashboard page
  And I should not see the graph image for "Saved Query One Graph"
  When I expand ext panel "Saved Query One Graph"
  Then I can see the graph image for "Saved Query One Graph"

Scenario: User creates query and marks for view on dashboard
  Given this should be implemented

Scenario: User can order graphs by dragging and dropping
  Given my dashboard is configured for 2x3 graphs
  When I go to the rollcall page
  And I hover over ext panel "Saved Query One Page"
  Then I should see the move mouse cursor
  And I should see the graphs in the following order:
    | Saved Query One Graph   | Saved Query Two Graph  |
    | Saved Query Three Graph | Saved Query Four Graph |
  When I drag ext panel "Saved Query One Graph" to ext panel "Saved Query Three Graph"
  Then I should see the graphs in the following order:
    | Saved Query Three Graph | Saved Query Two Graph  |
    | Saved Query One Graph   | Saved Query Four Graph |
  And I drag ext panel "Saved Query Two Graph" to ext panel "Saved Query Four Graph"
  Then I should see the graphs in the following order:
    | Saved Query Three Graph | Saved Query Four Graph |
    | Saved Query One Graph   | Saved Query Two Graph  |
  And I drag ext panel "Saved Query Three Graph" to ext panel slot 6
  Then I should see "Saved Query Three Graph" in ext panel slot 6
  And I should not see "" in ext panel slot 1

Scenario: User can order graphs by clicking arrow icons
  Given my dashboard is configured for 2x3 graphs
  When I go to the rollcall page
  And I should see the graphs in the following order:
    | Saved Query One Graph   | Saved Query Two Graph  |
    | Saved Query Three Graph | Saved Query Four Graph |
  And I click ext panel "Saved Query One Graph"
  And I click right on the joypad
  Then I should see the graphs in the following order:
    | Saved Query Two Graph   | Saved Query One Graph  |
    | Saved Query Three Graph | Saved Query Four Graph |
  And I click ext panel "Saved Query Two Graph"
  And I click down on the joypad
  Then I should see the graphs in the following order:
    | Saved Query Three Graph | Saved Query One Graph  |
    | Saved Query Two Graph   | Saved Query Four Graph |
  And I click ext panel "Saved Query Four Graph"
  And I click left on the joypad
  Then I should see the graphs in the following order:
    | Saved Query Three Graph | Saved Query One Graph |
    | Saved Query Four Graph  | Saved Query Two Graph |
  And I click ext panel "Saved Query Two Graph"
  And I click up on the joypad
  Then I should see the graphs in the following order:
    | Saved Query Three Graph | Saved Query Two Graph |
    | Saved Query Four Graph  | Saved Query One Graph |  


Scenario: User attempts to order graphs that can not be re-ordered
  Given my dashboard is configured for 2x3 graphs
  When I go to the rollcall page
  And I should see the graphs in the following order:
    | Saved Query One Graph   | Saved Query Two Graph  |
    | Saved Query Three Graph | Saved Query Four Graph |
  And I click ext panel "Saved Query One Graph"
  And I click left on the joypad
  Then I should see the graphs in the following order:
    | Saved Query One Graph   | Saved Query Two Graph  |
    | Saved Query Three Graph | Saved Query Four Graph |
  And I click ext panel "Saved Query Two Graph"
  And I click up on the joypad
  Then I should see the graphs in the following order:
    | Saved Query One Graph   | Saved Query Two Graph  |
    | Saved Query Three Graph | Saved Query Four Graph |
  And I click ext panel "Saved Query Three Graph"
  And I click left on the joypad
  Then I should see the graphs in the following order:
    | Saved Query One Graph   | Saved Query Two Graph  |
    | Saved Query Three Graph | Saved Query Four Graph |
  And I click ext panel "Saved Query Four Graph"
  And I click right on the joypad
  Then I should see the graphs in the following order:
    | Saved Query One Graph   | Saved Query Two Graph  |
    | Saved Query Three Graph | Saved Query Four Graph |

Scenario: User can see recent alarms indicator on dashboard
  Given nurse.betty@example.com has the following graph alerts
    | Name        | Threshold | Severity | School   |
    | Alert One   | 7-12      | Low      | LEWIS ES |
    | Alert Two   | 7-12      | Low      | BERRY ES |
    | Alert Three | 12-15     | Medium   | BERRY ES |
  When I go to the rollcall page
  And I should see "Recent Alarms (3)"


Scenario: User can see and read and graphs from third-party survaillance systems
  Given this is implemented

#TODO: Research how to do scenario below, possibly embedd image link into dashboard
Scenario: User can add third-party survaillance system graphs to the dashboard
  Given this is implemented

