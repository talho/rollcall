<?

$outputfile = "./attendance.csv";
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

// Find which attendance details are tardies
$tardinessquery = "SELECT DISTINCT \"ATND_ABSENCE_TYPE\".\"AAT-ID\" as \"id\"
 FROM  \"SKYWARD\".\"PUB\".\"ATND-ABSENCE-TYPE\" \"ATND_ABSENCE_TYPE\"
 WHERE \"ATND_ABSENCE_TYPE\".\"AAT-EXC-UNEXC-TAR-OTH\" = 'T' 
    OR \"ATND_ABSENCE_TYPE\".\"AAT-INCL-IN-TOT-ATND\" != 1";

$tardie_arr = array("''");
// Build the tardiness list.
if (!$dbdata = odbc_exec($dbconnect, $tardinessquery)) {
	echo "Failed to execute query!" . "\r\n";
	wlogdie("Failed to execute query!");
}
while ($row = odbc_fetch_array($dbdata)){
	array_push($tardie_arr, "'".$row["id"]."'");
}
odbc_free_result($dbdata);
$tardies = implode(',',$tardie_arr);

// Find the daily absenses
$absencequery = "SELECT \"STUDENT_ATND_DETAIL\".\"ATND-DATE\" AS 'date', '".$districtid."'+\"STUDENT_ATND_DETAIL\".\"ENTITY-ID\" AS 'id', count(\"STUDENT_ATND_DETAIL\".\"STUDENT-ID\") as 'absent'
FROM   \"SKYWARD\".\"PUB\".\"STUDENT-ATND-DETAIL\" \"STUDENT_ATND_DETAIL\"
WHERE  \"STUDENT_ATND_DETAIL\".\"ATND-DATE\" = Curdate()
  AND  (
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[1] NOT IN (".$tardies.") OR
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[2] NOT IN (".$tardies.") OR
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[3] NOT IN (".$tardies.") OR
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[4] NOT IN (".$tardies.") OR
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[5] NOT IN (".$tardies.") OR
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[6] NOT IN (".$tardies.") OR
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[7] NOT IN (".$tardies.") OR
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[8] NOT IN (".$tardies.") OR
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[9] NOT IN (".$tardies.") OR
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[10] NOT IN (".$tardies.") OR
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[11] NOT IN (".$tardies.") OR
    \"STUDENT_ATND_DETAIL\".\"AAT-ID\"[12] NOT IN (".$tardies.")
       )
GROUP BY \"STUDENT_ATND_DETAIL\".\"ENTITY-ID\", \"STUDENT_ATND_DETAIL\".\"ATND-DATE\"";

// Execute the enrollment query.
if (!$dbdata = odbc_exec($dbconnect, $enrollmentquery)) {
	echo "Failed to execute query!" . "\r\n";
	wlogdie("Failed to execute query!");
}
while ($row = odbc_fetch_array($dbdata)){
	$result[$row["id"]] = array(
		"date" => $row["date"],
		"id" => $row['id'],
		"enrolled" => $row["enrolled"]
	);
}
odbc_free_result($dbdata);

// Execute the attendance query.
if (!$dbdata = odbc_exec($dbconnect, $absencequery)) {
	echo "Failed to execute query!" . "\r\n";
	wlogdie("Failed to execute query!");
}
while ($row = odbc_fetch_array($dbdata)){
	$result[$row["id"]]["absent"] = $row["absent"];
}
odbc_free_result($dbdata);


// Close the ODBC connection
odbc_close($dbconnect);
odbc_close_all();

// Write the csv out to file

$count = 0;
foreach ( $result as $value ){
	$rowarray = array($value["date"], $value["id"], $value["enrolled"], $value["absent"]);

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
