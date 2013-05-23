Feature: Administer Rollcall Users
  In order to extend the functionality of a administering user accounts for Rollcall
  As a Rollcall Admin
  I should be able to assign school districts and schools to rollcall users

Background:
  Given the following entities exist:
    | Role         | Admin          |          |
    | Role         | Rollcall       | rollcall |
    | Role         | Admin          | rollcall |
    | Role         | Nurse          | rollcall |
    | Role         | Epidemiologist | rollcall |
    | Jurisdiction | Texas          |          |
    | Jurisdiction | Harris         |          |
  And Texas is the parent jurisdiction of:
    | Harris |
  And Harris has the following school districts:
    | Houston | 101912 |
  And "Houston" has the following schools:
    | name                | school_number | tea_id    | school_type       | postal_code | gmap_lat   | gmap_lng    | gmap_addr                                                                      |
    | Anderson Elementary | 105           | 101912105 | Elementary School | 77035       | 29.6496766 | -95.4879978 | "Anderson Elementary School, 5727 Ludington Dr, Houston, TX 77035-4399, USA"   |
    | Ashford Elementary  | 273           | 101912273 | Elementary School | 77077       | 29.7477296 | -95.5988336 | "Ashford Elementary School, 1815 Shannon Valley Dr, Houston, TX 77077, USA"    |
    | Yates High School   | 20            | 101912020 | High School       | 77004       | 29.7232848 | -95.3546602 | "Yates High School: School Buildings, 3703 Sampson St, Houston, TX 77004, USA" |
  And the following users exist:
    | Admin Joe    | admin.joe@example.com   | Admin          | Harris  |          |
    | Admin Joe    | admin.joe@example.com   | Admin          | Harris  | rollcall |
    | Roll User    | roll.user@example.com   | Rollcall       | Harris  | rollcall |
  And delayed jobs are processed

Scenario: User creates Rollcall User
  Given I am logged in as "admin.joe@example.com"
  When I fill in the add user form with:
    | Email address     | rolly.cally@example.com |
    | First name        | Rolly                   |
    | Last name         | Cally                   |
    | Password          | Password1               |
    | Confirm password  | Password1               |
    | Display name      | Rolly Cally             |
    | Language          | English                 |
    | Home Jurisdiction | Harris                  |
  And I request the role "Rollcall" for "Harris" in the RolesControl
  And I press "Apply Changes"
  And delayed jobs are processed
  And I should see "The user has been successfully created"
  And "rolly.cally@example.com" should have the "Public" role for "Harris"
  And "rolly.cally@example.com" should have the "Rollcall" role for "Harris"
  And "rolly.cally@example.com" should not receive an email with the subject "Request submitted for Rollcall in Harris"
  And rollcall user "admin.joe@example.com" should not receive an email
  And I navigate to "Apps > Rollcall > Admin > Users"
  And I wait for the panel to load
  Then I should see "Rolly Cally" within ".x-grid3-cell"

Scenario: User assigns school district to Rollcall User
  Given I am logged in as "admin.joe@example.com"
  And I navigate to "Apps > Rollcall > Admin > Users"
  And I wait for the panel to load
  And I click x-grid3-cell "Roll User"
  And I select "Houston" from ext combo "school_district"
  And I press "Add this school district"
  Then I should see "Houston" within ".x-grid3-cell"

Scenario: User assigns school to Rollcall User
  Given I am logged in as "admin.joe@example.com"
  And I navigate to "Apps > Rollcall > Admin > Users"
  And I wait for the panel to load
  And I click x-grid3-cell "Roll User"
  And I select "Houston" from ext combo "school_district"
  And I select "Yates High School" from ext combo "school"
  And I press "Add this school"
  Then I should see "Yates High School" within ".x-grid3-cell"

Scenario: User removes school assigned to Rollcall User
  Given I am logged in as "admin.joe@example.com"
  And I navigate to "Apps > Rollcall > Admin > Users"
  And I wait for the panel to load
  And I click x-grid3-cell "Roll User"
  And I select "Houston" from ext combo "school_district"
  And I select "Yates High School" from ext combo "school"
  And I press "Add this school"
  Then I should see "Yates High School" within ".x-grid3-cell"
  And I click x-action-col-icon on the "Yates High School" grid row
  Then I should not see "Yates High School" within ".x-grid3-cell"

Scenario: User removes school district assigned to Rollcall User
  Given I am logged in as "admin.joe@example.com"
  And I navigate to "Apps > Rollcall > Admin > Users"
  And I wait for the panel to load
  And I click x-grid3-cell "Roll User"
  And I select "Houston" from ext combo "school_district"
  And I press "Add this school district"
  Then I should see "Houston" within ".x-grid3-cell"
  And I click x-action-col-icon on the "Houston" grid row
  Then I should not see "Houston" within ".x-grid3-cell"
