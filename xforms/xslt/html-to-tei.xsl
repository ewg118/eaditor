<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:saxon="http://saxon.sf.net/"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:template match="/body">
		<desc xmlns="http://www.tei-c.org/ns/1.0">
			<xsl:apply-templates/>
		</desc>
	</xsl:template>

	<xsl:template match="a">
		<ref target="{@href}" xmlns="http://www.tei-c.org/ns/1.0">
			<xsl:value-of select="normalize-space(.)"/>
		</ref>
	</xsl:template>

</xsl:stylesheet>
