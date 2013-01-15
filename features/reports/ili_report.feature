Feature: Test the ILI report generation

  In order to see the flu status of my schools for the last week
  As a rollcall user
  I want to generate a report with a breakdown of enrolled, absent, ili, and confirmed

  Background:
    Given I am logged in as a nonpublic rollcall user

  Scenario: Be able to generate an ILI report via the UI
    When I run an ILI report
    Then my ILI report should be generated

  Scenario: ILI report generates correct data
    Given I have reportable ILI data
    When I run an ILI report
    Then my ILI report should have the expected data
    And I my ILI report should display correctly

  Scenario: ILI report does not display data from school districts that are not my own
    Given I have reportable ILI data
    And there exists non-reportable ILI data
    When I run an ILI report
    Then my ILI report should have the expected data
