<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:datetime="http://exslt.org/dates-and-times"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:oac="http://www.openannotation.org/ns/" exclude-result-prefixes="datetime" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="descendant::doc"/>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="id" select="str[@name='id']"/>
		<xsl:variable name="objectUri">
			<xsl:choose>
				<xsl:when test="//config/ark[@enabled='true']">
					<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', str[@name='id'])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($url, 'id/', str[@name='id'])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<oac:Annotation rdf:about="{$url}pelagios.rdf#{$id}">
			<dcterms:title>
				<xsl:value-of select="str[@name='unittitle_display']"/>
			</dcterms:title>
			<xsl:for-each select="distinct-values(arr[@name='pleiades_uri']/str)">
				<oac:hasBody rdf:resource="{.}#this"/>
			</xsl:for-each>
			<oac:hasTarget rdf:resource="{$objectUri}"/>
		</oac:Annotation>
	</xsl:template>
</xsl:stylesheet>
