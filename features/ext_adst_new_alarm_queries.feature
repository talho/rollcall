Feature: Alarm Queries
  In order to create and set alarms
  As a Rollcall user
  I should be able to create alarm queries based off absenteeism severity/deviation from a set of search results
  
Background: 
  Given I have alarm query data
  
Scenario: User creates an Alarm Query
  When I create a new alarm query
  Then I see a new alarm query

Scenario: User creates an Alarm Query with specific threshold

Scenario: User deletes an existing Alarm Query
  Given I have an alarm query
  When I delete an alarm query
  Then I should not see an alarm query

Scenario: User toggles Alarm Query

Scenario: User Edits an Alarm Query

Scenario: GIS