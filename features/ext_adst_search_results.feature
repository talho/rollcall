Feature: Interact with search result controls feature
  In order to interact with ADST search result controls
  As a Rollcall user
  I should be able to select from a list of search results, click and interact with its controls

Background:
  Given the following entities exist:
    | Role         | Epidemiologist  | rollcall |
    | Jurisdiction | Texas           |          |
    | Jurisdiction | Harris          |          |
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
    | Nurse Betty  | nurse.betty@example.com | Epidemiologist    | Harris |
  And rollcall user "nurse.betty@example.com" has the following school districts assigned:
    | Houston |
  And rollcall user "nurse.betty@example.com" has the following schools assigned:
    | Anderson Elementary |
    | Ashford Elementary  |
    | Yates High School   |
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

  And I am logged in as "nurse.betty@example.com"
  And I navigate to the ext dashboard page
  And I navigate to "Apps > Rollcall > ADST"
  And I wait for the panel to load
  And I press "Submit"
  And delayed jobs are processed

Scenario: User closes a graph window
  When "Anderson Elementary" graphs has done loading
  And I close the "Query Result for Anderson Elementary" window
  Then I should not see the "Anderson Elementary" window

Scenario: User exports result data
  When "Anderson Elementary" graphs has done loading
  And I click the "down" tool on the "Query Result for Anderson Elementary" window
  And I should see "Your CSV file will be placed in your documents folders"
  And delayed jobs are processed
  And I press "OK"
  And I wait for documents to be processed
  And I navigate to "Documents"
  And I expand the folders ""
  And I select the "Rollcall Documents" grid row
  Then I should see "rollcall_export.cucumber.csv" within ".document-file-icon-view"

Scenario: User saves result as alarm query
  When "Anderson Elementary" graphs has done loading
  And I click the "save" tool on the "Query Result for Anderson Elementary" window
  And I should see "Alarm Query for Anderson Elementary"
  And I fill in "Name" with "Example Query"
  And I press "Submit" within ".x-window"
  Then I should see "Example Query" within "#alarm_queries"

Scenario: User views a results school profile
  When "Anderson Elementary" graphs has done loading
  And I click the "gis" tool on the "Query Result for Anderson Elementary" window
  And I should see "School Profile for Anderson Elementary"
  Then I should see "5727 Ludington Dr"

Scenario: User pins a graph result
  When "Anderson Elementary" graphs has done loading
  And I click the "pin" tool on the "Query Result for Anderson Elementary" window
  And the "Anderson Elementary" graph result is pinned
  And I select "Yates High School" from ext combo "school_simple"
  And I press "Submit"
  And delayed jobs are processed
  Then I should see "Anderson Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Raw_101912105_c_absenteeism.png,DF-Raw_101912020_c_absenteeism.png" within the results