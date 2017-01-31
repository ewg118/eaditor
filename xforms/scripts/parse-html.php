<?php 

/**************
 * AUTHOR: Ethan Gruber
* DATE: June 2016
* FUNCTION: This script parses the generic HTML page for directory listings in order to gather a list of EAD XML files for harvesting
* The screen scraper will generate an XML response that feeds back into the Orbeon XForms engine
* REQUIRED LIBRARIES: php5, php5-curl, php5-cgi
**************/
//set output header
header('Content-Type: application/xml');

$url = 'http://rmc.library.cornell.edu/EAD/xml/dlxs/';

//develop XML serialization
$writer = new XMLWriter();
//$writer->openURI('php://output');
$writer->openURI('file.xml');
$writer->startDocument('1.0','UTF-8');
$writer->setIndent(true);
$writer->setIndentString("    ");

//initiate curl
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$html = curl_exec($ch);

if(curl_exec($ch) !== FALSE) {
	process_html($url, $html, $writer);
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
	//add trailing slash if not present
	if (substr($url, -1) != '/'){
		$url .= '/';
	}
	
	$dom = new DOMDocument();
	@$dom->loadHTML($html);
	$xpath = new DOMXpath($dom);
	//iterate through each link
	foreach($dom->getElementsByTagName('a') as $link) {
		$href = $link->getAttribute('href');
		//only include links to XML files
		if (strpos($href, '.xml') !== FALSE){
			$pieces = explode('/', $href);
			$fileName = end($pieces);
			$file = $url . $fileName;
			
			//attempt to get the date
			$date = '';
			/*if ($link->parentNode->nodeName == 'td'){
				$tr = $xpath->query("//tr[descendant::a[@href='{$href}']]")->item(0);				
				foreach ($tr->getElementsByTagName('td') as $td){
					if (is_string($td->nodeValue)){
						$dateArray = date_parse($td->nodeValue);
						
						if (is_int($dateArray['year']) && is_int($dateArray['month']) && is_int($dateArray['day'])){
							$date = date(DATE_ATOM, mktime(0, 0, 0, $dateArray['month'], $dateArray['day'], $dateArray['year']));
						}
					}
				}
			}*/
			
			$writer->startElement('file');
				$writer->writeElement('url', $file);
				$writer->writeElement('date', $date);
			$writer->endElement();
		}
	}
}


?>