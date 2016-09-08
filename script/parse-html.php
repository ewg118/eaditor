<?php 

/**************
 * AUTHOR: Ethan Gruber
* DATE: June 2016
* FUNCTION: This script parses the generic HTML page for directory listings in order to gather a list of EAD XML files for harvesting
* The screen scraper will generate an XML response that feeds back into the Orbeon XForms engine
* REQUIRED LIBRARIES: php5, php5-curl, php5-cgi
* On Ubuntu systems, create a symlink to this PHP file in /usr/lib/cgi-bin and enable CGI processing in the Apache config
**************/
//set output header
header('Content-Type: application/xml');

//$url = 'http://rmc.library.cornell.edu/EAD/xml/dlxs/';

//get URL from request parameter
$url = $_GET['url'];

//develop XML serialization
$writer = new XMLWriter();
$writer->openURI('php://output');
//$writer->openURI('file.xml');
$writer->startDocument('1.0','UTF-8');
$writer->setIndent(true);
$writer->setIndentString("    ");

//initiate curl
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$html = curl_exec($ch);

if(curl_exec($ch) !== FALSE) {
	$writer->startElement('files');
	process_html($url, $html, $writer);
	$writer->endElement();
}
else {
	$writer->startElement('response');
		$writer->writeElement('error', 'Unable to parse provided URL');
	$writer->endElement();
}

curl_close($ch);

//end writer process
$writer->endDocument();
$writer->flush();

function process_html($url, $html, $writer) {
	$from = $_GET['from'];
	
	//add trailing slash if not present
	if (substr($url, -1) != '/'){
		$url .= '/';
	}
	
	$dom = new DOMDocument();
	@$dom->loadHTML($html);
	$xpath = new DOMXpath($dom);
	$tr = $xpath->query("//tr[descendant::a]");
	
	//the parsing has been built around the Cornell directory listing (probably Apache)
	foreach ($tr as $row){
		$href = $row->getElementsByTagName('a')->item(0)->getAttribute('href');
		$date = '';
		
		//get URL
		if (strpos($href, '.xml') !== FALSE){
			$pieces = explode('/', $href);
			$fileName = end($pieces);
			$file = $url . $fileName;	
			//then iterate through the table cells looking for strings that resemble dates
			foreach ($row->getElementsByTagName('td') as $td){
				if (is_string($td->nodeValue)){
					$dateArray = date_parse($td->nodeValue);
						
					if (is_int($dateArray['year']) && is_int($dateArray['month']) && is_int($dateArray['day'])){
						$date = date('Y-m-d', mktime(0, 0, 0, $dateArray['month'], $dateArray['day'], $dateArray['year']));
					}
				}
			}
			
			//if there is a from date, then only include those files that are on or after this date
			if (strlen($from) > 0){
				if (strtotime($from) <= strtotime($date)){
					$writer->startElement('file');
						$writer->writeElement('url', $file);
						$writer->writeElement('date', $date);
					$writer->endElement();
				}
			} else {
				$writer->startElement('file');
					$writer->writeElement('url', $file);
					$writer->writeElement('date', $date);
				$writer->endElement();
			}
			
		}	
	}
}

?>