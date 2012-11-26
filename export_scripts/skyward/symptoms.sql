--BROWNSBORO
SELECT 
"STU_SYMPTOMS"."OFFICE-VISIT-REF-NO" AS 'CID', 
"STUDENT_HEALTH"."SCHOOL-YEAR" AS 'HEALTHYEAR', 
'107902'+"STUDENT_HEALTH"."SCHOOL-ID" AS 'CAMPUSID', 
"SCHOOL1"."SCHOOL-NAME" AS 'CAMPUS_NAME',
"STUDENT_HEALTH"."HLT-DATE" AS 'ORIGDATE', 
' ' AS 'DATEOFONSET',
"STU_SYMPTOMS"."HLT-OVM-TEMPERATURE" AS 'TEMPERATURE', 
"STU_SYMPTOMS"."REASONS" AS 'SYMPTOMS',
"ZIP1"."ZIP-CODE" AS 'ZIP',
("STUDENT_HEALTH"."SCHOOL-YEAR"-"STUDENT1"."GRAD-YR"+12) AS 'GRADE', 
' ' AS 'INSCHOOL',
' ' AS 'CONFIRMED',
' ' AS 'RELEASED',
' ' AS 'DIAGNOSIS',
' ' AS 'TREATMENT',
("NAME_stu"."FIRST-NAME" + ' ' + "NAME_stu"."LAST-NAME") AS 'NAME', 
' ' AS 'CONTACT',
' ' AS 'PHONE',
"NAME_stu"."BIRTHDATE" AS 'DOB', 
"NAME_stu"."GENDER" AS 'GENDER',
"NAME_stu"."RACE-CODE" AS ' RACE', 
' ' AS 'FOLLOWUP',
("NAME_dr"."FIRST-NAME" +  ' ' + "NAME_dr"."LAST-NAME") AS 'DOCTOR' ,
' ' AS 'DOCTORADDRESS'

FROM   "SKYWARD"."PUB"."STUDENT-HEALTH" "STUDENT_HEALTH"

INNER JOIN  "SKYWARD"."PUB"."ENTITY" ON
     "STUDENT_HEALTH"."SCHOOL-YEAR" = "ENTITY"."SCHOOL-YEAR" AND
     "ENTITY"."ENTITY-ID" = '000' AND
	 "STUDENT_HEALTH"."HLT-DATE" <= CURDATE()

INNER JOIN "SKYWARD"."PUB"."STUDENT" "STUDENT1" ON 
   "STUDENT_HEALTH"."STUDENT-ID"="STUDENT1"."STUDENT-ID"

INNER JOIN "SKYWARD"."PUB"."NAME" "NAME_stu" ON 
    "STUDENT1"."NAME-ID"="NAME_stu"."NAME-ID"

LEFT OUTER JOIN "SKYWARD"."PUB"."SCHOOL" "SCHOOL1" ON 
    "STUDENT_HEALTH"."SCHOOL-ID"="SCHOOL1"."SCHOOL-ID"

LEFT OUTER JOIN "SKYWARD"."PUB"."NAME" "NAME_dr" ON 
     "STUDENT1"."PRIMARY-PHYSICIAN"="NAME_dr"."NAME-ID"

LEFT OUTER JOIN "SKYWARD"."PUB"."ADDRESS" "ADDRESS1" ON
     "NAME_stu"."ADDRESS-ID"="ADDRESS1"."ADDRESS-ID"

LEFT OUTER JOIN "SKYWARD"."PUB"."ZIP" "ZIP1" ON 
     "ADDRESS1"."ZIP-CODE"="ZIP1"."ZIP-CODE"

INNER JOIN
(SELECT 
"HLT-OFFICE-VISIT-MST"."STUDENT-ID",
"HLT-OFFICE-VISIT-MST"."OFFICE-VISIT-REF-NO",
"HLT-OFFICE-VISIT-MST"."REF-NO",
"HLT-OFFICE-VISIT-MST"."HLT-OVM-TEMPERATURE",
MIN
(
RTRIM(LTRIM("1CODE"."VISIT-REASON-LDESC")) +
IFNULL(','+LTRIM(RTRIM("2CODE"."VISIT-REASON-LDESC")),'') +
IFNULL(','+LTRIM(RTRIM("3CODE"."VISIT-REASON-LDESC")),'') +
IFNULL(','+LTRIM(RTRIM("4CODE"."VISIT-REASON-LDESC")),'') +
IFNULL(','+LTRIM(RTRIM("5CODE"."VISIT-REASON-LDESC")),'') +
IFNULL(','+LTRIM(RTRIM("6CODE"."VISIT-REASON-LDESC")),'')
) AS "REASONS"

FROM
"PUB"."HLT-OFFICE-VISIT-MST"

INNER JOIN PUB."HLT-OFFICE-VISIT-DTL" "1" ON
"HLT-OFFICE-VISIT-MST"."OFFICE-VISIT-REF-NO"="1"."OFFICE-VISIT-REF-NO"

LEFT OUTER JOIN PUB."HLT-OFFICE-VISIT-REASON" "1CODE" ON
"1"."OFFICE-VISIT-DTL-ID"="1CODE"."VISIT-REASON-ID"

LEFT OUTER JOIN PUB."HLT-OFFICE-VISIT-DTL" "2" ON
"1"."OFFICE-VISIT-REF-NO"="2"."OFFICE-VISIT-REF-NO" AND
"1"."OFFICE-VISIT-DTL-TYPE"="2"."OFFICE-VISIT-DTL-TYPE" AND
"1"."OFFICE-VISIT-DTL-ID"<>"2"."OFFICE-VISIT-DTL-ID"

LEFT OUTER JOIN PUB."HLT-OFFICE-VISIT-REASON" "2CODE" ON
"2"."OFFICE-VISIT-DTL-ID"="2CODE"."VISIT-REASON-ID"

LEFT OUTER JOIN PUB."HLT-OFFICE-VISIT-DTL" "3" ON
"2"."OFFICE-VISIT-REF-NO"="3"."OFFICE-VISIT-REF-NO" AND
"2"."OFFICE-VISIT-DTL-TYPE"="3"."OFFICE-VISIT-DTL-TYPE" AND
"1"."OFFICE-VISIT-DTL-ID"<>"3"."OFFICE-VISIT-DTL-ID" AND
"2"."OFFICE-VISIT-DTL-ID"<>"3"."OFFICE-VISIT-DTL-ID"

LEFT OUTER JOIN PUB."HLT-OFFICE-VISIT-REASON" "3CODE" ON
"3"."OFFICE-VISIT-DTL-ID"="3CODE"."VISIT-REASON-ID"

LEFT OUTER JOIN PUB."HLT-OFFICE-VISIT-DTL" "4" ON
"3"."OFFICE-VISIT-REF-NO"="4"."OFFICE-VISIT-REF-NO" AND
"3"."OFFICE-VISIT-DTL-TYPE"="4"."OFFICE-VISIT-DTL-TYPE" AND
"1"."OFFICE-VISIT-DTL-ID"<>"4"."OFFICE-VISIT-DTL-ID" AND
"2"."OFFICE-VISIT-DTL-ID"<>"4"."OFFICE-VISIT-DTL-ID" AND
"3"."OFFICE-VISIT-DTL-ID"<>"4"."OFFICE-VISIT-DTL-ID"

LEFT OUTER JOIN PUB."HLT-OFFICE-VISIT-REASON" "4CODE" ON
"4"."OFFICE-VISIT-DTL-ID"="4CODE"."VISIT-REASON-ID"

LEFT OUTER JOIN PUB."HLT-OFFICE-VISIT-DTL" "5" ON
"4"."OFFICE-VISIT-REF-NO"="5"."OFFICE-VISIT-REF-NO" AND
"4"."OFFICE-VISIT-DTL-TYPE"="5"."OFFICE-VISIT-DTL-TYPE" AND
"1"."OFFICE-VISIT-DTL-ID"<>"5"."OFFICE-VISIT-DTL-ID" AND
"2"."OFFICE-VISIT-DTL-ID"<>"5"."OFFICE-VISIT-DTL-ID" AND
"3"."OFFICE-VISIT-DTL-ID"<>"5"."OFFICE-VISIT-DTL-ID" AND
"4"."OFFICE-VISIT-DTL-ID"<>"5"."OFFICE-VISIT-DTL-ID"

LEFT OUTER JOIN PUB."HLT-OFFICE-VISIT-REASON" "5CODE" ON
"5"."OFFICE-VISIT-DTL-ID"="5CODE"."VISIT-REASON-ID"

LEFT OUTER JOIN PUB."HLT-OFFICE-VISIT-DTL" "6" ON
"5"."OFFICE-VISIT-REF-NO"="6"."OFFICE-VISIT-REF-NO" AND
"5"."OFFICE-VISIT-DTL-TYPE"="6"."OFFICE-VISIT-DTL-TYPE" AND
"1"."OFFICE-VISIT-DTL-ID"<>"6"."OFFICE-VISIT-DTL-ID" AND
"2"."OFFICE-VISIT-DTL-ID"<>"6"."OFFICE-VISIT-DTL-ID" AND
"3"."OFFICE-VISIT-DTL-ID"<>"6"."OFFICE-VISIT-DTL-ID" AND
"4"."OFFICE-VISIT-DTL-ID"<>"6"."OFFICE-VISIT-DTL-ID" AND
"5"."OFFICE-VISIT-DTL-ID"<>"6"."OFFICE-VISIT-DTL-ID"

LEFT OUTER JOIN PUB."HLT-OFFICE-VISIT-REASON" "6CODE" ON
"6"."OFFICE-VISIT-DTL-ID"="6CODE"."VISIT-REASON-ID"

WHERE
"1"."OFFICE-VISIT-DTL-TYPE"='V' 

GROUP BY
"HLT-OFFICE-VISIT-MST"."STUDENT-ID",
"HLT-OFFICE-VISIT-MST"."OFFICE-VISIT-REF-NO",
"HLT-OFFICE-VISIT-MST"."REF-NO",
"HLT-OFFICE-VISIT-MST"."HLT-OVM-TEMPERATURE"


) AS "STU_SYMPTOMS" ON
"STU_SYMPTOMS"."STUDENT-ID" = "STUDENT_HEALTH"."STUDENT-ID" 
AND "STUDENT_HEALTH"."REF-NO"="STU_SYMPTOMS"."REF-NO" 

