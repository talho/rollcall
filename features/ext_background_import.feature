Feature: Importing automated data
  In order to facilitate reliable surveillance of school attendance data
  As an outside system
  I want to upload data for automatic import into Rollcall

Background:
  Given the following entities exist:
    | Role         | Epidemiologist  | rollcall |
    | Jurisdiction | Texas           |          |
    | Jurisdiction | Harris          |          |
  And Texas is the parent jurisdiction of:
    | Harris |
  And Harris has the following school districts:
    | HoustonTest | 101912 |
  And "HoustonTest" has the following schools:
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
    | HoustonTest |
  And rollcall user "nurse.betty@example.com" has the following schools assigned:
    | Anderson Elementary |
    | Ashford Elementary  |
    | Yates High School   |

Scenario: Uploading a file
  Given I am logged in as "nurse.betty@example.com"
  When I drop the following "Attendance" file in the rollcall directory for "HoustonTest":
  """
  "AbsenceDate","CampusID","SchoolName","Absent"
  "<%= (Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","101912105","Anderson Elementary","2"
  "<%= (Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","101912273","Ashford Elementary","1"
  "<%= (Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","101912020","Yates High School","10"
  "<%= (Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","101912105","Anderson Elementary","5"
  "<%= (Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","101912273","Ashford Elementary","4"
  "<%= (Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","101912020","Yates High School","5"
  """
  And I drop the following "Enrollment" file in the rollcall directory for "HoustonTest":
  """
  "EnrollDate","CampusID","SchoolName","CurrentEnrollment"
  "<%= (Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","101912105","Anderson Elementary","100"
  "<%= (Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","101912273","Ashford Elementary","100"
  "<%= (Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","101912020","Yates High School","200"
  "<%= (Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","101912105","Anderson Elementary","100"
  "<%= (Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","101912273","Ashford Elementary","100"
  "<%= (Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","101912020","Yates High School","200"
  """
  And I drop the following "ILI" file in the rollcall directory for "HoustonTest":
  """
  "CID","HealthYear","CampusID","CampusName","OrigDate","DateOfOnset","Temperature","Symptoms","Zip","Grade","InSchool","Confirmed","Released","Diagnosis","Treatment","Name","Contact","Phone","DOB","Gender","Race","FollowUp","Doctor","DoctorAddress"
  "1","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912105","Anderson Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","Cough,Temperature","","2","","true","","","","","","","02/13/2003","M","","","",""
  "2","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912105","Anderson Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","1","","false","","","","","","","03/01/2004","F","","","",""
  "3","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912105","Anderson Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","Cough,Temperature,Chills","","2","","true","","","","Dorian, John","","","02/13/2003","M","","","",""
  "4","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912105","Anderson Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","1","","false","","","","","","","12/01/2005","F","","","",""
  "5","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912105","Anderson Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","1","","false","","","","","","","09/11/2005","F","","","",""
  "6","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912105","Anderson Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","Congestion,Cough,Headache","","2","","true","","","","","","","05/01/2003","M","","","",""
  "7","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912105","Anderson Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","1","","false","","","","","","","03/01/2004","F","","","",""
  "8","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912273","Ashford Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","Influenza","","3","","true","","","","","","","05/12/2002","F","","","",""
  "9","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912273","Ashford Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","Temperature","","2","","true","","","","","","","01/02/2003","F","","","",""
  "10","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912273","Ashford Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","None","","2","","true","","","","","","","01/22/2004","M","","","",""
  "11","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912273","Ashford Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","Temperature","","2","","true","","","","Turk, Chris","","","08/27/2004","F","","","",""
  "12","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912273","Ashford Elementary","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","Temperature,Cough","","2","","true","","","","","","","02/12/2003","M","","","",""
  "13","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","10","","false","","","","","","","06/16/1995","M","","","",""
  "14","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","12","","false","","","","","","","04/26/1993","F","","","",""
  "15","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","12","","false","","","","","","","02/19/1993","M","","","",""
  "16","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","Lethargy,Headache","","09","","true","","","","","","","08/26/1996","M","","","",""
  "17","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","09","","false","","","","","","","06/30/1996","F","","","",""
  "18","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","09","","false","","","","","","","01/02/1997","M","","","",""
  "19","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","Sore Throat,Cough","","10","","true","","","","","","","03/13/1995","M","","","",""
  "20","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","Diarrhea,Vomiting","","10","","true","","","","Reid, Elliot","","","11/17/1995","M","","","",""
  "21","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","10","","false","","","","","","","09/24/1994","M","","","",""
  "22","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 1.day).strftime("%Y-%m-%d 00:00:00")%>","","","None","","10","","true","","","","","","","02/08/1995","F","","","",""
  "23","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","09","","false","","","","","","","08/04/1996","F","","","",""
  "24","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","11","","false","","","","","","","12/13/1994","M","","","",""
  "25","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","","","10","","false","","","","","","","04/23/1994","F","","","",""
  "26","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","Chills,Cough,Headache","","12","","true","","","","","","","10/17/1993","M","","","",""
  "27","<%=Date.today.last_year.year%>-<%=Date.today.year%>","101912020","Yates High School","<%=(Date.today.at_beginning_of_week - 1.week + 2.day).strftime("%Y-%m-%d 00:00:00")%>","","","Chills,Temperature,Headache","","12","","true","","","","","","","07/23/1993","M","","","",""
  """
  And the rollcall background worker processes for "HoustonTest"

  And I am logged in as "nurse.betty@example.com"
  And I navigate to the ext dashboard page
  And I navigate to "Apps > Rollcall > Nurse Assistant"
  And I wait for the panel to load
  When I press "Change School"
  And I wait for the panel to load
  And I select "Anderson Elementary" from ext combo "select_school"
  And I press "OK"
  And I wait for the panel to load
  And I should see "John" within grid "student_grid" in column "First Name"
  When I press "Change School"
  And I wait for the panel to load
  And I select "Ashford Elementary" from ext combo "select_school"
  And I press "OK"
  And I wait for the panel to load
  And I should see "Chris" within grid "student_grid" in column "First Name"
  When I press "Change School"
  And I wait for the panel to load
  And I select "Yates High School" from ext combo "select_school"
  And I press "OK"
  And I wait for the panel to load
  And I should see "Elliot" within grid "student_grid" in column "First Name"