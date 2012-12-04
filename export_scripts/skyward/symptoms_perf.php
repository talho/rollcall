<?

$outputfile = "./symptoms.csv";
$user = "SKYDBUSER";
$pass = "stuL0b0db";
$dsn = "Skyward Student";
$districtid = "092903";
$logfilename = "./out.log";
include('include.php');

$query = "SELECT \"STU_SYMPTOMS\".\"OFFICE-VISIT-REF-NO\" AS 'cid', \"STUDENT_HEALTH\".\"SCHOOL-YEAR\" AS 'year', '".$districtid."'+\"STUDENT_HEALTH\".\"SCHOOL-ID\" AS 'campusid', 
       \"SCHOOL1\".\"SCHOOL-NAME\" AS 'school_name', \"STUDENT_HEALTH\".\"HLT-DATE\" AS 'date', \"STU_SYMPTOMS\".\"HLT-OVM-TEMPERATURE\" AS 'temp', 
       \"ZIP1\".\"ZIP-CODE\" AS 'zip', (\"STUDENT_HEALTH\".\"SCHOOL-YEAR\"-\"STUDENT1\".\"GRAD-YR\"+12) AS 'grade', 
       \"NAME_stu\".\"GENDER\" AS 'gender', \"NAME_stu\".\"RACE-CODE\" AS 'race', (\"NAME_dr\".\"FIRST-NAME\" +  ' ' + \"NAME_dr\".\"LAST-NAME\") AS 'doctor'
FROM   \"SKYWARD\".\"PUB\".\"STUDENT-HEALTH\" \"STUDENT_HEALTH\"
INNER JOIN  \"SKYWARD\".\"PUB\".\"ENTITY\" ON \"STUDENT_HEALTH\".\"SCHOOL-YEAR\" = \"ENTITY\".\"SCHOOL-YEAR\" AND \"ENTITY\".\"ENTITY-ID\" = '000'
INNER JOIN \"SKYWARD\".\"PUB\".\"STUDENT\" \"STUDENT1\" ON \"STUDENT_HEALTH\".\"STUDENT-ID\"=\"STUDENT1\".\"STUDENT-ID\" 
INNER JOIN \"SKYWARD\".\"PUB\".\"NAME\" \"NAME_stu\" ON \"STUDENT1\".\"NAME-ID\"=\"NAME_stu\".\"NAME-ID\"
LEFT OUTER JOIN \"SKYWARD\".\"PUB\".\"SCHOOL\" \"SCHOOL1\" ON \"STUDENT_HEALTH\".\"SCHOOL-ID\"=\"SCHOOL1\".\"SCHOOL-ID\"
LEFT OUTER JOIN \"SKYWARD\".\"PUB\".\"NAME\" \"NAME_dr\" ON \"STUDENT1\".\"PRIMARY-PHYSICIAN\"=\"NAME_dr\".\"NAME-ID\"
LEFT OUTER JOIN \"SKYWARD\".\"PUB\".\"ADDRESS\" \"ADDRESS1\" ON \"NAME_stu\".\"ADDRESS-ID\"=\"ADDRESS1\".\"ADDRESS-ID\"
LEFT OUTER JOIN \"SKYWARD\".\"PUB\".\"ZIP\" \"ZIP1\" ON \"ADDRESS1\".\"ZIP-CODE\"=\"ZIP1\".\"ZIP-CODE\"
INNER JOIN \"PUB\".\"HLT-OFFICE-VISIT-MST\" AS \"STU_SYMPTOMS\" ON \"STU_SYMPTOMS\".\"STUDENT-ID\" = \"STUDENT_HEALTH\".\"STUDENT-ID\" AND \"STUDENT_HEALTH\".\"REF-NO\"=\"STU_SYMPTOMS\".\"REF-NO\" 
WHERE \"STUDENT_HEALTH\".\"HLT-DATE\" >= (CURDATE() - 7) AND \"STUDENT_HEALTH\".\"HLT-DATE\" <= CURDATE()";

$query2 = "SELECT \"HLT-OFFICE-VISIT-MST\".\"OFFICE-VISIT-REF-NO\" AS \"cid\",
	LTRIM(RTRIM(\"CODE\".\"VISIT-REASON-LDESC\")) AS \"reason\"
	FROM \"PUB\".\"HLT-OFFICE-VISIT-MST\"
	INNER JOIN \"SKYWARD\".\"PUB\".\"STUDENT-HEALTH\" \"STUDENT_HEALTH\" ON \"HLT-OFFICE-VISIT-MST\".\"STUDENT-ID\" = \"STUDENT_HEALTH\".\"STUDENT-ID\" AND \"STUDENT_HEALTH\".\"REF-NO\"=\"HLT-OFFICE-VISIT-MST\".\"REF-NO\"
	INNER JOIN PUB.\"HLT-OFFICE-VISIT-DTL\" \"DTL\" ON \"HLT-OFFICE-VISIT-MST\".\"OFFICE-VISIT-REF-NO\"=\"DTL\".\"OFFICE-VISIT-REF-NO\"
	LEFT OUTER JOIN PUB.\"HLT-OFFICE-VISIT-REASON\" \"CODE\" ON \"DTL\".\"OFFICE-VISIT-DTL-ID\"=\"CODE\".\"VISIT-REASON-ID\"
	WHERE \"DTL\".\"OFFICE-VISIT-DTL-TYPE\"='V' 
	  AND \"CODE\".\"VISIT-REASON-LDESC\" != ''
	  AND \"STUDENT_HEALTH\".\"HLT-DATE\" >= (CURDATE() - 7) 
	  AND \"STUDENT_HEALTH\".\"HLT-DATE\" <= CURDATE()";

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
	echo odbc_errormsg($dbconnect)."\r\n";
	wlog("Failed to connect to data source!");
	wlogdie(odbc_errormsg($dbconnect));
}

 // Execute the query.
if (!$dbdata = odbc_exec($dbconnect, $query)) {
	echo "Failed to execute query!" . "\r\n";
	echo odbc_errormsg($dbconnect)."\r\n";
	wlog("Failed to execute query!");
	wlogdie(odbc_errormsg($dbconnect));
}

$result = [];
$count = 0;

while ($row = odbc_fetch_array($dbdata)) {
  $result[$row["cid"]] = array("cid" => $row["cid"], "year" => $row["year"], "campusid" => $row["campusid"], 
                               "date" => $row["date"], "temp" => $row["temp"], "grade" => $row["grade"], 
                               "zip" => $row["zip"], "gender" => $row["gender"], "race" => $row["race"], 
			       "doctor" => $row["doctor"], "symptoms" => []);
}

odbc_free_result($dbdata);

 // Execute the query.
if (!$dbdata = odbc_exec($dbconnect, $query2)) {
	echo "Failed to execute reason query!" . "\r\n";
	echo odbc_errormsg($dbconnect)."\r\n";
	wlog("Failed to execute reason query!");
	wlogdie(odbc_errormsg($dbconnect));
}

while($row = odbc_fetch_array($dbdata)){
  if($result[$row["cid"]]){
    array_push($result[$row["cid"]]["symptoms"], $row["reason"]);
  }
}

odbc_free_result($dbdata);

foreach($result as $row){
  $rowarray = array($row["cid"], $row["year"], $row["campusid"], $row["date"], $row["temp"], $row["grade"], $row["zip"], $row["gender"], $row["race"], $row["doctor"], implode(',', $row["symptoms"]));

  // Write the line to the output file and increment the record count.
  writeLine($outfile,$rowarray);
  $count++;
}

// Close the ODBC connection and free the results from each query.
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
