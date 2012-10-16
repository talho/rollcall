Feature:  Status Report Page and Email Reporting
  In order to see what schools are reporting
  As a rollcall SuperAdmin
  I should be able to see the status page and receive status reports via email
  
  Background:
    Given I have rollcall users in a variety of roles
    And I have schools with reported rollcall data
  
  Scenario: User Visits the Status Page
    When I am logged in as a rollcall user
    Then I do not see the status link
    
  Scenario: Admin Visits the Status Page
    When I am logged in as a rollcall admin
    Then I do not see the status link
  
  Scenario: Superadmin Visits the Status Page
    When I am logged in as a rollcall superadmin
    Then I do see the status link
    And I see schools that have not reported
    
  Scenario: Superadmin Receives a Status Report
    Given I am logged in as a rollcall superadmin
    When the chron job fires or whatever
    Then I receive an emailed status report