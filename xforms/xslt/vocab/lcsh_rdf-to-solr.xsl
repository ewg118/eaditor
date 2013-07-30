<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#">
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="//rdf:Description"/>
		</add>
	</xsl:template>

	<xsl:template match="rdf:Description">
		<doc>
			<field name="id">
				<xsl:value-of select="substring-before(substring-after(@rdf:about, 'authorities/'), '#')"/>
			</field>
			<field name="created">
				<xsl:value-of select="dcterms:created"/>
			</field>
			<field name="modified">
				<xsl:value-of select="dcterms:modified"/>
			</field>
			<xsl:choose>
				<xsl:when test="skos:inScheme[contains(@rdf:resource, 'genreForm')]">
					<field name="genreform">
						<xsl:value-of select="skos:prefLabel"/>
					</field>
					<field name="source">
						<xsl:text>lcgft</xsl:text>
					</field>
				</xsl:when>
				<xsl:otherwise>
					<field name="subject">
						<xsl:value-of select="skos:prefLabel"/>
					</field>
					<field name="source">
						<xsl:text>lcsh</xsl:text>
					</field>
				</xsl:otherwise>
			</xsl:choose>			
		</doc>

	</xsl:template>

</xsl:stylesheet>
