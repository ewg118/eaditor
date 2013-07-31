<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs ead" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template match="/">
		<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
		<xsl:apply-templates select="/ead:ead"/>		
	</xsl:template>
	
	<xsl:template match="ead:ead">
		<dsc id="{/ead:ead/@id}" title="{/ead:ead/ead:archdesc/ead:did/ead:unittitle}">
			<xsl:apply-templates select="//ead:dsc/ead:c"/>
		</dsc>
	</xsl:template>

	<xsl:template match="ead:c">
		<c unittitle="{ead:did/ead:unittitle}" id="{@id}" level="{@level}">
			<xsl:apply-templates select="ead:c"/>
		</c>
	</xsl:template>

</xsl:stylesheet>
