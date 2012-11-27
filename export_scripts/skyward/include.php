<?php
/*****************************************/

$logfp = fopen($logfilename,"a");
if (!$logfp) {
	exit(-1);
}

/**
 * Writes "$str" to global "$logfp" log file and kills script
 *
 * @param string "$str"
 */
function wlogDie ($str) {
	global $logfp;

	wlog($str);
	fclose($logfp);
	die(-1);
}
/**
 * Writes "$str" to global "$logfp" log file
 *
 * @param string "$str"
 */
function wlog ($str) {
	global $logfp;
	fwrite($logfp, date("Y-m-d h:i:s") . " - $str\r\n");
}

/**
 * Writes array "$row" as a comma-delimited, double-quoted text string to output file "$stufile"
 *
 * @param output file "$stufile"
 * @param array "$row"
 */
function writeLine ($stufile, $row) {
	$sisline = '"' . implode('","',$row) . '"' . "\r\n";
	if (!fwrite($stufile,$sisline)) {
		fclose($stufile);
		wlogDie("failed to write student line to import file: $sisline");
	}
}

/**
 * Takes objects in array "$row" and returns a formatted string "$line" Example:
 * $row = array(1,2,3); $x=andList($row);
 * Result: $x = "1, 2, and 3"
 * @param array "$row"
 * @return string "$line"
 */
function andList ($row) {
	$line = NULL;
	for ($x = 0; $x < count($row); $x++) {
		if ($line === NULL) {
			$line = $row[$x];
		} else if ( $x == (count($row) -1) ) {
			$line .= ", and " . $row[$x];
		} else {
			$line .= ", " . $row[$x];
		}
	}
	return $line;
}


/* Example:
$string = "12345Bob    Smith    5551212";
$lengths = array(5,10,10,7)
$vals = fixedlenread($string, $lengths, true); (FINAL "$trim_char" PARAMETER IS OPTIONAL!)
echo $vals[0] . "\n"; //returns 12345
echo $vals[1] . "\n"; //returns Bob
echo $vals[2] . "\n"; //returns Smith
echo $vals[3] . "\n"; //returns 5551212
*/

/**
 * Read a string into an array based on field widths specified in an array,
 * Optional "$trim" will trim spaces from the values, (set to false by default)
 * Returns an array of the values
 *
 * @param string "$string"
 * @param array "$lengths"
 * @param boolean "$trim"
 * @return array "$row"
 */
function fixedlenread($string, $lengths, $trim=false) {
	$number = count($lengths);
	$row = array();
	if ($number > 0) {
		$start = 0;
		foreach ($lengths as $curlen) {
			if($trim){
				$row[] = trim(substr($string, $start, $curlen));
			}else{
				$row[] = substr($string, $start, $curlen);
			}
			$start = $start + $curlen;
		}
		return $row;
	} else {
		return false;
	}
}


/* Example:
$filenames = array("/tmp/tempfile1.txt", "/tmp/tempfile2.txt");
$usablefiles = readablefiles($filenames);
foreach ($usablefiles as $file => $size)
	echo "$file size did not change and size is $size\n";
*/

/**
 * readablefiles($filearray array of files, $checkdur optional, durration of sleep between checks)
 * Check an array of files to see if any are being written to currently,
 * Returns array of files that were not modified over some period
 *
 * @param array "$filenames"
 * @param int "$checkdur"
 * @return array "$returnfiles"
 */
function readablefiles($filenames, $checkdur=10) {
	$openfiles = array();
	$returnfiles = array();
	$checkfiles = array();
	foreach ($filenames as $file) {
		if (file_exists($file)) {
			$openfiles[$file] = filesize($file);
		}
	}
	if (count($openfiles) !== 0) {
		sleep($checkdur + 0);
		clearstatcache();
		$checkfiles = array();
		foreach ($openfiles as $file => $size) {
			if (file_exists($file)) {
				$checksize = filesize($file);
				if ($checksize == $size)
					$returnfiles[$file] = $checksize;
				else
					$checkfiles[$file] = $checksize;
			}
		}
		$openfiles = $checkfiles;
	}
	return $returnfiles;
}


/**
 * searches an array for duplicate items and replaces any duplicates with blanks without removing
  that item place from the array
  Example:  $newArray = array_dup_rep($arrayToSearch);
 *
 * @param array "$inArray"
 * @return array "$inArray"
 */
function array_dup_rep($inArray){

	$arraySize=count($inArray);
	$sub1=0;

	while($sub1<$arraySize-1){
		for($sub2=($sub1+1);$sub2<$arraySize;$sub2++){
			if($inArray[$sub1]==$inArray[$sub2]){
				$inArray[$sub2]="";
			}
		}
		$sub1++;
	}
	return $inArray;
}


/**
 * searches array and compares positions "$positions",
 * If any duplicate items are found, replaces duplicates with blanks,
 * without removing that item place from the array
 *
 * @param array "$inArray"
 * @param array "$positions"
 * @return array "$inArray"
 */
function subset_dup_rep($inArray, $positions){

	foreach ($positions as $pos1){
		foreach($positions as $pos2){
			if($pos1!==$pos2 and $inArray[$pos1]==$inArray[$pos2]){
				$inArray[$pos2]="";
			}
		}
	}
	return $inArray;
}


/**
 * Accepts any currency format and returns re-formatted string , If given a variable containing characters other that 0-9, "$", and "-", it will echo an error message and return the original variable
 * ("$-0.45" returns "$.45") ("$0.45"  returns "$.45") (".45"    returns "$.45") ("$45"	returns "$45.00")
 *
 * @param string "$balance"
 * @return string
 */
function format_balance ($balance) {
	$original_balance = $balance;
	$balance = str_replace("$","",$balance);
    $balance = str_replace("-","",$balance);
	if(!is_numeric($balance)){
		echo "Unable to format non-numeric variable!"."\r\n";
		return $original_balance;
	}

    $balance = number_format($balance,2);
    $tmpBal = explode(".",$balance);
    if ($tmpBal[0] == 0) {
                $finalBalance = "$." . $tmpBal[1];
    } else {
                $finalBalance = "$" . $tmpBal[0] . "." . $tmpBal[1];
    }

    return $finalBalance;
}


//Example:
//					$balance = $2.45;
//					$balType=($balance,3.00);
//Returns: "Low"
//
//WHEN USED WITH THE "format_balance" FUNCTION
//"balance_type" MUST BE USED FIRST!!!


/* Examples:

$balanceType = balance_type($row[4]);
No thresholds defined.
Returns "Positive" for values greater than zero. Returns "Zero" for values equal to zero. Returns "Negative"for values less than zero.

$balanceType = balance_type($row[4],3);
Low threshold defined. Negative threshold undefined.
Returns "Acceptable" for values greater than the low threshold. Returns "Low" for values less than low threshold and greater than zero.
Returns "Zero" for values equal to zero. Returns "Negative" for values less than zero.

$balanceType = balance_type($row[4],3,-2);
Low and negative thresholds defined.
Returns "Acceptable" for values greater than the low threshold. Returns "Low" for values less than low threshold and greater than zero.
Returns "Zero" for values equal to zero. Returns "Negative: Non-Critical" for values less than zero and greater than the negative threshold.
Returns "Negative: Critical" for values less than the negative threshold.

$balanceType = balance_type($row[4],null,-2);
Low threshold defined as null (required). Negative threshold defined.
Returns "Positive" for values greater than zero. Returns "Zero" for values equal to zero. Returns "Negative: Non-Critical" for
values less than zero and greater than the negative threshold. Returns "Negative: Critical" for values less than the negative threshold.

*/

/**
 * Evaluates $balance and returns corresponding balance type (e.g. "Acceptable","Low","Zero","Negative") for numeric values only
Second parameter $low stores the low balance threshold
Third parameter $negative stores the negative balance threshold
Both $low and $negative parameters are inclusive.

 *
 * @param string "$balance"
 * @param int "$low"
 * @param int "$negative"
 * @return string "$type"
 */

function balance_type($balance,$low = null,$negative = null) {
		$balance = str_replace("$","",$balance);
		if ($balance == "") {
			return "";
		} else if (!is_numeric($balance)) {
			return "Unknown";
		} else {
			if (!isset($low) && !isset($negative)) {
				if ($balance > 0) {
					return "Positive";
				} else if (($balance + 0) == 0) {
					return "Zero";
				} else if ($balance < 0) {
					return "Negative";
				}
			} else if (isset($low) && isset($negative)) {
				if ($balance >= $low) {
					return "Acceptable";
				} else if (($balance < $low) && ($balance > 0)) {
					return "Low";
				} else if (($balance + 0) == 0) {
					return "Zero";
				} else if (($balance < 0) && ($balance > $negative)) {
					return "Negative: Don't Call";
				} else if ($balance <= $negative) {
					return "Negative: Call";
				}
			} else if (isset($low) && (!isset($negative))) {
				if ($balance >= $low) {
					return "Acceptable";
				} else if (($balance < $low) && ($balance > 0)) {
					return "Low";
				} else if (($balance + 0) == 0) {
					return "Zero";
				} else if ($balance < 0) {
					return "Negative";
				}
			} else if (!isset($low) && isset($negative)) {
				if ($balance > 0) {
					return "Positive";
				} else if (($balance + 0) == 0) {
					return "Zero";
				} else if (($balance < 0) && ($balance > $negative)) {
					return "Negative: Don't Call";
				} else if ($balance <= $negative) {
					return "Negative: Call";
				}
			}

		}
}


/**
 * Opens $infile for $action ("w","r", etc), returns file resource handle, Logs error on failure
 * Optional parameter $date_check used to check to see if the file was
 * modified/created today, If not, log failure and return false (Turned off by default)
 *
 * @param $infile file
 * @param $action string
 * @param $date_check boolean[optional]
 * @return resource
 */
function fopen_log($infile, $action, $date_check= false){
	//open the file or quit if we can't
	if(!$outfile = fopen($infile, $action)) {
		echo "Failed to open $infile!"."\r\n";
		wlog("Failed to open $infile!");
		return false;
	}
	if($action=="w"){$action="for writing";}
	elseif($action=="r"){$action="for reading";}
	elseif($action==("w+" or "r+")){
		$action="for reading and writing";}
	else{$action="";}
	if($date_check){
		//get input file last mod date and today's date
		$filedate = filemtime($infile);
		$filedate = date('m/d/Y',$filedate);
		$today = date('m/d/Y');
		//if the dates don't match, abort the script
		if($filedate!==$today){
			echo "Attempting to read old file - Operation aborted"."\r\n";
			wlog("Attempting to read old file - Operation aborted");
			return false;
		}
	}

	echo "Opened $infile $action"."\r\n";

	return $outfile;
}


/**
 * Creates connection to the DSN "$dsn" using username "$user" and password "$pass
Load and executes "$query" and returns database resource
Logs all failures
 *
 * @param DSN string
 * @param user string
 * @param password string
 * @param query string
 * @return resource
 */
function connect_run_log($dsn, $user, $pass, $query){
	//connect to the DSN
	if (!$dbconnect = odbc_connect($dsn, $user, $pass)) {
		echo "Failed to connect to the DSN - $dsn!"."\r\n";
		wlog("Failed to connect to the DSN - $dsn!");
		return false;
	}

	echo "Connected to the DSN - $dsn"."\r\n";

	//load and execute the query against the DSN
	if (!$dbdata = odbc_exec($dbconnect, $query)) {
		echo "Failed to execute the query!"."\r\n";
		wlog("Failed to execute the query!");
		return false;
	}

	echo "Executed query successfully"."\r\n";

	return $dbdata;
}


/**
 * Counts "$count" and logs/echos total number, Logs failure if $count = 0
 * Optional second parameter "$type" (Example: "Student")
 * will include count type in logs/echo
 *
 * @param string $count
 * @param string $type
 */
function count_log($count, $type=""){
	if(!$count == 0) {
		echo "Processed $count $type records"."\r\n";
		wlog("Processed $count $type records");
	}else{
		echo "Failed to process any $type records!"."\r\n";
		wlogdie("Failed to process any $type records!");
	}
}


/**
 * User defined function to be used with the "array_walk" funtion,
 * Will trim all items in an array
 * Example: array_walk($array_to_be_trimmed, 'user_trim')
 *
 * @param mixed $value
 */
function user_trim(&$value){
	$value=trim($value);
}
/*****************************************/
?>