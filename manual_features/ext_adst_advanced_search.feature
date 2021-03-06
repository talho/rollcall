# TODO: modify to test that d3 is graphic the data

Feature: Execute Advanced Graphing Queries
  In order to execute advanced search queries
  As a Rollcall user
  I should be able to select from a list of advanced Graphing options, construct and execute my query

Background:
  Given the following entities exist:
    | Role         | Epidemiologist | rollcall |
    | Jurisdiction | Texas          |          |
    | Jurisdiction | Collin         |          |
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
    | Nurse Betty  | nurse.betty@example.com | Epidemiologist    | Collin | rollcall |
  And rollcall user "nurse.betty@example.com" has the following school districts assigned:
    | District1  |
    | District2 |
  And rollcall user "nurse.betty@example.com" has the following schools assigned:
    | Anderson Elementary               |
    | Ashford Elementary                |
    | Yates High School                 |
    | Ector Junior High School          |
    | Gale Pond Alamo Elementary School |
    | Austin Elementary School          |
  And "District1" has the following current school absenteeism data:
    | day | school_name         | total_enrolled | total_absent |
    | 1   | Anderson Elementary | 100            | 2            |
    | 2   | Anderson Elementary | 100            | 5            |
    | 1   | Ashford Elementary  | 100            | 1            |
    | 2   | Ashford Elementary  | 100            | 4            |
    | 1   | Yates High School   | 200            | 10           |
    | 2   | Yates High School   | 200            | 5            |
  And "District1" has the following current student absenteeism data:
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
  And "District2" has the following current school absenteeism data:
    | day | school_name                       | total_enrolled | total_absent |
    | 1   | Ector Junior High School          | 150            | 2            |
    | 2   | Ector Junior High School          | 150            | 5            |
    | 1   | Gale Pond Alamo Elementary School | 125            | 1            |
    | 2   | Gale Pond Alamo Elementary School | 125            | 4            |
    | 1   | Austin Elementary School          | 225            | 10           |
    | 2   | Austin Elementary School          | 225            | 5            |
  And "District2" has the following current student absenteeism data:
    | day | school_name                       | age      | first_name | last_name | dob        | grade | gender | confirmed_ill | symptoms                    | student_number |
    | 1   | Ector Junior High School          | 8        |            |           | 02/13/2003 | 2     | M      | true          | Cough,Temperature           |                |
    | 1   | Ector Junior High School          | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2   | Ector Junior High School          | 8        | John       | Dorian    | 02/13/2003 | 2     | M      | true          | Cough,Temperature,Chills    | 10055500       |
    | 2   | Ector Junior High School          | 6        |            |           | 12/01/2005 | 1     | F      | false         |                             |                |
    | 2   | Ector Junior High School          | 6        |            |           | 09/11/2005 | 1     | F      | false         |                             |                |
    | 2   | Ector Junior High School          | 8        |            |           | 05/01/2003 | 2     | M      | true          | Congestion,Cough,Headache   |                |
    | 2   | Ector Junior High School          | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 1   | Gale Pond Alamo Elementary School | 9        |            |           | 05/12/2002 | 3     | F      | true          | Influenza                   |                |
    | 2   | Gale Pond Alamo Elementary School | 8        |            |           | 01/02/2003 | 2     | F      | true          | Temperature                 |                |
    | 2   | Gale Pond Alamo Elementary School | 7        |            |           | 01/22/2004 | 2     | M      | true          | None                        |                |
    | 2   | Gale Pond Alamo Elementary School | 7        | Chris      | Turk      | 08/27/2004 | 2     | F      | true          | Temperature                 | 900800700      |
    | 2   | Gale Pond Alamo Elementary School | 8        |            |           | 02/12/2003 | 2     | M      | true          | Temperature,Cough           |                |
    | 1   | Austin Elementary School          | 16       |            |           | 06/16/1995 | 10    | M      | false         |                             |                |
    | 1   | Austin Elementary School          | 18       |            |           | 04/26/1993 | 12    | F      | false         |                             |                |
    | 1   | Austin Elementary School          | 18       |            |           | 02/19/1993 | 12    | M      | false         |                             |                |
    | 1   | Austin Elementary School          | 15       |            |           | 08/26/1996 | 09    | M      | true          | Lethargy,Headache           |                |
    | 1   | Austin Elementary School          | 15       |            |           | 06/30/1996 | 09    | F      | false         |                             |                |
    | 1   | Austin Elementary School          | 14       |            |           | 01/02/1997 | 09    | M      | false         |                             |                |
    | 1   | Austin Elementary School          | 16       |            |           | 03/13/1995 | 10    | M      | true          | Sore Throat,Cough           |                |
    | 1   | Austin Elementary School          | 16       | Elliot     | Reid      | 11/17/1995 | 10    | M      | true          | Diarrhea,Vomiting           | 101202303      |
    | 1   | Austin Elementary School          | 17       |            |           | 09/24/1994 | 10    | M      | false         |                             |                |
    | 1   | Austin Elementary School          | 16       |            |           | 02/08/1995 | 10    | F      | true          | None                        |                |
    | 2   | Austin Elementary School          | 15       |            |           | 08/04/1996 | 09    | F      | false         |                             |                |
    | 2   | Austin Elementary School          | 17       |            |           | 12/13/1994 | 11    | M      | false         |                             |                |
    | 2   | Austin Elementary School          | 17       |            |           | 04/23/1994 | 10    | F      | false         |                             |                |
    | 2   | Austin Elementary School          | 18       |            |           | 10/17/1993 | 12    | M      | true          | Chills,Cough,Headache       |                |
    | 2   | Austin Elementary School          | 18       |            |           | 07/23/1993 | 12    | M      | true          | Chills,Temperature,Headache |                |

  And I am logged in as "nurse.betty@example.com"
  And I navigate to "Apps > Rollcall > Graphing"
  And I wait for the panel to load

Scenario: User runs an advanced query against multiple schools
  When I press "Switch to Advanced"
  And I click school-name-list-item "Anderson Elementary"
  And I click school-name-list-item "Yates High School"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Raw_101912105_c_absenteeism.png,DF-Raw_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query against multiple school types
  When I press "Switch to Advanced"
  And I click school-type-list-item "Elementary School"
  And I click school-type-list-item "High School"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Raw_101912105_c_absenteeism.png,DF-Raw_101912273_c_absenteeism.png,DF-Raw_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query against multiple zipcodes
  When I press "Switch to Advanced"
  And I click zipcode-list-item "77077"
  And I click zipcode-list-item "77004"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Raw_101912273_c_absenteeism.png,DF-Raw_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query against multiple ages
  When I press "Switch to Advanced"
  And I click age-list-item "8"
  And I click age-list-item "17"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "AGE-8-18_DF-Raw_101912105_c_absenteeism.png,AGE-8-18_DF-Raw_101912273_c_absenteeism.png,AGE-8-18_DF-Raw_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query against multiple grades
  When I press "Switch to Advanced"
  And I click grade-list-item "2"
  And I click grade-list-item "10"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Ector Junior High School,Gale Pond Alamo Elementary School,Austin Elementary School,Anderson Elementary,Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Raw_GRD-2-10_101912105_c_absenteeism.png,DF-Raw_GRD-2-10_101912273_c_absenteeism.png,DF-Raw_GRD-2-10_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query against multiple symptoms
  When I press "Switch to Advanced"
  And I click symptom-list-item "Chills"
  And I click symptom-list-item "Influenza"
  And I Submit and wait
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Raw_SYM-780.64-487.1_101912105_c_absenteeism.png,DF-Raw_SYM-780.64-487.1_101912273_c_absenteeism.png,DF-Raw_SYM-780.64-487.1_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query against male gender
  When I press "Switch to Advanced"
  And I select "Male" from ext combo "gender"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Raw_GNDR-M_101912105_c_absenteeism.png,DF-Raw_GNDR-M_101912273_c_absenteeism.png,DF-Raw_GNDR-M_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query against female gender
  When I press "Switch to Advanced"
  And I select "Female" from ext combo "gender"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Raw_GNDR-F_101912105_c_absenteeism.png,DF-Raw_GNDR-F_101912273_c_absenteeism.png,DF-Raw_GNDR-F_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query against school type, age, grade, gender and symptoms
  When I press "Switch to Advanced"
  And I click school-type-list-item "Elementary School"
  And I click grade-list-item "10"
  And I select "Male" from ext combo "gender"
  And I click symptom-list-item "Influenza"
  And I click age-list-item "8"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Ashford Elementary,Austin Elementary School,Gale Pond Alamo Elementary School" within the results
  #Then I should see graphs "AGE-8_DF-Raw_GNDR-M_GRD-10_SYM-487.1_101912105_c_absenteeism.png,AGE-8_DF-Raw_GNDR-M_GRD-10_SYM-487.1_101912273_c_absenteeism.png" within the results

Scenario: User runs an advanced query to view the average data
  When I press "Switch to Advanced"
  And I select "Average" from ext combo "data_func"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Average_101912105_c_absenteeism.png,DF-Average_101912273_c_absenteeism.png,DF-Average_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query to view the standard deviation
  When I press "Switch to Advanced"
  And I select "Standard Deviation" from ext combo "data_func"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "DF-StandardDeviation_101912105_c_absenteeism.png,DF-StandardDeviation_101912273_c_absenteeism.png,DF-StandardDeviation_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query to view the cusum data
  When I press "Switch to Advanced"
  And I select "Cusum" from ext combo "data_func"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Cusum_101912105_c_absenteeism.png,DF-Cusum_101912273_c_absenteeism.png,DF-Cusum_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query to view the moving average data for 30 days
  When I press "Switch to Advanced"
  And I select "Average 30 Day" from ext combo "data_func"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Average30Day_101912105_c_absenteeism.png,DF-Average30Day_101912273_c_absenteeism.png,DF-Average30Day_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query to view the moving average data for 60 days
  When I press "Switch to Advanced"
  And I select "Average 60 Day" from ext combo "data_func"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Anderson Elementary,Ashford Elementary,Yates High School" within the results
  #Then I should see graphs "DF-Average60Day_101912105_c_absenteeism.png,DF-Average60Day_101912273_c_absenteeism.png,DF-Average60Day_101912020_c_absenteeism.png" within the results

Scenario: User runs an advanced query against time period
  When I press "Switch to Advanced"
  And I set "startdt" to "5" days from origin date
  And I set "enddt" to "0" days from origin date
  And I press "Submit"
  And delayed jobs are processed
  #Then I should see dated graphs for schools "101912105,101912273,101912020" starting "5" days and ending "0" days from origin date

Scenario: User runs an advanced query against a school district
  When I press "Switch to Advanced"
  And I click school-district-list-item "District2"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "Ector Junior High School,Gale Pond Alamo Elementary School,Austin Elementary School" within the results
  #Then I should see graphs "DF-Raw_68901047_c_absenteeism.png,DF-Raw_68901101_c_absenteeism.png,DF-Raw_68901102_c_absenteeism.png" within the results

Scenario: User runs a simple query against a school district, requests school district graph
  When I press "Switch to Advanced"
  And I click school-district-list-item "District2"
  And I press "School District"
  And I press "Submit"
  #And delayed jobs are processed
  Then I should see "District2" within the results
  #Then I should see graphs "DF-Raw_district_68901_c_absenteeism.png" within the results
