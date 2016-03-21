<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xhv="http://www.w3.org/1999/xhtml/vocab#"
	xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:schema="https://schema.org/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:oa="http://www.w3.org/ns/oa#"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" exclude-result-prefixes="#all" version="2.0">
	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	
	<!-- url params -->
	<xsl:param name="uri" select="doc('input:request')/request/request-url"/>
	<xsl:variable name="path">
		<xsl:choose>
			<xsl:when test="contains($uri, 'ark:/')">
				<xsl:value-of select="substring-before(substring-after(substring-after($uri, 'ark:/'), '/'), '.rdf')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before(substring-after($uri, 'id/'), '.rdf')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="objectUri">
		<xsl:choose>
			<xsl:when test="//config/ark[@enabled='true']">
				<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', $path)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($url, 'id/', $path)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="/content/tei:TEI"/>
		</rdf:RDF>
	</xsl:template>

	<!-- ***************** TEI-TO-RDF ******************-->
	<xsl:template match="tei:TEI">
		<!-- handle serialization of individual facsimiles or the TEI documen as a whole -->
		<xsl:choose>
			<xsl:when test="local-name()='facsimile'">
				<xsl:apply-templates select="." mode="page">
					<xsl:with-param name="mode">root</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<schema:Book rdf:about="{$objectUri}">
					<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
					<xsl:apply-templates select="descendant::tei:facsimile[@style='depiction']" mode="depiction"/>
				</schema:Book>				
				
				<xsl:apply-templates select="descendant::tei:facsimile" mode="structure"/>					
				<xsl:apply-templates select="descendant::tei:keywords"/>
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

	<xsl:template match="tei:facsimile" mode="structure">		
		<xsl:variable name="itemUri" select="concat($objectUri, '#', @xml:id)"/>		

		<dcmitype:Text rdf:about="{$itemUri}">
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
			<dcterms:type rdf:resource="http://vocab.getty.edu/aat/300194222"/>
			<dcterms:isPartOf rdf:resource="{$objectUri}"/>		
			<dcterms:source rdf:resource="{$objectUri}"/>
		</dcmitype:Text>
	</xsl:template>
	
	<xsl:template match="tei:keywords">
		<xsl:variable name="itemUri" select="concat($objectUri, '#', @corresp)"/>
		
		<xsl:for-each select="tei:term[@target]">
			<xsl:element name="oa:Annotation" namespace="http://www.w3.org/ns/oa#">
				<xsl:attribute name="rdf:about" select="concat($objectUri, '.rdf#', parent::node()/@corresp, '/annotations/', format-number(position(), '0000'))"/>
				
				<oa:hasBody rdf:resource="{@target}"/>
				<oa:hasTarget rdf:resource="{$itemUri}"/>
			</xsl:element>
		</xsl:for-each>
		
	</xsl:template>
</xsl:stylesheet>
