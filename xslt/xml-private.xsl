<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber [gruber at numismatics dot org]
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	Modified: June 2011
	Function: Identity transform for the xml pipeline in EADitor.  Internal components are suppressed unless they have external
	descendants, in which case only the unittitles are displayed 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common"  xmlns:ead="urn:isbn:1-931666-22-9" version="2.0">
	<xsl:output encoding="utf-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>
	
	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>
	<!-- load config.xml from eXist into a variable which is later processed with exsl:node-set -->
	<xsl:variable name="config" select="document(concat($exist-url, 'eaditor/config.xml'))"/>

	<xsl:template match="/">
		<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
		<xsl:apply-templates select="document(concat($exist-url, 'eaditor/guides/', $id, '.xml'))/ead:ead"/>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
