Feature: School
  In order to view absentee and ILI surveillance data for a school
  As a permitted user
  I should see absentee and ILI graphs when I browse to the Rollcall School View screen

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
      | Name                 | DisplayName | SchoolID | Level |
      | Lewis Elementary     | LEWIS ES    | 1        | ES    |
      | Southmayd Elementary | SOUTHMAYDES | 2        | ES    |
      | Berry Elementary     | BERRY ES    | 3        | ES    |
    And the following users exist:
      | Nurse Betty  | nurse.betty@example.com | SchoolNurse    | Houston |
      | Nurse Betty  | nurse.betty@example.com | Rollcall       | Houston |
      | Epi Smith    | epi.smith@example.com   | Epidemiologist | Houston |
      | Epi Smith    | epi.smith@example.com   | Rollcall       | Houston |
      | Normal Epi   | normal.epi@example.com  | Epidemiologist | Houston |
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

  Scenario: Viewing the School View screen
    Given I am logged in as "nurse.betty@example.com"
    When I go to the ext dashboard page
    And I navigate to "Rollcall > Schools"
    And I wait for the "object" element to load
    Then I should see school data for "BERRY ES"

  Scenario: Accessing the School View in the Rollcall application as a non-rollcall user
    Given I am logged in as "normal.epi@example.com"
    When I go to the ext dashboard page
    And I navigate to "Rollcall > Schools"
    Then I should see "You have not been given access to the Rollcall application."
    And I should see "RollCall is a school surveillance application that will"

  Scenario: Selecting a district and school from the dropdown
    Given I am logged in as "nurse.betty@example.com"
    When I go to the ext dashboard page
    And I navigate to "Rollcall > Schools"
    And I select "LEWIS ES" from "School"
    And I press "Choose"
    And I wait for the "object" element to load
    Then I should see school data for "LEWIS ES"

  Scenario: Viewing the first school
    Given I am logged in as "nurse.betty@example.com"
    When I go to the ext dashboard page
    And I navigate to "Rollcall > Schools"
    And I wait for the "object" element to load
    Then I should see school data for "BERRY ES"
    And I should see an absenteeism graph with the following:
      | data-label  | Berry Elementary                 |
      | data        | nil,nil,5.0,5.0,2.5,7.5,5.0  |

  Scenario: Viewing the second school
    Given I am logged in as "nurse.betty@example.com"
    When I go to the ext dashboard page
    And I navigate to "Rollcall > Schools"
    And I wait for the "object" element to load
    And I select "LEWIS ES" from "School"
    And I press "Choose"
    And I wait for the "object" element to load
    Then I should see an absenteeism graph with the following:
      | data-label | Lewis Elementary                 |
      | data       | nil,nil,12.0,1.0,3.0,2.0,1.0 |
