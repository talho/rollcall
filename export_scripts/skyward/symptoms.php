<?

$outputfile = "./symptoms.csv";
$user = "";
$pass = "";
$dsn = "";
$districtid = "";
$logfilename = "./out.log";
include('include.php');

// Store the query in variable $query.
$query = "SELECT HltOfficeVisitMst.[OFFICE-VISIT-REF-NO] as cid, StudentHealth.[school-year] as year, HltOfficeVisitMst.[HLT-OVM-ENTITY-ID] as campusid, 
	  StudentHealth.[HLT-DATE] as date, HltOfficeVisitMst.[HLT-OVM-TEMPERATURE] as temp, 12 + Entity.[SCHOOL-YEAR] - Student.[GRAD-YR] as grade, 
	  Address.[ZIP-CODE] as zip
FROM   StudentHealth 
JOIN   HltOfficeVisitMst ON StudentHealth.[REF-NO] = HltOfficeVisitMst.[REF-NO] AND StudentHealth.[STUDENT-ID] = HltOfficeVisitMst.[STUDENT-ID] 
JOIN   HltOfficeVisitDtl ON HltOfficeVisitMst.[OFFICE-VISIT-REF-NO] = HltOfficeVisitDtl.[OFFICE-VISIT-REF-NO]
JOIN   Student ON StudentHealth.[STUDENT-ID] = Student.[STUDENT-ID]
JOIN   Entity ON HltOfficeVisitMst.[HLT-OVM-ENTITY-ID] = Entity.[ENTITY-ID]
JOIN Name ON Student.[NAME-ID] = Name.[NAME-ID] 
JOIN Address ON Name.[ADDRESS-ID] = Address.[ADDRESS-ID]
WHERE  (StudentHealth.[SYS-HLT-TYPE-ID] = 'HOV') AND (HltOfficeVisitDtl.[OFFICE-VISIT-DTL-TYPE] = 'V') AND
         (HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'SA' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'NAU' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'THR' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'ILI' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'HA' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'CO' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'CHI' OR
          HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = 'FEV')
  AND  StudentHealth.[HLT-DATE] > DATEADD(dd,DATEDIFF(dd,0,GETDATE()),-7) AND StudentHealth.[HLT-DATE] <= GETDATE()
GROUP BY HltOfficeVisitMst.[OFFICE-VISIT-REF-NO], StudentHealth.[school-year];";

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

$result = array();
while ($row = odbc_fetch_array($dbdata)) {
  $result[$row["cid"]] = array("cid" => $row["cid"], "year" => $row["year"], "teaid" => $districtid.$row["campusid"],
			 	"date" => $row["date"], "temp" => $row["temp"], "grade" => $row["grade"], "zip" => $row["zip"]);
}

// Close the ODBC connection and free the results from each query.
odbc_free_result($dbdata);

$count = 0;
foreach($result as $visit){
  $symptoms_query = "SELECT ', ' + HltOfficeVisitReason.[VISIT-REASON-SDESC]
			    FROM  HltOfficeVisitDtl 
			    INNER JOIN HltOfficeVisitReason ON HltOfficeVisitDtl.[OFFICE-VISIT-DTL-ID] = HltOfficeVisitReason.[VISIT-REASON-ID]
			    WHERE HltOfficeVisitDtl.[OFFICE-VISIT-REF-NO] = '".$row["cid"]."' AND HltOfficeVisitDtl.[OFFICE-VISIT-DTL-TYPE] = 'V'";

  $dbdata = odbc_exec($dbconnect, $symptoms_query);
  $symptoms = array();
  while ($row = odbc_fetch_array($dbdata)){
    $symptoms[] = $row["symptom"];
  }
  odbc_free_result($dbdata);

  $rowarray = array($visit["cid"], $visit["year"], $visit["teaid"], $visit["date"], $visit["temp"], $visit["grade"], $visit["zip"], implode(",", $symptoms));

  // Write the line to the output file and increment the record count.
  writeLine($outfile,$rowarray);
  $count++;
}

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
