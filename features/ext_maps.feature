Feature: Maps
  In order to interact with maps
  As a Rollcall user
  I should be able to view maps and change the viewing date
  
Background:
  Given I have map data
  
Scenario: User loads the map
  When I open the map
  Then map is displayed

Scenario: User changes the date
  Given I open the map
  When I change the map date
  Then I can go through all the dates