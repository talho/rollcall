Feature: Alarms
  In order to interact with alarms
  As a Rollcall user
  I should be able to create/edit alarms based off of alarm queries
  
Background:
  Given I have alarm data

Scenario: User ignore an alarm
  When I press "Ignore"
  Then the alarm is ignored

Scenario: User un-ignores an alarm
  Given I have an ignored alarm
  When I press "Un-Ignore"
  Then the alarm is not ignored

Scenario: User deletes an alarm
  When I press "Delete"
  Then the alarm is deleted