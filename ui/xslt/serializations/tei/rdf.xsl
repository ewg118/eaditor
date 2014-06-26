<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xhv="http://www.w3.org/1999/xhtml/vocab#"
	xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" exclude-result-prefixes="#all" version="2.0">

	<!-- ***************** TEI-TO-RDF ******************-->
	<xsl:template name="tei-content">
		<!-- handle serialization of individual facsimiles or the TEI documen as a whole -->
		<xsl:choose>
			<xsl:when test="local-name()='facsimile'">
				<xsl:apply-templates select="." mode="page">
					<xsl:with-param name="mode">root</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<rdf:Description rdf:about="{$objectUri}">
					<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
					<!-- depiction -->
					<xsl:apply-templates select="descendant::tei:facsimile[@style='depiction']" mode="depiction"/>
				</rdf:Description>
				<xsl:apply-templates select="descendant::tei:facsimile" mode="page">
					<xsl:with-param name="mode">page</xsl:with-param>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
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
			<xsl:value-of select="normalize-space(.)"/>
		</dcterms:title>
	</xsl:template>

	<xsl:template match="tei:extent">
		<dcterms:extent>
			<xsl:value-of select="normalize-space(.)"/>
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
			<xsl:value-of select="normalize-space(.)"/>
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

	<xsl:template match="tei:facsimile[@style='depiction']" mode="depiction">
		<foaf:thumbnail rdf:resource="{concat($url, 'ui/media/thumbnail/', tei:graphic/@url, '.jpg')}"/>
		<foaf:depiction rdf:resource="{concat($url, 'ui/media/reference/', tei:graphic/@url, '.jpg')}"/>
	</xsl:template>

	<xsl:template match="tei:facsimile" mode="page">
		<xsl:param name="mode"/>
		<xsl:variable name="itemUri">
			<xsl:choose>
				<xsl:when test="$mode='root'">
					<xsl:value-of select="$objectUri"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($objectUri, '/', @xml:id)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="parentUri">
			<xsl:choose>
				<xsl:when test="$mode='root'">
					<xsl:variable name="pieces" select="tokenize($objectUri, '/')"/>
					<xsl:for-each select="$pieces[not(position()=last())]">
						<xsl:value-of select="."/>
						<xsl:if test="not(position()=last())">
							<xsl:text>/</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$objectUri"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<rdf:Description rdf:about="{$itemUri}">
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
			<dcterms:isPartOf rdf:resource="{$parentUri}"/>
			<xsl:for-each select="distinct-values(descendant::tei:ref/@target)">
				<dcterms:subject rdf:resource="{.}"/>
			</xsl:for-each>
		</rdf:Description>
	</xsl:template>
</xsl:stylesheet>
