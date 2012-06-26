Feature:  School Search
  In order to ensure correct school searching
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
  And "District2" has the following schools:
    | name                              | school_number | tea_id    | school_type       | postal_code | gmap_lat   | gmap_lng    | gmap_addr                                                                        |
    | Ector Junior High School          | 47           | 6890147  | High School       | 79763       | 31.831847  | -102.373438 | "Ector Junior High School, 809 West Clements Street, Odessa, TX 79763-4600"      |
    | Gale Pond Alamo Elementary School | 101           | 68901101  | Elementary School | 79761       | 31.871289  | -102.371464 | "Gale Pond Alamo Elementary School, 801 East 23rd Street, Odessa, TX 79761-1356" |
    | Austin Elementary School          | 102           | 68901102  | Elementary School | 79761       | 31.853575  | -102.373352 | "Austin Elementary School, 200 West 9th Street, Odessa, TX 79761-3956"           |
  And the following users exist:
    | Nurse Betty  | nurse.betty@example.com | Epidemiologist    | Collin | rollcall |
  And rollcall user "nurse.betty@example.com" has the following school districts assigned:
    | District1  |
    | District2  |
  And rollcall user "nurse.betty@example.com" has the following schools assigned:
    | Anderson Elementary               |
    | Ashford Elementary                |
    | Yates High School                 |
    | Ector Junior High School          |
    | Gale Pond Alamo Elementary School |
    | Austin Elementary School          |
    
Scenario: No options
  When I school search with:
    |     |
  Then I find the school ids:
    | 105 |
    | 273 |
    | 20  |
    | 47  |
    | 101 |
    | 102 |
  Then I should not find the school ids:
    |     |

Scenario: All options
  When I school search with:
    | District  | District1                |
    | Zip       | 77035                    |
    | Name      | Austin Elementary School |
    | Type      | Elementary School        |
  Then I find the school ids:
    | 273 |
    | 102 |
    | 105 |
  Then I should not find the school ids:    
    | 20  |
    | 47  |
    | 101 |

Scenario: District
  When I school search with:
    | District  |  District1 |
  Then I find the school ids:
    | 105 |
    | 273 |
    | 20  |
  Then I should not find the school ids:
    | 47  |
    | 101 |
    | 102 |

Scenario: Zip
  When I school search with:
    | Zip       | 79761 |
  Then I find the school ids:
    | 101 |
    | 102 |
  Then I should not find the school ids:
    | 105 |
    | 273 |
    | 20  |
    | 47  |

Scenario: Type
  When I school search with:
    | Type      | High School |
  Then I find the school ids:
    | 20  |
    | 47  |
  Then I should not find the school ids:
    | 105 |
    | 273 |
    | 101 |
    | 102 |

Scenario: Name
  When I school search with:
    | Name      | Austin Elementary School |
  Then I find the school ids:
    | 102 |
  Then I should not find the school ids:
    | 105 |
    | 273 |
    | 20  |
    | 47  |
    | 101 |

Scenario: District, Zip
  When I school search with:
    | District  | District1 |
    | Zip       | 79763     |
  Then I find the school ids:
    | 105 |
    | 273 |
    | 20  |
    | 47  |
  Then I should not find the school ids:
    | 101 |
    | 102 |

Scenario: District, Type
  When I school search with:
    | District  | District1         |
    | Type      | Elementary School |
  Then I find the school ids:
    | 105 |
    | 273 |
  Then I should not find the school ids:
    | 20  |
    | 47  |
    | 101 |
    | 102 |

Scenario: District, Name
  When I school search with:
    | District  | District1                |
    | Name      | Austin Elementary School |
  Then I find the school ids:
    | 105 |
    | 273 |
    | 20  |
    | 102 |
  Then I should not find the school ids:
    | 47  |
    | 101 |

Scenario: Name, Zip
  When I school search with:
    | Zip       | 79763                    |
    | Name      | Austin Elementary School |
  Then I find the school ids:
    | 47  |
    | 102 |
  Then I should not find the school ids:
    | 105 |
    | 273 |
    | 20  |
    | 101 |

Scenario: Name, Type
  When I school search with:
    | Name      | Austin Elementary School |
    | Type      | High School              |
  Then I find the school ids:
    | 20  |
    | 47  |
    | 102 |
  Then I should not find the school ids:
    | 105 |
    | 273 |
    | 101 |

Scenario: Type, Zip
  When I school search with:
    | Zip       | 79763       |
    | Type      | High School |
  Then I find the school ids:
    | 47 |
  Then I should not find the school ids:
    | 105 |
    | 273 |
    | 20  |
    | 101 |
    | 102 |

Scenario: District, Zip, Type
  When I school search with:
    | District  | District1         |
    | Zip       | 79761             |
    | Type      | Elementary School |
  Then I find the school ids:
    | 105 |
    | 273 |        
    | 101 |
    | 102 |
  Then I should not find the school ids:
    | 20  |
    | 47  |

Scenario: District, Zip, Name
  When I school search with:
    | District  | District1                |
    | Zip       | 79761                    |
    | Name      | Ector Junior High School |
  Then I find the school ids:
    | 105 |
    | 273 |
    | 20  |
    | 47  |
    | 101 |
    | 102 |
  Then I should not find the school ids:
    |     |

Scenario: Name, Zip, Type
  When I school search with:
    | Zip       | 79761                    |
    | Name      | Ector Junior High School |
    | Type      | Elementary School        |
  Then I find the school ids:
    | 47  |
    | 101 |
    | 102 |
  Then I should not find the school ids:
    | 105 |
    | 273 |
    | 20  |

Scenario: District, Name, Type
  When I school search with:
    | District  | District1                |    
    | Name      | Austin Elementary School |
    | Type      | Elementary School        |
  Then I find the school ids:
    | 105 |
    | 273 |
    | 102 |
  Then I should not find the school ids:
    | 20  |
    | 47  |
    | 101 |
