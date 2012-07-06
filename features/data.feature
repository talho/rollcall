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
  And "District1" has the following current district absenteeism data:
    | day          | total_enrolled | total_absent |
    | 20/06/2012   | 400            | 13           |
    | 21/06/2012   | 400            | 14           |
    | 22/06/2012   | 400            | 12           |
    | 23/06/2012   | 400            | 11           |
    | 24/06/2012   | 400            | 14           |
    | 25/06/2012   | 400            | 12           |
    | 26/06/2012   | 400            | 14           |
  And "District1" has the following current school absenteeism data:
    | day          | school_name         | total_enrolled | total_absent |
    | 20/06/2012   | Anderson Elementary | 100            | 2            |
    | 21/06/2012   | Anderson Elementary | 100            | 5            |
    | 22/06/2012   | Anderson Elementary | 100            | 5            |
    | 23/06/2012   | Anderson Elementary | 100            | 5            |
    | 24/06/2012   | Anderson Elementary | 100            | 1            |
    | 25/06/2012   | Anderson Elementary | 100            | 5            |
    | 26/06/2012   | Anderson Elementary | 100            | 3            |
    | 20/06/2012   | Ashford Elementary  | 100            | 1            |
    | 21/06/2012   | Ashford Elementary  | 100            | 4            |
    | 22/06/2012   | Ashford Elementary  | 100            | 5            |
    | 23/06/2012   | Ashford Elementary  | 100            | 7            |
    | 24/06/2012   | Ashford Elementary  | 100            | 1            |
    | 25/06/2012   | Ashford Elementary  | 100            | 4            |
    | 26/06/2012   | Ashford Elementary  | 100            | 4            |
    | 20/06/2012   | Yates High School   | 200            | 10           |
    | 21/06/2012   | Yates High School   | 200            | 4            |
    | 22/06/2012   | Yates High School   | 200            | 5            |
    | 23/06/2012   | Yates High School   | 200            | 9            |
    | 24/06/2012   | Yates High School   | 200            | 5            |
    | 25/06/2012   | Yates High School   | 200            | 8            |
    | 26/06/2012   | Yates High School   | 200            | 5            |
  And "District1" has the following current student absenteeism data:
    | day          | school_name         | age      | first_name | last_name | dob        | grade | gender | confirmed_ill | symptoms                    | student_number |
    | 20/06/2012   | Anderson Elementary | 8        |            |           | 02/13/2003 | 2     | M      | true          | Cough,Temperature           |                |
    | 20/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 21/06/2012   | Anderson Elementary | 8        | John       | Dorian    | 02/13/2003 | 2     | M      | true          | Cough,Temperature,Chills    | 10055500       |
    | 21/06/2012   | Anderson Elementary | 6        |            |           | 12/01/2005 | 1     | F      | false         |                             |                |
    | 21/06/2012   | Anderson Elementary | 6        |            |           | 09/11/2005 | 1     | F      | false         |                             |                |
    | 21/06/2012   | Anderson Elementary | 8        |            |           | 05/01/2003 | 2     | M      | true          | Congestion,Cough,Headache   |                |
    | 21/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 22/06/2012   | Anderson Elementary | 6        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 22/06/2012   | Anderson Elementary | 2        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 23/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 23/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 24/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 24/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 24/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 25/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 25/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 25/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 26/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 26/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 26/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 26/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 26/06/2012   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 20/06/2012   | Ashford Elementary  | 9        |            |           | 05/12/2002 | 3     | F      | true          | Influenza                   |                |
    | 21/06/2012   | Ashford Elementary  | 8        |            |           | 01/02/2003 | 2     | M      | true          | Temperature                 |                |
    | 21/06/2012   | Ashford Elementary  | 7        |            |           | 01/22/2004 | 2     | M      | true          | None                        |                |
    | 21/06/2012   | Ashford Elementary  | 7        | Chris      | Turk      | 08/27/2004 | 2     | F      | true          | Temperature                 | 900800700      |
    | 21/06/2012   | Ashford Elementary  | 8        |            |           | 02/12/2003 | 2     | M      | true          | Temperature,Cough           |                |
    | 22/06/2012   | Ashford Elementary  | 6        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 22/06/2012   | Ashford Elementary  | 2        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 23/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 23/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 24/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 24/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 24/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 25/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 25/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 25/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 26/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 26/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 26/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 26/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 26/06/2012   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 20/06/2012   | Yates High School   | 16       |            |           | 06/16/1995 | 10    | M      | false         |                             |                |
    | 20/06/2012   | Yates High School   | 18       |            |           | 04/26/1993 | 12    | F      | false         |                             |                |
    | 20/06/2012   | Yates High School   | 18       |            |           | 02/19/1993 | 12    | M      | false         |                             |                |
    | 20/06/2012   | Yates High School   | 15       |            |           | 08/26/1996 | 09    | M      | true          | Lethargy,Headache           |                |
    | 20/06/2012   | Yates High School   | 15       |            |           | 06/30/1996 | 09    | F      | false         |                             |                |
    | 20/06/2012   | Yates High School   | 14       |            |           | 01/02/1997 | 09    | M      | false         |                             |                |
    | 20/06/2012   | Yates High School   | 16       |            |           | 03/13/1995 | 10    | M      | true          | Sore Throat,Cough           |                |
    | 20/06/2012   | Yates High School   | 16       | Elliot     | Reid      | 11/17/1995 | 10    | M      | true          | Diarrhea,Vomiting           | 101202303      |
    | 20/06/2012   | Yates High School   | 17       |            |           | 09/24/1994 | 10    | M      | false         |                             |                |
    | 20/06/2012   | Yates High School   | 16       |            |           | 02/08/1995 | 10    | F      | true          | None                        |                |
    | 21/06/2012   | Yates High School   | 15       |            |           | 08/04/1996 | 09    | F      | false         |                             |                |
    | 21/06/2012   | Yates High School   | 17       |            |           | 12/13/1994 | 11    | M      | false         |                             |                |
    | 21/06/2012   | Yates High School   | 17       |            |           | 04/23/1994 | 10    | F      | false         |                             |                |
    | 21/06/2012   | Yates High School   | 18       |            |           | 10/17/1993 | 12    | M      | true          | Chills,Cough,Headache       |                |
    | 21/06/2012   | Yates High School   | 18       |            |           | 07/23/1993 | 12    | M      | true          | Chills,Temperature,Headache |                |
    | 22/06/2012   | Yates High School   | 16       |            |           | 03/01/1993 | 10    | F      | false         |                             |                |
    | 22/06/2012   | Yates High School   | 15       |            |           | 03/01/1993 | 11    | M      | true          | Influenza                   |                |
    | 23/06/2012   | Yates High School   | 16       |            |           | 03/01/1993 | 12    | M      | false         |                             |                |
    | 23/06/2012   | Yates High School   | 18       |            |           | 03/01/1993 | 10    | F      | true          | Influenza                   |                |
    | 24/06/2012   | Yates High School   | 17       |            |           | 03/01/1993 | 11    | F      | false         |                             |                |
    | 24/06/2012   | Yates High School   | 15       |            |           | 03/01/1993 | 12    | M      | false         |                             |                |
    | 24/06/2012   | Yates High School   | 17       |            |           | 03/01/1993 | 10    | F      | false         |                             |                |
    | 25/06/2012   | Yates High School   | 18       |            |           | 03/01/1993 | 10    | M      | true          | Influenza                   |                |
    | 25/06/2012   | Yates High School   | 14       |            |           | 03/01/1993 | 09    | F      | false         |                             |                |
    | 25/06/2012   | Yates High School   | 16       |            |           | 03/01/1993 | 11    | F      | true          | Influenza                   |                |
    | 26/06/2012   | Yates High School   | 15       |            |           | 03/01/1993 | 12    | F      | false         |                             |                |
    | 26/06/2012   | Yates High School   | 17       |            |           | 03/01/1993 | 11    | M      | true          | Influenza                   |                |
    | 26/06/2012   | Yates High School   | 18       |            |           | 03/01/1993 | 11    | F      | false         |                             |                |
    | 26/06/2012   | Yates High School   | 15       |            |           | 03/01/1993 | 09    | F      | true          | Influenza                   |                |
    | 26/06/2012   | Yates High School   | 17       |            |           | 03/01/1993 | 15    | M      | true          | Influenza                   |                |

Scenario: School District ILI
  When I do get_data for "District1" with:
    | symptoms  |  487.1       |
  Then get_data should return:
    | 1         | 20/06/2012   |    
    | 3         | 22/06/2012   |
    | 1         | 23/06/2012   |
    | 4         | 24/06/2012   |
    | 2         | 25/06/2012   |
    | 7         | 26/06/2012   |        

Scenario: School ILI
  When I do get_data for "Ashford Elementary" with:
    | symptoms  |  487.1       |
  Then get_data should return:
    | 1         | 20/06/2012   |                        
    | 1         | 22/06/2012   |                       
    | 2         | 24/06/2012   |                           
    | 2         | 26/06/2012   |                      

Scenario: School District Data Function Standard Deviation
  When I do get_data for "District1" with:
    | data_func | Standard Deviation          |
  Then get_data should return:
    | 13        | 20/06/2012   | 0.0          |
    | 14        | 21/06/2012   | 0.5          |
    | 12        | 22/06/2012   | 0.816        |
    | 11        | 23/06/2012   | 1.118        |
    | 14        | 24/06/2012   | 1.166        |
    | 12        | 25/06/2012   | 1.106        |
    | 14        | 26/06/2012   | 1.125        |
  
Scenario: School District Data Function Cusum
  When I do get_data for "District1" with:
    | data_func | Cusum        |
  Then get_data should return:
    | 13        | 20/06/2012   | 0.143        |
    | 14        | 21/06/2012   | 1.286        |
    | 12        | 22/06/2012   | 0.429        |
    | 11        | 23/06/2012   | 0            |
    | 14        | 24/06/2012   | 1.143        |
    | 12        | 25/06/2012   | 0            |
    | 14        | 26/06/2012   | 1.143        |
    
Scenario: School District Data Function Average
  When I do get_data for "District1" with:
    | data_func | Average      |
  Then get_data should return:
    | 13        | 20/06/2012   | 13           |
    | 14        | 21/06/2012   | 13.5         |
    | 12        | 22/06/2012   | 13           |
    | 11        | 23/06/2012   | 12.5         |
    | 14        | 24/06/2012   | 12.8         |
    | 12        | 25/06/2012   | 12.667       |
    | 14        | 26/06/2012   | 12.857       |
    
Scenario: School District Data Function Average 30
  When I do get_data for "District1" with:
    | data_func | Average 30 Day |
  Then get_data should return:
    | 13        | 20/06/2012   | 13           |
    | 14        | 21/06/2012   | 13.5         |
    | 12        | 22/06/2012   | 13           |
    | 11        | 23/06/2012   | 12.5         |
    | 14        | 24/06/2012   | 12.8         |
    | 12        | 25/06/2012   | 12.667       |
    | 14        | 26/06/2012   | 12.857       |
    
Scenario: School District Data Function Average 60
  When I do get_data for "District1" with:
    | data_func | Average 60 Day |
  Then get_data should return:
    | 13        | 20/06/2012   | 13           |
    | 14        | 21/06/2012   | 13.5         |
    | 12        | 22/06/2012   | 13           |
    | 11        | 23/06/2012   | 12.5         |
    | 14        | 24/06/2012   | 12.8         |
    | 12        | 25/06/2012   | 12.667       |
    | 14        | 26/06/2012   | 12.857       |
    
Scenario: School Data Function Standard Deviation
  When I do get_data for "Ashford Elementary" with:
    | data_func | Standard Deviation          |
  Then get_data should return:
    | 1         | 20/06/2012   | 0.0          |
    | 4         | 21/06/2012   | 1.5          |
    | 5         | 22/06/2012   | 1.7          |
    | 7         | 23/06/2012   | 2.165        |
    | 1         | 24/06/2012   | 2.332        |
    | 4         | 25/06/2012   | 2.134        |
    | 4         | 26/06/2012   | 1.979        |
  
Scenario: School Data Function Cusum
  When I do get_data for "Ashford Elementary" with:
    | data_func | Cusum        |
  Then get_data should return:
    | 1         | 20/06/2012   | 0.0          |
    | 4         | 21/06/2012   | 0.0          |
    | 5         | 22/06/2012   | 0.333        |
    | 7         | 23/06/2012   | 2.333        |
    | 1         | 24/06/2012   | 0.0          |
    | 4         | 25/06/2012   | 0.0          |
    | 4         | 26/06/2012   | 0.0          |
    
Scenario: School Data Function Average
  When I do get_data for "Ashford Elementary" with:
    | data_func | Average      |
  Then get_data should return:
    | 1         | 20/06/2012   | 1            |
    | 4         | 21/06/2012   | 2.5          |
    | 5         | 22/06/2012   | 3.333        |
    | 7         | 23/06/2012   | 4.25         |
    | 1         | 24/06/2012   | 3.6          |
    | 4         | 25/06/2012   | 3.667        |
    | 4         | 26/06/2012   | 3.714        |
    
Scenario: School Data Function Average 30
  When I do get_data for "Ashford Elementary" with:
    | data_func | Average 30 Day |
  Then get_data should return:
    | 1         | 20/06/2012   | 1            |
    | 4         | 21/06/2012   | 2.5          |
    | 5         | 22/06/2012   | 3.333        |
    | 7         | 23/06/2012   | 4.25         |
    | 1         | 24/06/2012   | 3.6          |
    | 4         | 25/06/2012   | 3.667        |
    | 4         | 26/06/2012   | 3.714        |
    
Scenario: School Data Function Average 60
  When I do get_data for "Ashford Elementary" with:
    | data_func | Average 60 Day |
  Then get_data should return:
    | 1         | 20/06/2012   | 1            |
    | 4         | 21/06/2012   | 2.5          |
    | 5         | 22/06/2012   | 3.333        |
    | 7         | 23/06/2012   | 4.25         |
    | 1         | 24/06/2012   | 3.6          |
    | 4         | 25/06/2012   | 3.667        |
    | 4         | 26/06/2012   | 3.714        |    
    
Scenario: School Confirmed Illness
  When I do get_data for "Ashford Elementary" with:
    | absent    | Confirmed Illness |
  Then get_data should return:
    | 1         | 20/06/2012        |              
    | 4         | 21/06/2012        |              
    | 1         | 22/06/2012        |              
    | 2         | 24/06/2012        |              
    | 2         | 26/06/2012        |              
    
Scenario: Date Range Start and End Date
  When I do get_data for "Ashford Elementary" with:
    | startdt   | 20/06/2012   |
    | enddt     | 22/06/2012   |
  Then get_data should return:
    | 1         | 20/06/2012   |              
    | 4         | 21/06/2012   |              
    | 5         | 22/06/2012   |
    
Scenario: Date Range Start Date
  When I do get_data for "Ashford Elementary" with:
    | startdt   | 23/06/2012   |
  Then get_data should return:
    | 7         | 23/06/2012   |
    | 1         | 24/06/2012   |              
    | 4         | 25/06/2012   |              
    | 4         | 26/06/2012   |

Scenario: Date Range End Date
  When I do get_data for "Ashford Elementary" with:
    | enddt     | 21/06/2012   |
  Then get_data should return:
    | 1         | 20/06/2012   |              
    | 4         | 21/06/2012   |                    

    