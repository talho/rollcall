Feature: Use Nurse Assistant Panel
  In order to utilize the Nurse Assistant Panel
  As a Rollcall user
  I should be able to add, edit, and view student visits to the nurse.

Background:
  Given the following entities exist:
    | Role         | Nurse           | rollcall |
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
    | Nurse Betty  | nurse.betty@example.com | Nurse    | Harris | rollcall |
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
  And "Houston" has the following student data:
   | first_name | last_name | contact_first_name | contact_last_name | address        | zip   | dob        | gender | phone      | race | student_number | school_name         |
   | Hugh       | Mann      | Woe                | Mann              | 1122 Street Ln | 77077 | 05/15/1995 | M      | 5125556666 | 1    | 5318008        | Yates High School   |

  And I am logged in as "nurse.betty@example.com"
  And I navigate to the ext dashboard page
  And I navigate to "Apps > Rollcall > Nurse Assistant"
  And I wait for the panel to load
  #And I select "Anderson Elementary" from ext combo "select_school"
  #And I press "OK"

Scenario: User enters a new student visit
  When I press "New"
  And I should see "New Visit"
  And I wait for the panel to load
  And I press "New Student"
  And I fill in "Student ID" with "000111000"
  And I fill in "Student First Name" with "John"
  And I fill in "Student Last Name" with "Doe"
  And I fill in "Contact First Name" with "Jane"
  And I fill in "Contact Last Name" with "Doe"
  And I fill in "Address" with "1111 Forward Ln"
  And I select "77035" from ext combo "zip"
  And I fill in "Phone Number" with "1112223344"
  And I select "10th Grade" from ext combo "grade"
  And I fill in "dob" with "05/15/1995"
  And I select "Male" from ext combo "gender"
  And I select "White" from ext combo "race"
  And I fill in "Temperature" with "98"
  And I fill in "Action Taken" with "sent back to class"
  And I select "Sore Throat" from ext combo "symptoms"
  And I press "Submit"
  And I wait for the panel to load
  And I click ".x-form-date-trigger"
  And I press "Today"
  And I wait for the panel to load
  And I should see "John" within "#nurse_assistant"
  And I should see "Sore Throat" within "#nurse_assistant"
  Then I should see "sent back to class" within "#nurse_assistant"

Scenario: User enters a new student visit off of a existing student
  When I press "New"
  And I should see "New Visit"
  And I should see "John" within grid "student_list" in column "First Name"
  And I select the "John" grid row within "#student_list"
  And I wait for the panel to load  
  And I fill in "Temperature" with "98"
  And I fill in "dob" with "05/15/1995"
  And I fill in "Action Taken" with "sent back to class"
  And I select "Sore Throat" from ext combo "symptoms"
  And I press "Submit"
  And I wait for the panel to load
  And I click ".x-form-date-trigger"
  And I press "Today"
  And I wait for the panel to load  
  And I should see "John" within "#nurse_assistant"
  And I should see "Sore Throat" within "#nurse_assistant"
  Then I should see "sent back to class" within "#nurse_assistant"

Scenario: User enters a new student visit off of a existing student using a student ID
  When I press "New"
  And I should see "New Visit"
  And I should see "John" within grid "student_list" in column "First Name"
  And I fill in "filter_student_number" with "10055500"
  And I should see "John" within "#student_list"
  And I select the "John" grid row within "#student_list"
  And I wait for the panel to load
  And I fill in "Temperature" with "98"
  And I fill in "dob" with "05/15/1995"
  And I fill in "Action Taken" with "sent back to class"
  And I select "Sore Throat" from ext combo "symptoms"
  And I press "Submit"
  And I wait for the panel to load
  And I click ".x-form-date-trigger"
  And I press "Today"
  And I wait for the panel to load
  And I should see "John" within "#nurse_assistant"
  And I should see "Sore Throat" within "#nurse_assistant"
  Then I should see "sent back to class" within "#nurse_assistant"

Scenario: User edits a student visit
  When I select the "Unknown" grid row within "#nurse_assistant"
  And I click x-grid3-col-edit_student_entry on the "Unknown" grid row 
  And I should see "Edit Visit"
  And I fill in "dob" with "05/15/1995"
  And I fill in "Student ID" with "00110011"
  And I fill in "Action Taken" with "sent back to class"
  And I select "White" from ext combo "race"
  And I press "Submit"
  And I wait for the panel to load
  Then I should see "00110011" within "#nurse_assistant"

Scenario: User deletes a student visit
  When I select the "John" grid row within "#nurse_assistant"
  And I click x-grid3-col-delete_student_entry on the "John" grid row  
  And I should see "Are you sure you want to delete this recorded visitation?"
  And I press "Yes"
  And I wait for the panel to load
  Then I should not see "John" within "#nurse_assistant"

Scenario: User creates a new student
  When I press "New Student"
  And I should see "New Student"
  And I fill in "Student ID" with "222333"
  And I fill in "Student First Name" with "Tester"
  And I fill in "Student Last Name" with "Test"
  And I fill in "Contact First Name" with "Contact"
  And I fill in "Contact Last Name" with "Test"
  And I fill in "Address" with "PO Box 111"
  And I select "77035" from ext combo "zip"
  And I fill in "Phone Number" with "8901113434"
  And I fill in "dob" with "06/23/1999"
  And I select "Male" from ext combo "gender"
  And I select "White" from ext combo "race"
  And I press "Submit"
  And I wait for the panel to load
  And I should see "Tester" within grid "student_grid" in column "First Name"
  And I should see "Tester" within "#student_grid"
  And I select the "Tester" grid row
  And I wait for the panel to load
  Then I should see "Tester Test" within "#student-stats"

Scenario: User edits an existing student
  When I click x-action-col-icon on the "Unknown" grid row within "#student_grid"
  And I fill in "Student ID" with "222333"
  And I fill in "Student First Name" with "Tester"
  And I fill in "Student Last Name" with "Test"
  And I fill in "Contact First Name" with "Contact"
  And I fill in "Contact Last Name" with "Test"
  And I fill in "Address" with "PO Box 111"
  And I select "77035" from ext combo "zip"
  And I fill in "Phone Number" with "8901113434"
  And I fill in "dob" with "06/23/1999"
  And I select "Male" from ext combo "gender"
  And I select "White" from ext combo "race"
  And I press "Submit"
  And I wait for the panel to load
  And I should see "Tester" within grid "student_grid" in column "First Name"
  And I fill in "list_filter_student_number" with "222333"
  And I should see "Tester" within "#student_grid"
  And I select the "Tester" grid row
  And I wait for the panel to load
  Then I should see "Tester Test" within "#student-stats"

Scenario: User searches for a student visit
  When I fill in "search_field" with "Elliot" within "#nurse_assistant"
  And I press "Search"
  And I wait for the panel to load
  And I should not see "Unknown" within "#nurse_assistant"
  Then I should see "Elliot" within "#nurse_assistant"

Scenario: User refreshes student list
  When I fill in "list_filter_student_number" with ""
  And I should see "John" within grid "student_grid" in column "First Name"
  And I fill in "list_filter_student_number" with "10055500"
  And I should see "John" within "#student_grid"
  And I should not see "Unknown" within "#student_grid"
  And I click x-tbar-loading "" within "#student_grid"
  And I wait for the panel to load
  Then I should see "Unknown" within "#student_grid"

Scenario: User refreshes main panel
  When I fill in "search_field" with "Elliot" within "#nurse_assistant"
  And I press "Search"
  And I wait for the panel to load
  And I should not see "Unknown" within "#nurse_assistant"
  And I should see "Elliot" within "#nurse_assistant"
  And I click x-tbar-loading "" within "#nurse_assistant"
  And I wait for the panel to load
  And I should see "Unknown" within "#nurse_assistant"    
  Then I should see "John" within "#nurse_assistant"

Scenario: User changes schools
  When I press "Change School"
  And I wait for the panel to load
  And I select "Anderson Elementary" from ext combo "select_school"
  And I press "OK"
  And I wait for the panel to load
  And I should see "John" within grid "student_grid" in column "First Name"