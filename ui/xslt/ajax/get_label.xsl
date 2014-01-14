<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:template match="/">
		<xsl:text>{"label":"</xsl:text>
		<xsl:call-template name="get_label"/>
		<xsl:text>"}</xsl:text>
	</xsl:template>
	
	<xsl:template name="get_label">
		<xsl:choose>	
			<xsl:when test="count(descendant::skos:prefLabel) &gt; 0">
				<xsl:choose>
					<xsl:when test="string(descendant::skos:prefLabel[@xml:lang='en'])">
						<xsl:value-of select="descendant::skos:prefLabel[@xml:lang='en']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="descendant::skos:prefLabel[1]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="count(descendant::dcterms:title) &gt; 0">
				<xsl:choose>
					<xsl:when test="string(descendant::dcterms:title[@xml:lang='en'])">
						<xsl:value-of select="descendant::dcterms:title[@xml:lang='en']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="descendant::dcterms:title[1]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="response"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
