Feature: Importing automated data
  In order to facilitate reliable surveillance of school attendance data
  As an outside system
  I want to upload data for automatic import into Rollcall

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
      | DisplayName         | TeaId     | SchoolId | SchoolType        |
      | Lewis Elementary    | 101912194 | 194      | Elementary School |
      | Berry Elementary    | 101912109 | 109      | Elementary School |
    And the following users exist:
      | Nurse Betty  | nurse.betty@example.com | Rollcall    | Houston |
    And "Houston ISD" has the following current absenteeism data:
      | Day   | SchoolName          | Enrolled | Absent |
      | 1     | Lewis Elementary    | 500      | 10     |
      | 2     | Lewis Elementary    | 500      | 15     |
      | 3     | Lewis Elementary    | 500      | 5      |
      | 4     | Lewis Elementary    | 500      | 60     |
      | 1     | Berry Elementary    | 200      | 20     |
      | 2     | Berry Elementary    | 200      | 10     |
      | 3     | Berry Elementary    | 200      | 10     |
      | 4     | Berry Elementary    | 200      | 10     |


  Scenario: Uploading a file
    Given I am logged in as "nurse.betty@example.com"
    When I drop the following file in the rollcall directory:
    """
    <%= Date.today.strftime("%Y-%m-%d 00:00:00")%>,101912194,500,50
    <%= Date.today.strftime("%Y-%m-%d 00:00:00")%>,101912109,200,30
    """
    And the rollcall background worker processes
    When I go to the ext dashboard page
    And I navigate to "Rollcall > Schools"
    And I select "Lewis Elementary" from "School"
    And I press "Choose"
    Then I should see an absenteeism graph with the following:
    | data        | nil,nil,12.0,1.0,3.0,2.0,10.0     |
    | data-label  | Lewis Elementary                  |
    | title       | Absenteeism Rates (Last 7 days)   |