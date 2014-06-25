<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xhv="http://www.w3.org/1999/xhtml/vocab#"
	xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" exclude-result-prefixes="#all" version="2.0">

	<!-- ***************** TEI-TO-RDF ******************-->
	<xsl:template name="tei-content">
		<rdf:Description rdf:about="{$objectUri}">
			<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
			<!-- depiction -->
			<xsl:apply-templates select="descendant::tei:facsimile[@style='depiction']"/>
		</rdf:Description>
		<xsl:apply-templates select="descendant::tei:facsimile"/>
	</xsl:template>

	<xsl:template match="tei:fileDesc">
		<xsl:apply-templates select="tei:sourceDesc//tei:title"/>
		<xsl:apply-templates select="tei:sourceDesc//tei:author"/>
		<xsl:apply-templates select="tei:sourceDesc//tei:extent"/>
		<xsl:apply-templates select="tei:sourceDesc//tei:imprint/tei:date[@when]"/>
		<xsl:apply-templates select="descendant::tei:note[@type='abstract']"/>
	</xsl:template>

	<xsl:template match="tei:title">
		<dcterms:title>
			<xsl:value-of select="."/>
		</dcterms:title>
	</xsl:template>

	<xsl:template match="tei:extent">
		<dcterms:extent>
			<xsl:value-of select="."/>
		</dcterms:extent>
	</xsl:template>

	<xsl:template match="tei:author">
		<xsl:choose>
			<xsl:when test="*/@ref">
				<dcterms:creator rdf:resource="{*/@ref}"/>
			</xsl:when>
			<xsl:otherwise>
				<dcterms:creator>
					<xsl:value-of select="normalize-space(.)"/>
				</dcterms:creator>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:note[@type='abstract']">
		<dcterms:abstract>
			<xsl:value-of select="."/>
		</dcterms:abstract>
	</xsl:template>

	<xsl:template match="tei:date">
		<dcterms:date>
			<xsl:attribute name="rdf:datatype">
				<xsl:choose>
					<xsl:when test="@when castable as xs:date">
						<xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
					</xsl:when>
					<xsl:when test="@when castable as xs:gYearMonth">
						<xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
					</xsl:when>
					<xsl:when test="@when castable as xs:gYear">
						<xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="@when"/>
		</dcterms:date>
	</xsl:template>

	<xsl:template match="tei:facsimile[@style='depiction']">
		<foaf:thumbnail rdf:resource="{concat($url, 'ui/media/thumbnail/', tei:graphic/@url, '.jpg')}"/>
		<foaf:depiction rdf:resource="{concat($url, 'ui/media/reference/', tei:graphic/@url, '.jpg')}"/>
	</xsl:template>

	<xsl:template match="tei:facsimile">
		<rdf:Description rdf:about="{$objectUri}/{@xml:id}">
			<dcterms:title>
				<xsl:choose>
					<xsl:when test="string(tei:graphic/@n)">
						<xsl:value-of select="tei:graphic/@n"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="tei:graphic/@url"/>
					</xsl:otherwise>
				</xsl:choose>
			</dcterms:title>
			<dcterms:isPartOf rdf:resource="{$objectUri}"/>
			<xsl:for-each select="distinct-values(descendant::tei:ref/@target)">
				<dcterms:subject rdf:resource="{.}"/>
			</xsl:for-each>
		</rdf:Description>
	</xsl:template>
</xsl:stylesheet>
