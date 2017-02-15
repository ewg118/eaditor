from lxml import etree as ET
import os

#get location of script
__location__ = os.path.dirname(os.path.abspath(__file__))

#set lxml parser
parser = ET.XMLParser(remove_blank_text=True)

#loop though __location__
for file in os.listdir(__location__):
	#limit to XML files only
	if file.endswith(".xml"):
		#set fill path to file
		filePath = os.path.join(__location__, file)
		
		#open file as string to check for XML declaration
		readFile = open(filePath, "r")
		fileString = readFile.read()
		if fileString.strip().lower().startswith("<?xml "):
			xmlDeclaration = True
		else:
			xmlDeclaration = False
		readFile.close()

		#open and parse as lxml root object, get doctype and encoding if any
		FA_input = ET.parse(filePath, parser)
		docType = FA_input.docinfo.doctype
		docEncoding = FA_input.docinfo.encoding
		FA = FA_input.getroot()
		
		#check for processing instructions and limit to only files with PI
		pis = FA.xpath("//processing-instruction()")
		if len(pis) > 0:
		
			#check for doctype
			if len(docType) > 0:
				FA_string = ET.tostring(FA, pretty_print=True, xml_declaration=xmlDeclaration, encoding=docEncoding, doctype=docType)
			else:
				FA_string = ET.tostring(FA, pretty_print=True, xml_declaration=xmlDeclaration, encoding=docEncoding)

			#write filr back to filesystem
			writeFile = open(filePath, "w")
			writeFile.write(FA_string)
			writeFile.close()