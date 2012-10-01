Feature: Neighboring School Districts
  In order to view compare data of school districts I'm a member of
  As a Rollcall user
  I should be able to see stripped down neighboring districts
  
Background:
  Given the following entities exist:
    | Role         | Epidemiologist | rollcall |
    | Jurisdiction | Texas          |          |
    | Jurisdiction | Collin         |          |
    | Jurisdiction | Mystery        |          |
  And Texas is the parent jurisdiction of:
    | Collin  |
  And Collin has the following school districts:
    | District1 | 101912 |
    | District2 | 68901  |
  And "District1" has the following schools:
    | name                | school_number | tea_id    | school_type       | postal_code | gmap_lat   | gmap_lng    | gmap_addr                                                                      |
    | Anderson Elementary | 105           | 101912105 | Elementary School | 77035       | 29.6496766 | -95.4879978 | "Anderson Elementary School, 5727 Ludington Dr, Houston, TX 77035-4399, USA"   |
    | Ashford Elementary  | 273           | 101912273 | Elementary School | 77077       | 29.7477296 | -95.5988336 | "Ashford Elementary School, 1815 Shannon Valley Dr, Houston, TX 77077, USA"    |
    | Yates High School   | 20            | 101912020 | High School       | 77004       | 29.7232848 | -95.3546602 | "Yates High School: School Buildings, 3703 Sampson St, Houston, TX 77004, USA" |
  And "District2" has the following schools:
    | name                              | school_number | tea_id    | school_type       | postal_code | gmap_lat   | gmap_lng    | gmap_addr                                                                        |
    | Ector Junior High School          | 047           | 68901047  | High School       | 79763       | 31.831847  | -102.373438 | "Ector Junior High School, 809 West Clements Street, Odessa, TX 79763-4600"      |
    | Gale Pond Alamo Elementary School | 101           | 68901101  | Elementary School | 79761       | 31.871289  | -102.371464 | "Gale Pond Alamo Elementary School, 801 East 23rd Street, Odessa, TX 79761-1356" |
    | Austin Elementary School          | 102           | 68901102  | Elementary School | 79761       | 31.853575  | -102.373352 | "Austin Elementary School, 200 West 9th Street, Odessa, TX 79761-3956"           |
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
    | Nurse Betty  | nurse.betty@example.com | Epidemiologist    | Collin  | rollcall |
    | Steve Steve  | steve@example.com       | Epidemiologist    | Mystery | rollcall |
  And rollcall user "nurse.betty@example.com" has the following school districts assigned:
    | District1 |
    | District2 |
  And rollcall user "nurse.betty@example.com" has the following schools assigned:
    | Anderson Elementary               |
    | Ashford Elementary                |
    | Yates High School                 |
    | Ector Junior High School          |
    | Gale Pond Alamo Elementary School |
    | Austin Elementary School          |
  And "District1" has the following current district absenteeism data:
    | day | total_enrolled | total_absent |
    | 1   | 400            | 13           |
    | 2   | 400            | 14           |
  And "District1" has the following current school absenteeism data:
    | day | school_name         | total_enrolled | total_absent |
    | 1   | Anderson Elementary | 100            | 2            |
    | 2   | Anderson Elementary | 100            | 5            |
    | 1   | Ashford Elementary  | 100            | 1            |
    | 2   | Ashford Elementary  | 100            | 4            |
    | 1   | Yates High School   | 200            | 10           |
    | 2   | Yates High School   | 200            | 5            |
  And "District2" has the following current district absenteeism data:
    | day | total_enrolled | total_absent |
    | 1   | 500            | 13           |
    | 2   | 500            | 14           |
  And "District2" has the following current school absenteeism data:
    | day | school_name                       | total_enrolled | total_absent |
    | 1   | Ector Junior High School          | 150            | 2            |
    | 2   | Ector Junior High School          | 150            | 5            |
    | 1   | Gale Pond Alamo Elementary School | 125            | 1            |
    | 2   | Gale Pond Alamo Elementary School | 125            | 4            |
    | 1   | Austin Elementary School          | 225            | 10           |
    | 2   | Austin Elementary School          | 225            | 5            |  
  
Scenario:  User views multiple school district neighbors
  And I am logged in as "nurse.betty@example.com"
  And I navigate to "Apps > Rollcall > ADST"
  And I wait for the panel to load
  When I press "Switch to Advanced"
  And I click school-district-list-item "District1"
  And I click school-district-list-item "District2"
  And I press "School District"
  And I press "Submit"
  And I press "View Neighboring School Districts"
  And I should not see "Export Result Set" within ".x-toolbar-right-row"
  And I should not see "Create Alarm from Result Set" within ".x-toolbar-right-row"
  And I should not see "Generate Report from Result Set" within ".x-toolbar-right-row"
  And I should not see "Displaying" within ".xtb-text"
  And I should see "District1" within ".x-panel-header-text"
  And I should see "District1 Neighbor: District2" within ".x-panel-header-text"
  And I should see "District2" within ".x-panel-header-text"
  And I should see "District2 Neighbor: District1" within ".x-panel-header-text"  
  
@malicious
Scenario: Neighboring School District Maliciousness Test
  And I am logged in as "steve@example.com"
  And I load ExtJs
  And I malicously try to call neighbors
  Then The maliciousness response should contain /\"success\":false/
  