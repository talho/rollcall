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
  And the following symptoms exist:
    | icd9_code | name                    |
    | 032.9     | Diphtheria              |
    | 034.0     | Strep Throat            |
    | 034.1     | Scarlet Fever           |
    | 038.11    | Staph Aureus            |
    | 041.00    | Streptococcal Infection |
    | 052.9     | Chicken Pox             |
    | 056.9     | Rubella                 |
    | 055.9     | Measles                 |
    | 072.9     | Mumps                   |
    | 322.9     | Meningitis              |
    | 323.9     | Encephalitis            |
    | 462       | Sore Throat             |
    | 478.19    | Congestion              |
    | 487.1     | Influenza               |
    | 573.3     | Hepatitis               |
    | 780.60    | Temperature             |
    | 780.64    | Chills                  |
    | 780.79    | Lethargy                |
    | 784.0     | Headache                |
    | 786.2     | Cough                   |
    | 787.03    | Vomiting                |
    | 787.91    | Diarrhea                |
    | 0         | None                    |
  And the following users exist:
    | Admin Joe    | admin.joe@example.com   | Admin          | Harris  |          |
    | Admin Joe    | admin.joe@example.com   | Admin          | Harris  | rollcall |
    | Roll User    | roll.user@example.com   | Rollcall       | Harris  | rollcall |
  And "Houston" has the following current district absenteeism data:
    | day | total_enrolled | total_absent |
    | 1   | 400            | 13           |
    | 2   | 400            | 14           |
  And "Houston" has the following current school absenteeism data:
    | day | school_name         | total_enrolled | total_absent |
    | 1   | Anderson Elementary | 100            | 2            |
    | 2   | Anderson Elementary | 100            | 5            |
    | 1   | Ashford Elementary  | 100            | 1            |
    | 2   | Ashford Elementary  | 100            | 4            |
    | 1   | Yates High School   | 200            | 10           |
    | 2   | Yates High School   | 200            | 5            |
  And "Houston" has the following current student absenteeism data:
    | day | school_name         | age      | first_name | last_name | dob        | grade | gender | confirmed_ill | symptoms                    | student_number |
    | 1   | Anderson Elementary | 8        |            |           | 02/13/2003 | 2     | M      | true          | Cough,Temperature           |                |
    | 1   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 8        | John       | Dorian    | 02/13/2003 | 2     | M      | true          | Cough,Temperature,Chills    | 10055500       |
    | 2   | Anderson Elementary | 6        |            |           | 12/01/2005 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 6        |            |           | 09/11/2005 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 8        |            |           | 05/01/2003 | 2     | M      | true          | Congestion,Cough,Headache   |                |
    | 2   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 1   | Ashford Elementary  | 9        |            |           | 05/12/2002 | 3     | F      | true          | Influenza                   |                |
    | 2   | Ashford Elementary  | 8        |            |           | 01/02/2003 | 2     | F      | true          | Temperature                 |                |
    | 2   | Ashford Elementary  | 7        |            |           | 01/22/2004 | 2     | M      | true          | None                        |                |
    | 2   | Ashford Elementary  | 7        | Chris      | Turk      | 08/27/2004 | 2     | F      | true          | Temperature                 | 900800700      |
    | 2   | Ashford Elementary  | 8        |            |           | 02/12/2003 | 2     | M      | true          | Temperature,Cough           |                |
    | 1   | Yates High School   | 16       |            |           | 06/16/1995 | 10    | M      | false         |                             |                |
    | 1   | Yates High School   | 18       |            |           | 04/26/1993 | 12    | F      | false         |                             |                |
    | 1   | Yates High School   | 18       |            |           | 02/19/1993 | 12    | M      | false         |                             |                |
    | 1   | Yates High School   | 15       |            |           | 08/26/1996 | 09    | M      | true          | Lethargy,Headache           |                |
    | 1   | Yates High School   | 15       |            |           | 06/30/1996 | 09    | F      | false         |                             |                |
    | 1   | Yates High School   | 14       |            |           | 01/02/1997 | 09    | M      | false         |                             |                |
    | 1   | Yates High School   | 16       |            |           | 03/13/1995 | 10    | M      | true          | Sore Throat,Cough           |                |
    | 1   | Yates High School   | 16       | Elliot     | Reid      | 11/17/1995 | 10    | M      | true          | Diarrhea,Vomiting           | 101202303      |
    | 1   | Yates High School   | 17       |            |           | 09/24/1994 | 10    | M      | false         |                             |                |
    | 1   | Yates High School   | 16       |            |           | 02/08/1995 | 10    | F      | true          | None                        |                |
    | 2   | Yates High School   | 15       |            |           | 08/04/1996 | 09    | F      | false         |                             |                |
    | 2   | Yates High School   | 17       |            |           | 12/13/1994 | 11    | M      | false         |                             |                |
    | 2   | Yates High School   | 17       |            |           | 04/23/1994 | 10    | F      | false         |                             |                |
    | 2   | Yates High School   | 18       |            |           | 10/17/1993 | 12    | M      | true          | Chills,Cough,Headache       |                |
    | 2   | Yates High School   | 18       |            |           | 07/23/1993 | 12    | M      | true          | Chills,Temperature,Headache |                |
  And delayed jobs are processed
  
Scenario: User creates Rollcall User
  Given I am logged in as "admin.joe@example.com"
  And I navigate to the ext dashboard page
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
  And I press "Add School District"
  And I click x-menu-item "Houston"
  And I wait for the panel to load
  Then I should see "Houston" within ".x-grid3-cell"
  
Scenario: User assigns school to Rollcall User
  Given I am logged in as "admin.joe@example.com"
  And I navigate to "Apps > Rollcall > Admin > Users"
  And I wait for the panel to load
  And I click x-grid3-cell "Roll User"
  And I press "Add School District"
  And I click x-menu-item "Houston"
  And I wait for the panel to load
  And I should see "Houston" within ".x-grid3-cell"
  And I click x-grid3-cell "Roll User"
  And I press "Add School"
  And I click x-menu-item "Yates High School"
  And I wait for the panel to load
  Then I should see "Yates High School" within ".x-grid3-cell"

Scenario: User removes school assigned to Rollcall User
  Given I am logged in as "admin.joe@example.com"
  And I navigate to "Apps > Rollcall > Admin > Users"
  And I wait for the panel to load
  And I click x-grid3-cell "Roll User"
  And I press "Add School District"
  And I click x-menu-item "Houston"
  And I wait for the panel to load
  And I should see "Houston" within ".x-grid3-cell"
  And I click x-grid3-cell "Roll User"
  And I press "Add School"
  And I click x-menu-item "Yates High School"
  And I wait for the panel to load
  And I should see "Yates High School" within ".x-grid3-cell"
  And I click x-tpl-circle-icon on the "Roll User" grid row
  And I wait for the panel to load
  Then I should not see "Yates High School" in column "Schools" within "rollcall_users_grid"
  
Scenario: User removes school district assigned to Rollcall User
  Given I am logged in as "admin.joe@example.com"
  And I navigate to "Apps > Rollcall > Admin > Users"
  And I wait for the panel to load
  And I click x-grid3-cell "Roll User"
  And I press "Add School District"
  And I click x-menu-item "Houston"
  And I wait for the panel to load
  And I wait for the panel to load
  And I should see "Houston" within ".x-grid3-cell"
  And I click x-grid3-cell "Roll User"
  And I click x-tpl-circle-icon on the "Roll User" grid row
  And I wait for the panel to load
  And I wait for the panel to load
  Then I should not see "Houston" within ".x-grid3-cell"