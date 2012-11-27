<?

$outputfile = "./attendence.csv";
$user = "";
$pass = "";
$dsn = "";
$districtid = "";
$logfilename = "./out.log";
include('include.php');

// Find the total enrollment
$enrollmentquery = "SELECT EntityStdCnts.[ENTITY-ID] as id, GETDATE() as date, Entity.[ENTITY-NAME] as name, EntityStdCnts.[CURR-NON-DUP-CNT] as enrolled
FROM   Entity 
INNER JOIN EntityStdCnts ON Entity.[ENTITY-ID] = EntityStdCnts.[ENTITY-ID]
WHERE  EntityStdCnts.[entity-id] NOT IN (-1) 
  AND EntityStdCnts.[grad-year] = 9999
  AND  EntityStdCnts.[school-year] = Entity.[SCHOOL-YEAR];";
// Find the daily absenses
$absencequery = "select EnrollmentCounts.[Absent] as absent
FROM   Entity 
INNER JOIN EnrollmentCounts ON Entity.[ENTITY-ID] = EnrollmentCounts.CampusID
WHERE  EntityStdCnts.[entity-id] NOT IN (select entityid from @excluded_campuses)
  AND  Entity.[ENTITY-ID] = id;";

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
		"id" => "$districtid".$row['id'],
		"name" => $row["name"],
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
	$result[$districtid.$row["ENTITY-ID"]]["absent"] = $row["absent"];
}
odbc_free_result($dbdata);


// Close the ODBC connection
//odbc_close($dbconnect);
//odbc_close_all();

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
