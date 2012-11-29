<?

$outputfile = "./attendence.csv";
$user = "";
$pass = "";
$dsn = "";
$districtid = "";
$logfilename = "./out.log";
include('include.php');

// Find the total enrollment
$enrollmentquery = "SELECT Curdate() AS 'date', '".$districtid."'+\"STUDENT_EW\".\"ENTITY-ID\" AS 'id', count( \"STUDENT_EW\".\"STUDENT-ID\") AS 'enrolled'
FROM   \"SKYWARD\".\"PUB\".\"STUDENT-EW\" \"STUDENT_EW\" 
WHERE  \"STUDENT_EW\".\"EW-DATE\"<=SYSDATE() AND (\"STUDENT_EW\".\"WITHDRAWAL-DATE\" IS  NULL  OR \"STUDENT_EW\".\"WITHDRAWAL-DATE\">SYSDATE())
GROUP BY \"STUDENT_EW\".\"ENTITY-ID\"";

// Find the daily absenses
$absencesubquery = "SELECT \"ATND_ABSENCE_TYPE\".\"AAT-ID\"
 FROM   \"SKYWARD\".\"PUB\".\"ATND-ABSENCE-TYPE\" \"ATND_ABSENCE_TYPE\"
 WHERE  
     \"ATND_ABSENCE_TYPE\".\"AAT-EXC-UNEXC-TAR-OTH\"<>'T' AND
     \"ATND_ABSENCE_TYPE\".\"ENTITY-ID\"=\"STUDENT_ATND_DETAIL\".\"ENTITY-ID\" AND
     \"ATND_ABSENCE_TYPE\".\"AAT-INCL-IN-TOT-ATND\"=1 and
     \"ATND_ABSENCE_TYPE\".\"SCHOOL-YEAR\"=\"STUDENT_ATND_DETAIL\".\"SCHOOL-YEAR\""

$absencequery = "SELECT \"STUDENT_ATND_DETAIL\".\"ATND-DATE\" AS 'date', '".$districtid."'+\"ENTITY\".\"ENTITY-ID\" AS 'id', \"ENTITY\".\"ENTITY-NAME\" AS 'name', count(\"STUDENT_ATND_DETAIL\".\"STUDENT-ID\") as 'absent'
FROM   \"SKYWARD\".\"PUB\".\"STUDENT-ATND-DETAIL\" \"STUDENT_ATND_DETAIL\"
INNER JOIN  \"SKYWARD\".\"PUB\".\"ENTITY\" ON \"STUDENT_ATND_DETAIL\".\"ENTITY-ID\" = \"ENTITY\".\"ENTITY-ID\" AND \"STUDENT_ATND_DETAIL\".\"SCHOOL-YEAR\" = \"ENTITY\".\"SCHOOL-YEAR\"
WHERE  \"STUDENT_ATND_DETAIL\".\"ATND-DATE\" = Curdate()
  AND  (
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[1] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[2] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[3] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[4] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[5] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[5] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[6] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[7] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[8] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[9] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[10] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[11] in (".$absencesubquery.") OR
	\"STUDENT_ATND_DETAIL\".\"AAT-ID\"[12] in (".$absencesubquery.")
       )
GROUP BY \"ENTITY\".\"ENTITY-ID\", \"ENTITY\".\"ENTITY-NAME\", \"STUDENT_ATND_DETAIL\".\"ATND-DATE\"";

// Disable the script time limit.
set_time_limit(0);

// log the beginning of the import
wlog("Starting attendence export.");

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

// Execute the enrollment query.
if (!$dbdata = odbc_exec($dbconnect, $enrollmentquery)) {
	echo "Failed to execute query!" . "\r\n";
	wlogdie("Failed to execute query!");
}
while ($row = odbc_fetch_array($dbdata)){
	$result[$districtid.$row["id"]] = array(
		"date" => $row["date"],
		"id" => $row['id'],
		"enrolled" => $row["enrolled"]
	);
}
odbc_free_result($dbdata);

// Execute the attendance query.
if (!$dbdata = odbc_exec($dbconnect, $attendancequery)) {
	echo "Failed to execute query!" . "\r\n";
	wlogdie("Failed to execute query!");
}
while ($row = odbc_fetch_array($dbdata)){
	$result[$row["id"]]["absent"] = $row["absent"];
	$result[$row["id"]]["name"] = $row["name"];
}
odbc_free_result($dbdata);


// Close the ODBC connection
odbc_close($dbconnect);
odbc_close_all();

// Write the csv out to file

$count = 0;
foreach ( $result as $value ){
	$rowarray = array($value["date"], $value["id"], $value["name"], $value["enrolled"], $value["absent"]);

	// Write the line to the output file and increment the record count.
	writeLine($outfile,$rowarray);
	$count++;
}

// Log the results.
if ($count == 0) {
	echo "No records found!" . "\r\n";
	wlogDie("No records found!");
} else {
	wlog("Processed $count records.");
	echo "Processed $count records." . "\r\n";
}

?>
