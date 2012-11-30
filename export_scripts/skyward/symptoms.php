<?

$outputfile = "./symptoms.csv";
$user = "";
$pass = "";
$dsn = "";
$districtid = "";
$logfilename = "./out.log";
include('include.php');

// Store the query in variable $query.
$query = "SELECT \"STU_SYMPTOMS\".\"OFFICE-VISIT-REF-NO\" AS 'cid', \"STUDENT_HEALTH\".\"SCHOOL-YEAR\" AS 'year', '".$districtid."'+\"STUDENT_HEALTH\".\"SCHOOL-ID\" AS 'campusid', 
       \"SCHOOL1\".\"SCHOOL-NAME\" AS 'school_name', \"STUDENT_HEALTH\".\"HLT-DATE\" AS 'date', \"STU_SYMPTOMS\".\"HLT-OVM-TEMPERATURE\" AS 'temp', 
       \"STU_SYMPTOMS\".\"REASONS\" AS 'symptoms', \"ZIP1\".\"ZIP-CODE\" AS 'zip', (\"STUDENT_HEALTH\".\"SCHOOL-YEAR\"-\"STUDENT1\".\"GRAD-YR\"+12) AS 'grade', 
       \"NAME_stu\".\"GENDER\" AS 'gender', \"NAME_stu\".\"RACE-CODE\" AS 'race', (\"NAME_dr\".\"FIRST-NAME\" +  ' ' + \"NAME_dr\".\"LAST-NAME\") AS 'doctor'
FROM   \"SKYWARD\".\"PUB\".\"STUDENT-HEALTH\" \"STUDENT_HEALTH\"
INNER JOIN  \"SKYWARD\".\"PUB\".\"ENTITY\" ON \"STUDENT_HEALTH\".\"SCHOOL-YEAR\" = \"ENTITY\".\"SCHOOL-YEAR\" AND \"ENTITY\".\"ENTITY-ID\" = '000'
INNER JOIN \"SKYWARD\".\"PUB\".\"STUDENT\" \"STUDENT1\" ON \"STUDENT_HEALTH\".\"STUDENT-ID\"=\"STUDENT1\".\"STUDENT-ID\" 
INNER JOIN \"SKYWARD\".\"PUB\".\"NAME\" \"NAME_stu\" ON \"STUDENT1\".\"NAME-ID\"=\"NAME_stu\".\"NAME-ID\"
LEFT OUTER JOIN \"SKYWARD\".\"PUB\".\"SCHOOL\" \"SCHOOL1\" ON \"STUDENT_HEALTH\".\"SCHOOL-ID\"=\"SCHOOL1\".\"SCHOOL-ID\"
LEFT OUTER JOIN \"SKYWARD\".\"PUB\".\"NAME\" \"NAME_dr\" ON \"STUDENT1\".\"PRIMARY-PHYSICIAN\"=\"NAME_dr\".\"NAME-ID\"
LEFT OUTER JOIN \"SKYWARD\".\"PUB\".\"ADDRESS\" \"ADDRESS1\" ON \"NAME_stu\".\"ADDRESS-ID\"=\"ADDRESS1\".\"ADDRESS-ID\"
LEFT OUTER JOIN \"SKYWARD\".\"PUB\".\"ZIP\" \"ZIP1\" ON \"ADDRESS1\".\"ZIP-CODE\"=\"ZIP1\".\"ZIP-CODE\"
INNER JOIN (SELECT \"HLT-OFFICE-VISIT-MST\".\"STUDENT-ID\", \"HLT-OFFICE-VISIT-MST\".\"OFFICE-VISIT-REF-NO\", \"HLT-OFFICE-VISIT-MST\".\"REF-NO\", \"HLT-OFFICE-VISIT-MST\".\"HLT-OVM-TEMPERATURE\",
	MIN (
		RTRIM(LTRIM(\"1CODE\".\"VISIT-REASON-LDESC\")) +
		IFNULL(','+LTRIM(RTRIM(\"2CODE\".\"VISIT-REASON-LDESC\")),'') +
		IFNULL(','+LTRIM(RTRIM(\"3CODE\".\"VISIT-REASON-LDESC\")),'') +
		IFNULL(','+LTRIM(RTRIM(\"4CODE\".\"VISIT-REASON-LDESC\")),'') +
		IFNULL(','+LTRIM(RTRIM(\"5CODE\".\"VISIT-REASON-LDESC\")),'') +
		IFNULL(','+LTRIM(RTRIM(\"6CODE\".\"VISIT-REASON-LDESC\")),'')
	) AS \"REASONS\"
	FROM \"PUB\".\"HLT-OFFICE-VISIT-MST\"
	INNER JOIN PUB.\"HLT-OFFICE-VISIT-DTL\" \"1\" ON \"HLT-OFFICE-VISIT-MST\".\"OFFICE-VISIT-REF-NO\"=\"1\".\"OFFICE-VISIT-REF-NO\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-REASON\" \"1CODE\" ON \"1\".\"OFFICE-VISIT-DTL-ID\"=\"1CODE\".\"VISIT-REASON-ID\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-DTL\" \"2\" ON \"1\".\"OFFICE-VISIT-REF-NO\"=\"2\".\"OFFICE-VISIT-REF-NO\" AND \"1\".\"OFFICE-VISIT-DTL-TYPE\"=\"2\".\"OFFICE-VISIT-DTL-TYPE\" AND \"1\".\"OFFICE-VISIT-DTL-ID\"<>\"2\".\"OFFICE-VISIT-DTL-ID\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-REASON\" \"2CODE\" ON \"2\".\"OFFICE-VISIT-DTL-ID\"=\"2CODE\".\"VISIT-REASON-ID\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-DTL\" \"3\" ON \"2\".\"OFFICE-VISIT-REF-NO\"=\"3\".\"OFFICE-VISIT-REF-NO\" AND \"2\".\"OFFICE-VISIT-DTL-TYPE\"=\"3\".\"OFFICE-VISIT-DTL-TYPE\" AND \"1\".\"OFFICE-VISIT-DTL-ID\"<>\"3\".\"OFFICE-VISIT-DTL-ID\" AND \"2\".\"OFFICE-VISIT-DTL-ID\"<>\"3\".\"OFFICE-VISIT-DTL-ID\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-REASON\" \"3CODE\" ON \"3\".\"OFFICE-VISIT-DTL-ID\"=\"3CODE\".\"VISIT-REASON-ID\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-DTL\" \"4\" ON \"3\".\"OFFICE-VISIT-REF-NO\"=\"4\".\"OFFICE-VISIT-REF-NO\" AND \"3\".\"OFFICE-VISIT-DTL-TYPE\"=\"4\".\"OFFICE-VISIT-DTL-TYPE\" AND \"1\".\"OFFICE-VISIT-DTL-ID\"<>\"4\".\"OFFICE-VISIT-DTL-ID\" AND \"2\".\"OFFICE-VISIT-DTL-ID\"<>\"4\".\"OFFICE-VISIT-DTL-ID\" AND \"3\".\"OFFICE-VISIT-DTL-ID\"<>\"4\".\"OFFICE-VISIT-DTL-ID\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-REASON\" \"4CODE\" ON \"4\".\"OFFICE-VISIT-DTL-ID\"=\"4CODE\".\"VISIT-REASON-ID\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-DTL\" \"5\" ON \"4\".\"OFFICE-VISIT-REF-NO\"=\"5\".\"OFFICE-VISIT-REF-NO\" AND \"4\".\"OFFICE-VISIT-DTL-TYPE\"=\"5\".\"OFFICE-VISIT-DTL-TYPE\" AND \"1\".\"OFFICE-VISIT-DTL-ID\"<>\"5\".\"OFFICE-VISIT-DTL-ID\" AND \"2\".\"OFFICE-VISIT-DTL-ID\"<>\"5\".\"OFFICE-VISIT-DTL-ID\" AND \"3\".\"OFFICE-VISIT-DTL-ID\"<>\"5\".\"OFFICE-VISIT-DTL-ID\" AND \"4\".\"OFFICE-VISIT-DTL-ID\"<>\"5\".\"OFFICE-VISIT-DTL-ID\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-REASON\" \"5CODE\" ON \"5\".\"OFFICE-VISIT-DTL-ID\"=\"5CODE\".\"VISIT-REASON-ID\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-DTL\" \"6\" ON \"5\".\"OFFICE-VISIT-REF-NO\"=\"6\".\"OFFICE-VISIT-REF-NO\" AND \"5\".\"OFFICE-VISIT-DTL-TYPE\"=\"6\".\"OFFICE-VISIT-DTL-TYPE\" AND \"1\".\"OFFICE-VISIT-DTL-ID\"<>\"6\".\"OFFICE-VISIT-DTL-ID\" AND \"2\".\"OFFICE-VISIT-DTL-ID\"<>\"6\".\"OFFICE-VISIT-DTL-ID\" AND \"3\".\"OFFICE-VISIT-DTL-ID\"<>\"6\".\"OFFICE-VISIT-DTL-ID\" AND \"4\".\"OFFICE-VISIT-DTL-ID\"<>\"6\".\"OFFICE-VISIT-DTL-ID\" AND\"5\".\"OFFICE-VISIT-DTL-ID\"<>\"6\".\"OFFICE-VISIT-DTL-ID\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-REASON\" \"6CODE\" ON \"6\".\"OFFICE-VISIT-DTL-ID\"=\"6CODE\".\"VISIT-REASON-ID\"
	WHERE \"1\".\"OFFICE-VISIT-DTL-TYPE\"='V' 
	GROUP BY \"HLT-OFFICE-VISIT-MST\".\"STUDENT-ID\", \"HLT-OFFICE-VISIT-MST\".\"OFFICE-VISIT-REF-NO\", \"HLT-OFFICE-VISIT-MST\".\"REF-NO\", \"HLT-OFFICE-VISIT-MST\".\"HLT-OVM-TEMPERATURE\"
) AS \"STU_SYMPTOMS\" ON \"STU_SYMPTOMS\".\"STUDENT-ID\" = \"STUDENT_HEALTH\".\"STUDENT-ID\" AND \"STUDENT_HEALTH\".\"REF-NO\"=\"STU_SYMPTOMS\".\"REF-NO\" 
WHERE \"STUDENT_HEALTH\".\"HLT-DATE\" >= (CURDATE() - 7) AND \"STUDENT_HEALTH\".\"HLT-DATE\" <= CURDATE()";

// Disable the script time limit.
set_time_limit(0);

// log the beginning of the import
wlog("Starting symptom export.");

// Open the output file.
if (!$outfile = fopen($outputfile, "w+")) {
	echo "Failed to open output file!" . "\r\n";
	wlogDie("Failed to open output file!");
}

// Connect to the data source.
if (!$dbconnect = odbc_connect($dsn, $user, $pass)) {
	echo "Failed to connect to data source!" . "\r\n";
	wlogDie("Failed to connect to data source!");
}

 // Execute the query.
if (!$dbdata = odbc_exec($dbconnect, $query)) {
	echo "Failed to execute query!" . "\r\n";
	wlogdie("Failed to execute query!");
}

$count = 0;
while ($row = odbc_fetch_array($dbdata)) {
  $rowarray = array($row["cid"], $row["year"], $row["campusid"], $row["date"], $row["temp"], $row["grade"], $row["zip"], $row["gender"], $row["race"], $row["doctor"], $row["symptoms"]);

  // Write the line to the output file and increment the record count.
  writeLine($outfile,$rowarray);
  $count++;
}

// Close the ODBC connection and free the results from each query.
odbc_free_result($dbdata);
odbc_close($dbconnect);
odbc_close_all();

// Log the results.
if ($count == 0) {
	echo "No records found!" . "\r\n";
	wlogDie("No records found!");
} else {
	wlog("Processed $count records.");
	echo "Processed $count records." . "\r\n";
}

?>
