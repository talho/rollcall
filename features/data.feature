Feature:  Test all paths of data.rb
  In order to process
  As the system
  The data should be correct
  
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
  And rollcall user "nurse.betty@example.com" has the following schools assigned:
    | Anderson Elementary               |
    | Ashford Elementary                |
    | Yates High School                 |
  And "District1" has the following current school absenteeism data:
    | day          | school_name         | total_enrolled | total_absent |
    | 2012-06-20   | Anderson Elementary | 100            | 2            |
    | 2012-06-21   | Anderson Elementary | 100            | 5            |
    | 2012-06-22   | Anderson Elementary | 100            | 5            |
    | 2012-06-23   | Anderson Elementary | 100            | 5            |
    | 2012-06-24   | Anderson Elementary | 100            | 1            |
    | 2012-06-25   | Anderson Elementary | 100            | 5            |
    | 2012-06-26   | Anderson Elementary | 100            | 3            |
    | 2012-06-20   | Ashford Elementary  | 100            | 1            |
    | 2012-06-21   | Ashford Elementary  | 100            | 4            |
    | 2012-06-22   | Ashford Elementary  | 100            | 5            |
    | 2012-06-23   | Ashford Elementary  | 100            | 7            |
    | 2012-06-24   | Ashford Elementary  | 100            | 1            |
    | 2012-06-25   | Ashford Elementary  | 100            | 4            |
    | 2012-06-26   | Ashford Elementary  | 100            | 4            |
    | 2012-06-20   | Yates High School   | 200            | 10           |
    | 2012-06-21   | Yates High School   | 200            | 4            |
    | 2012-06-22   | Yates High School   | 200            | 5            |
    | 2012-06-23   | Yates High School   | 200            | 9            |
    | 2012-06-24   | Yates High School   | 200            | 5            |
    | 2012-06-25   | Yates High School   | 200            | 8            |
    | 2012-06-26   | Yates High School   | 200            | 5            |
  And "District1" has the following current student absenteeism data:
    | day          | school_name         | age      | first_name | last_name | dob        | grade | gender | confirmed_ill | symptoms                    | student_number |
    | 2012-06-20   | Anderson Elementary | 8        |            |           | 02/13/2003 | 2     | M      | true          | Cough,Temperature           |                |
    | 2012-06-20   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-21   | Anderson Elementary | 8        | John       | Dorian    | 02/13/2003 | 2     | M      | true          | Cough,Temperature,Chills    | 10055500       |
    | 2012-06-21   | Anderson Elementary | 6        |            |           | 12/01/2005 | 1     | F      | false         |                             |                |
    | 2012-06-21   | Anderson Elementary | 6        |            |           | 09/11/2005 | 1     | F      | false         |                             |                |
    | 2012-06-21   | Anderson Elementary | 8        |            |           | 05/01/2003 | 2     | M      | true          | Congestion,Cough,Headache   |                |
    | 2012-06-21   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-22   | Anderson Elementary | 6        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 2012-06-22   | Anderson Elementary | 2        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 2012-06-23   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 2012-06-23   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-24   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 2012-06-24   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 2012-06-24   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 2012-06-25   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-25   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 2012-06-25   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-26   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-26   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 2012-06-26   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 2012-06-26   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 2012-06-26   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-20   | Ashford Elementary  | 9        |            |           | 05/12/2002 | 3     | F      | true          | Influenza                   |                |
    | 2012-06-21   | Ashford Elementary  | 8        |            |           | 01/02/2003 | 2     | M      | true          | Temperature                 |                |
    | 2012-06-21   | Ashford Elementary  | 7        |            |           | 01/22/2004 | 2     | M      | true          | None                        |                |
    | 2012-06-21   | Ashford Elementary  | 7        | Chris      | Turk      | 08/27/2004 | 2     | F      | true          | Temperature                 | 900800700      |
    | 2012-06-21   | Ashford Elementary  | 8        |            |           | 02/12/2003 | 2     | M      | true          | Temperature,Cough           |                |
    | 2012-06-22   | Ashford Elementary  | 6        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-22   | Ashford Elementary  | 2        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 2012-06-23   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 2012-06-23   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-24   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 2012-06-24   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 2012-06-24   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-25   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 2012-06-25   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 2012-06-25   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-26   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 2012-06-26   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-26   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-26   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 2012-06-26   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2012-06-20   | Yates High School   | 16       |            |           | 06/16/1995 | 10    | M      | false         |                             |                |
    | 2012-06-20   | Yates High School   | 18       |            |           | 04/26/1993 | 12    | F      | false         |                             |                |
    | 2012-06-20   | Yates High School   | 18       |            |           | 02/19/1993 | 12    | M      | false         |                             |                |
    | 2012-06-20   | Yates High School   | 15       |            |           | 08/26/1996 | 09    | M      | true          | Lethargy,Headache           |                |
    | 2012-06-20   | Yates High School   | 15       |            |           | 06/30/1996 | 09    | F      | false         |                             |                |
    | 2012-06-20   | Yates High School   | 14       |            |           | 01/02/1997 | 09    | M      | false         |                             |                |
    | 2012-06-20   | Yates High School   | 16       |            |           | 03/13/1995 | 10    | M      | true          | Sore Throat,Cough           |                |
    | 2012-06-20   | Yates High School   | 16       | Elliot     | Reid      | 11/17/1995 | 10    | M      | true          | Diarrhea,Vomiting           | 101202303      |
    | 2012-06-20   | Yates High School   | 17       |            |           | 09/24/1994 | 10    | M      | false         |                             |                |
    | 2012-06-20   | Yates High School   | 16       |            |           | 02/08/1995 | 10    | F      | true          | None                        |                |
    | 2012-06-21   | Yates High School   | 15       |            |           | 08/04/1996 | 09    | F      | false         |                             |                |
    | 2012-06-21   | Yates High School   | 17       |            |           | 12/13/1994 | 11    | M      | false         |                             |                |
    | 2012-06-21   | Yates High School   | 17       |            |           | 04/23/1994 | 10    | F      | false         |                             |                |
    | 2012-06-21   | Yates High School   | 18       |            |           | 10/17/1993 | 12    | M      | true          | Chills,Cough,Headache       |                |
    | 2012-06-21   | Yates High School   | 18       |            |           | 07/23/1993 | 12    | M      | true          | Chills,Temperature,Headache |                |
    | 2012-06-22   | Yates High School   | 16       |            |           | 03/01/1993 | 10    | F      | false         |                             |                |
    | 2012-06-22   | Yates High School   | 15       |            |           | 03/01/1993 | 11    | M      | true          | Influenza                   |                |
    | 2012-06-23   | Yates High School   | 16       |            |           | 03/01/1993 | 12    | M      | false         |                             |                |
    | 2012-06-23   | Yates High School   | 18       |            |           | 03/01/1993 | 10    | F      | true          | Influenza                   |                |
    | 2012-06-24   | Yates High School   | 17       |            |           | 03/01/1993 | 11    | F      | false         |                             |                |
    | 2012-06-24   | Yates High School   | 15       |            |           | 03/01/1993 | 12    | M      | false         |                             |                |
    | 2012-06-24   | Yates High School   | 17       |            |           | 03/01/1993 | 10    | F      | false         |                             |                |
    | 2012-06-25   | Yates High School   | 18       |            |           | 03/01/1993 | 10    | M      | true          | Influenza                   |                |
    | 2012-06-25   | Yates High School   | 14       |            |           | 03/01/1993 | 09    | F      | false         |                             |                |
    | 2012-06-25   | Yates High School   | 16       |            |           | 03/01/1993 | 11    | F      | true          | Influenza                   |                |
    | 2012-06-26   | Yates High School   | 15       |            |           | 03/01/1993 | 12    | F      | false         |                             |                |
    | 2012-06-26   | Yates High School   | 17       |            |           | 03/01/1993 | 11    | M      | true          | Influenza                   |                |
    | 2012-06-26   | Yates High School   | 18       |            |           | 03/01/1993 | 11    | F      | false         |                             |                |
    | 2012-06-26   | Yates High School   | 15       |            |           | 03/01/1993 | 09    | F      | true          | Influenza                   |                |
    | 2012-06-26   | Yates High School   | 17       |            |           | 03/01/1993 | 15    | M      | true          | Influenza                   |                |

Scenario: School District ILI
  When I do get_data for "District1" with:
    | symptoms  |  487.1       |
  Then get_data should return:
    | 1         | 2012-06-20   |    
    | 3         | 2012-06-22   |
    | 1         | 2012-06-23   |
    | 4         | 2012-06-24   |
    | 2         | 2012-06-25   |
    | 7         | 2012-06-26   |        

Scenario: School ILI
  When I do get_data for "Ashford Elementary" with:
    | symptoms  |  487.1       |
  Then get_data should return:
    | 1         | 2012-06-20   |                        
    | 1         | 2012-06-22   |                       
    | 2         | 2012-06-24   |                           
    | 2         | 2012-06-26   |                      

Scenario: School District Data Function Standard Deviation
  When I do get_data for "District1" with:
    | data_func | Standard Deviation          |
  Then get_data should return:
    | 13        | 2012-06-20   | 0            |
    | 13        | 2012-06-21   | 0            |
    | 15        | 2012-06-22   | 0.943        |
    | 21        | 2012-06-23   | 3.279        |
    | 7         | 2012-06-24   | 4.49         |
    | 17        | 2012-06-25   | 4.269        |
    | 12        | 2012-06-26   | 4.036        |
  
Scenario: School District Data Function Cusum
  When I do get_data for "District1" with:
    | data_func | Cusum        |
  Then get_data should return:
    | 13        | 2012-06-20   | 0            |
    | 13        | 2012-06-21   | 0            |
    | 15        | 2012-06-22   | 0            |
    | 21        | 2012-06-23   | 6            |
    | 7         | 2012-06-24   | 0            |
    | 17        | 2012-06-25   | 2            |
    | 12        | 2012-06-26   | 0            |
    
Scenario: School District Data Function Average
  When I do get_data for "District1" with:
    | data_func | Average      |
  Then get_data should return:
    | 13        | 2012-06-20   | 13           |
    | 13        | 2012-06-21   | 13           |
    | 15        | 2012-06-22   | 13.667       |
    | 21        | 2012-06-23   | 15.5         |
    | 7         | 2012-06-24   | 13.8         |
    | 17        | 2012-06-25   | 14.333       |
    | 12        | 2012-06-26   | 14           |
    
Scenario: School District Data Function Average 30
  When I do get_data for "District1" with:
    | data_func | Average 30 Day |
  Then get_data should return:
    | 13        | 2012-06-20   | 13           |
    | 13        | 2012-06-21   | 13           |
    | 15        | 2012-06-22   | 13.667       |
    | 21        | 2012-06-23   | 15.5         |
    | 7         | 2012-06-24   | 13.8         |
    | 17        | 2012-06-25   | 14.333       |
    | 12        | 2012-06-26   | 14           |
    
Scenario: School District Data Function Average 60
  When I do get_data for "District1" with:
    | data_func | Average 60 Day |
  Then get_data should return:
    | 13        | 2012-06-20   | 13           |
    | 13        | 2012-06-21   | 13           |
    | 15        | 2012-06-22   | 13.667       |
    | 21        | 2012-06-23   | 15.5         |
    | 7         | 2012-06-24   | 13.8         |
    | 17        | 2012-06-25   | 14.333       |
    | 12        | 2012-06-26   | 14           |
    
Scenario: School Data Function Standard Deviation
  When I do get_data for "Ashford Elementary" with:
    | data_func | Standard Deviation          |
  Then get_data should return:
    | 1         | 2012-06-20   | 0.0          |
    | 4         | 2012-06-21   | 1.5          |
    | 5         | 2012-06-22   | 1.7          |
    | 7         | 2012-06-23   | 2.165        |
    | 1         | 2012-06-24   | 2.332        |
    | 4         | 2012-06-25   | 2.134        |
    | 4         | 2012-06-26   | 1.979        |
  
Scenario: School Data Function Cusum
  When I do get_data for "Ashford Elementary" with:
    | data_func | Cusum        |
  Then get_data should return:
    | 1         | 2012-06-20   | 0            |
    | 4         | 2012-06-21   | 0            |
    | 5         | 2012-06-22   | 0            |
    | 7         | 2012-06-23   | 2.143        |
    | 1         | 2012-06-24   | 0            |
    | 4         | 2012-06-25   | 0            |
    | 4         | 2012-06-26   | 0            |
    
Scenario: School Data Function Average
  When I do get_data for "Ashford Elementary" with:
    | data_func | Average      |
  Then get_data should return:
    | 1         | 2012-06-20   | 1            |
    | 4         | 2012-06-21   | 2.5          |
    | 5         | 2012-06-22   | 3.333        |
    | 7         | 2012-06-23   | 4.25         |
    | 1         | 2012-06-24   | 3.6          |
    | 4         | 2012-06-25   | 3.667        |
    | 4         | 2012-06-26   | 3.714        |
    
Scenario: School Data Function Average 30
  When I do get_data for "Ashford Elementary" with:
    | data_func | Average 30 Day |
  Then get_data should return:
    | 1         | 2012-06-20   | 1            |
    | 4         | 2012-06-21   | 2.5          |
    | 5         | 2012-06-22   | 3.333        |
    | 7         | 2012-06-23   | 4.25         |
    | 1         | 2012-06-24   | 3.6          |
    | 4         | 2012-06-25   | 3.667        |
    | 4         | 2012-06-26   | 3.714        |
    
Scenario: School Data Function Average 60
  When I do get_data for "Ashford Elementary" with:
    | data_func | Average 60 Day |
  Then get_data should return:
    | 1         | 2012-06-20   | 1            |
    | 4         | 2012-06-21   | 2.5          |
    | 5         | 2012-06-22   | 3.333        |
    | 7         | 2012-06-23   | 4.25         |
    | 1         | 2012-06-24   | 3.6          |
    | 4         | 2012-06-25   | 3.667        |
    | 4         | 2012-06-26   | 3.714        |    
    
Scenario: School Confirmed Illness
  When I do get_data for "Ashford Elementary" with:
    | absent    | Confirmed Illness |
  Then get_data should return:
    | 1         | 2012-06-20        |              
    | 4         | 2012-06-21        |              
    | 1         | 2012-06-22        |              
    | 2         | 2012-06-24        |              
    | 2         | 2012-06-26        |              
    
Scenario: Date Range Start and End Date
  When I do get_data for "Ashford Elementary" with:
    | startdt   | 2012-06-20   |
    | enddt     | 2012-06-22   |
  Then get_data should return:
    | 1         | 2012-06-20   |              
    | 4         | 2012-06-21   |              
    | 5         | 2012-06-22   |
    
Scenario: Date Range Start Date
  When I do get_data for "Ashford Elementary" with:
    | startdt   | 2012-06-23   |
  Then get_data should return:
    | 7         | 2012-06-23   |
    | 1         | 2012-06-24   |              
    | 4         | 2012-06-25   |              
    | 4         | 2012-06-26   |

Scenario: Date Range End Date
  When I do get_data for "Ashford Elementary" with:
    | enddt     | 2012-06-21   |
  Then get_data should return:
    | 1         | 2012-06-20   |              
    | 4         | 2012-06-21   |                    

    