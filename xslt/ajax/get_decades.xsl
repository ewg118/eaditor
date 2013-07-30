<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs eaditor exsl xs xi" version="2.0"
	xmlns:xi="http://www.w3.org/2001/XInclude" xmlns="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" xmlns:eaditor="http://code.google.com/p/eaditor/">
	<xsl:output method="xml" encoding="UTF-8"/>
	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>
	<!-- load config.xml from eXist into a variable which is later processed with exsl:node-set -->
	<xsl:variable name="config" select="document(concat($exist-url, 'eaditor/config.xml'))"/>
	<xsl:variable name="solr-url" select="concat(exsl:node-set($config)/config/solr_published, 'select/')"/>

	<!-- URL parameters -->
	<xsl:param name="q">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='q']/value"/>
	</xsl:param>
	<xsl:variable name="encoded_q" select="encode-for-uri($q)"/>
	<xsl:param name="century">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='century']/value"/>
	</xsl:param>

	<!-- Solr query URL -->
	<xsl:variable name="service">
		<xsl:value-of select="concat($solr-url, '?q=', $encoded_q, '&amp;start=0&amp;rows=0&amp;facet.field=decade_num&amp;facet.sort=index&amp;fq=century_num:', $century)"/>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>test</title>
			</head>
			<body>
				<ul>
					<xsl:apply-templates select="document($service)/response//lst[@name='decade_num']"/>
				</ul>
			</body>
		</html>		
	</xsl:template>

	<xsl:template match="lst[@name='decade_num']">
		<xsl:for-each select="int[$century = substring(@name, 1, 2)]">
			<li>
				<xsl:choose>
					<xsl:when test="contains($q, concat('decade_num:', @name))">
						<input type="checkbox" value="{@name}" checked="checked" class="decade_checkbox"/>
					</xsl:when>
					<xsl:otherwise>
						<input type="checkbox" value="{@name}" class="decade_checkbox"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="concat(if(@name = '0') then '00' else @name, 's')"/>
			</li>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
