Feature: Alarm Queries
  In order to create and set alarms
  As a Rollcall user
  I should be able to create alarm queries based off absenteeism severity/deviation from a set of search results
  
Background: 
  Given I have alarm query data
  
Scenario: User creates an Alarm Query
  When I create a new alarm query
  Then I see a new alarm query

Scenario: User deletes an existing Alarm Query
  Given I have an alarm query
  When I delete an alarm query
  Then I should not see an alarm query

Scenario: User toggles Alarm Query
  Given I have an alarm query
  When I click ".query-toggle"  
  And I press "OK"  
  Then I should see "Anderson Elementary" within ".forum-title"

Scenario: User Edits an Alarm Query
  Given I have an alarm query
  When edit an alarm query
  Then I should see "Yates High School"  
  
Scenario: GIS
  Given I have an active alarm query
  When I press "GIS"
  Then I should see "My Schools in an Alarm State"