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
    | day | total_enrolled | total_absent |
    | 1   | 400            | 13           |
    | 2   | 400            | 14           |
    | 3   | 400            | 12           |
    | 4   | 400            | 11           |
    | 5   | 400            | 14           |
    | 6   | 400            | 12           |
    | 7   | 400            | 14           |
  And "District1" has the following current school absenteeism data:
    | day | school_name         | total_enrolled | total_absent |
    | 1   | Anderson Elementary | 100            | 2            |
    | 2   | Anderson Elementary | 100            | 5            |
    | 3   | Anderson Elementary | 100            | 5            |
    | 4   | Anderson Elementary | 100            | 5            |
    | 5   | Anderson Elementary | 100            | 1            |
    | 6   | Anderson Elementary | 100            | 5            |
    | 7   | Anderson Elementary | 100            | 3            |
    | 1   | Ashford Elementary  | 100            | 1            |
    | 2   | Ashford Elementary  | 100            | 4            |
    | 3   | Ashford Elementary  | 100            | 5            |
    | 4   | Ashford Elementary  | 100            | 7            |
    | 5   | Ashford Elementary  | 100            | 1            |
    | 6   | Ashford Elementary  | 100            | 4            |
    | 7   | Ashford Elementary  | 100            | 4            |
    | 1   | Yates High School   | 200            | 10           |
    | 2   | Yates High School   | 200            | 4            |
    | 3   | Yates High School   | 200            | 5            |
    | 4   | Yates High School   | 200            | 9            |
    | 5   | Yates High School   | 200            | 5            |
    | 6   | Yates High School   | 200            | 8            |
    | 7   | Yates High School   | 200            | 5            |
  And "District1" has the following current student absenteeism data:
    | day | school_name         | age      | first_name | last_name | dob        | grade | gender | confirmed_ill | symptoms                    | student_number |
    | 1   | Anderson Elementary | 8        |            |           | 02/13/2003 | 2     | M      | true          | Cough,Temperature           |                |
    | 1   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 8        | John       | Dorian    | 02/13/2003 | 2     | M      | true          | Cough,Temperature,Chills    | 10055500       |
    | 2   | Anderson Elementary | 6        |            |           | 12/01/2005 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 6        |            |           | 09/11/2005 | 1     | F      | false         |                             |                |
    | 2   | Anderson Elementary | 8        |            |           | 05/01/2003 | 2     | M      | true          | Congestion,Cough,Headache   |                |
    | 2   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 3   | Anderson Elementary | 6        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 3   | Anderson Elementary | 2        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 4   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 4   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 5   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 5   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 5   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 6   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 6   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 6   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 7   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 7   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 7   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 7   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 7   | Anderson Elementary | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 1   | Ashford Elementary  | 9        |            |           | 05/12/2002 | 3     | F      | true          | Influenza                   |                |
    | 2   | Ashford Elementary  | 8        |            |           | 01/02/2003 | 2     | M      | true          | Temperature                 |                |
    | 2   | Ashford Elementary  | 7        |            |           | 01/22/2004 | 2     | M      | true          | None                        |                |
    | 2   | Ashford Elementary  | 7        | Chris      | Turk      | 08/27/2004 | 2     | F      | true          | Temperature                 | 900800700      |
    | 2   | Ashford Elementary  | 8        |            |           | 02/12/2003 | 2     | M      | true          | Temperature,Cough           |                |
    | 3   | Ashford Elementary  | 6        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 3   | Ashford Elementary  | 2        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 4   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 4   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 5   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 5   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | true          | Influenza                   |                |
    | 5   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 6   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 6   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | false         |                             |                |
    | 6   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 7   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 7   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 7   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
    | 7   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | M      | true          | Influenza                   |                |
    | 7   | Ashford Elementary  | 7        |            |           | 03/01/2004 | 1     | F      | false         |                             |                |
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
    | 3   | Yates High School   | 16       |            |           | 03/01/1993 | 10    | F      | false         |                             |                |
    | 3   | Yates High School   | 15       |            |           | 03/01/1993 | 11    | M      | true          | Influenza                   |                |
    | 4   | Yates High School   | 16       |            |           | 03/01/1993 | 12    | M      | false         |                             |                |
    | 4   | Yates High School   | 18       |            |           | 03/01/1993 | 10    | F      | true          | Influenza                   |                |
    | 5   | Yates High School   | 17       |            |           | 03/01/1993 | 11    | F      | false         |                             |                |
    | 5   | Yates High School   | 15       |            |           | 03/01/1993 | 12    | M      | false         |                             |                |
    | 5   | Yates High School   | 17       |            |           | 03/01/1993 | 10    | F      | false         |                             |                |
    | 6   | Yates High School   | 18       |            |           | 03/01/1993 | 10    | M      | true          | Influenza                   |                |
    | 6   | Yates High School   | 14       |            |           | 03/01/1993 | 09    | F      | false         |                             |                |
    | 6   | Yates High School   | 16       |            |           | 03/01/1993 | 11    | F      | true          | Influenza                   |                |
    | 7   | Yates High School   | 15       |            |           | 03/01/1993 | 12    | F      | false         |                             |                |
    | 7   | Yates High School   | 17       |            |           | 03/01/1993 | 11    | M      | true          | Influenza                   |                |
    | 7   | Yates High School   | 18       |            |           | 03/01/1993 | 11    | F      | false         |                             |                |
    | 7   | Yates High School   | 15       |            |           | 03/01/1993 | 09    | F      | true          | Influenza                   |                |
    | 7   | Yates High School   | 17       |            |           | 03/01/1993 | 15    | M      | true          | Influenza                   |                |

Scenario: School District ILI
  When I do get_data for "District1" with:
    | symptoms  |  487.1       |
  Then get_data should return:
    | 1         | 0            |    
    | 3         | -2           |
    | 1         | -3           |
    | 4         | -4           |
    | 2         | -5           |
    | 7         | -6           |        

Scenario: School ILI
  When I do get_data for "Ashford Elementary" with:
    | symptoms  |  487.1       |
  Then get_data should return:
    | 1         | 0            |                        
    | 1         | -2           |                       
    | 2         | -4           |                           
    | 2         | -6           |                      

Scenario: School District Data Function Standard Deviation
  When I do get_data for "District1" with:
    | data_func | Standard Deviation          |
  Then get_data should return:
    | 13        | 1            | .143         |
    | 14        | 2            | 1.286        |
    | 12        | 3            | 1.286        |
    | 11        | 4            | 1.286        |
    | 14        | 5            | 2.429        |
    | 12        | 6            | 2.429        |
    | 14        | 7            | 3.572        |
  
Scenario: School District Data Function Cusum
  When I do get_data for "District1" with:
    | data_func | Cusum        |
  Then get_data should return:
    | 13        | 1            | 1.143        |
    | 14        | 2            | .286         |
    | 12        | 3            | 1.429        |
    | 11        | 4            | 0            |
    | 14        | 5            | 0            |
    | 12        | 6            | 1.143        |
    | 14        | 7            | 1.286        |
    
Scenario: School District Data Function Average
  When I do get_data for "District1" with:
    | data_func | Average      |
  Then get_data should return:
    | 13        | 1            | 12.857       |
    | 14        | 2            | 12.833       |
    | 12        | 3            | 12.6         |
    | 11        | 4            | 12.75        |
    | 14        | 5            | 13.333       |
    | 12        | 6            | 13           |
    | 14        | 7            | 14           |
    
Scenario: School District Data Function Average 30
  When I do get_data for "District1" with:
    | data_func | Average 30 Day |
  Then get_data should return:
    | 13        | 1            | 12.857       |
    | 14        | 2            | 12.833       |
    | 12        | 3            | 12.6         |
    | 11        | 4            | 12.75        |
    | 14        | 5            | 13.333       |
    | 12        | 6            | 13           |
    | 14        | 7            | 14           |
    
Scenario: School District Data Function Average 60
  When I do get_data for "District1" with:
    | data_func | Average 60 Day |
  Then get_data should return:
    | 13        | 1            | 12.857       |
    | 14        | 2            | 12.833       |
    | 12        | 3            | 12.6         |
    | 11        | 4            | 12.75        |
    | 14        | 5            | 13.333       |
    | 12        | 6            | 13           |
    | 14        | 7            | 14           |
    
Scenario: School Data Function Standard Deviation
  When I do get_data for "Ashford Elementary" with:
    | data_func | Standard Deviation          |
  Then get_data should return:
    | 1         | 1            | .143         |
    | 4         | 2            | 1.286        |
    | 5         | 3            | 1.286        |
    | 7         | 4            | 1.286        |
    | 1         | 5            | 2.429        |
    | 4         | 6            | 2.429        |
    | 4         | 7            | 3.572        |
  
Scenario: School Data Function Cusum
  When I do get_data for "Ashford Elementary" with:
    | data_func | Cusum        |
  Then get_data should return:
    | 1         | 1            | .143         |
    | 4         | 2            | 1.286        |
    | 5         | 3            | 1.286        |
    | 7         | 4            | 1.286        |
    | 1         | 5            | 2.429        |
    | 4         | 6            | 2.429        |
    | 4         | 7            | 3.572        |
    
Scenario: School Data Function Average
  When I do get_data for "Ashford Elementary" with:
    | data_func | Average      |
  Then get_data should return:
    | 4         | 1            | 3.714        |
    | 4         | 2            | 3.667        |
    | 1         | 3            | 3.6          |
    | 7         | 4            | 4.25         |
    | 5         | 5            | 3.333        |
    | 4         | 6            | 2.5          |
    | 1         | 7            | 1            |
    
Scenario: School Data Function Average 30
  When I do get_data for "Ashford Elementary" with:
    | data_func | Average 30 Day |
  Then get_data should return:
    | 4         | 1            | 3.714        |
    | 4         | 2            | 3.667        |
    | 1         | 3            | 3.6          |
    | 7         | 4            | 4.25         |
    | 5         | 5            | 3.333        |
    | 4         | 6            | 2.5          |
    | 1         | 7            | 1            |
    
Scenario: School Data Function Average 60
  When I do get_data for "Ashford Elementary" with:
    | data_func | Average 60 Day |
  Then get_data should return:
    | 4         | 1            | 3.714        |
    | 4         | 2            | 3.667        |
    | 1         | 3            | 3.6          |
    | 7         | 4            | 4.25         |
    | 5         | 5            | 3.333        |
    | 4         | 6            | 2.5          |
    | 1         | 7            | 1            |           
    
Scenario: School Confirmed Illness
  When I do get_data for "Ashford Elementary" with:
    | absent    | Confirmed Illness |
  Then get_data should return:
    | 1         | 0                 |              
    | 4         | -1                |              
    | 1         | -2                |              
    | 2         | -4                |              
    | 2         | -6                |              
    
Scenario: Date Range Start and End Date
  When I do get_data for "Ashford Elementary" with:
    | startdt   | 3            |
    | enddt     | 1            |
  Then get_data should return:
    | 4         | 1            |              
    | 4         | 2            |              
    | 1         | 3            |
    
Scenario: Date Range Start Date
  When I do get_data for "Ashford Elementary" with:
    | startdt   | 4            |
  Then get_data should return:
    | 4         | 1            |
    | 4         | 2            |              
    | 1         | 3            |              
    | 7         | 4            |

Scenario: Date Range End Date
  When I do get_data for "Ashford Elementary" with:
    | enddt     | 2            |
  Then get_data should return:
    | 4         | 2            |              
    | 1         | 3            |              
    | 7         | 4            |
    | 5         | 5            |
    | 4         | 6            |
    | 1         | 7            |         

    