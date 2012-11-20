Feature: Tutorial Page

  In order to see tutorials
  As all users
  I should be able to view and the playing tutorial
  
  Background:
    Given I have a rollcall user
    Given I am logged in as a rollcall user
    
  Scenario: Video is Loaded by Default
    Then I see a video
  
  Scenario: Clicking a video loads new video
    When I click on a video
    Then I see a new video