<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:void="http://rdfs.org/ns/void#" xmlns:schema="https://schema.org/"
	xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:oa="http://www.w3.org/ns/oa#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
	exclude-result-prefixes="xsl xs tei xlink" version="2.0">
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
			<xsl:when test="//config/ark[@enabled = 'true']">
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
			<xsl:when test="local-name() = 'facsimile'">
				<xsl:apply-templates select="." mode="page">
					<xsl:with-param name="mode">root</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="element">
					<xsl:choose>
						<xsl:when test="descendant::tei:classCode = '300264354'">Book</xsl:when>
						<xsl:otherwise>CreativeWork</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>	
				
				<xsl:element name="schema:{$element}" namespace="https://schema.org/">
					<xsl:attribute name="rdf:about" select="$objectUri"/>
					
					<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
					<xsl:apply-templates select="tei:teiHeader/tei:profileDesc"/>
					<xsl:apply-templates select="descendant::tei:facsimile[@style = 'depiction']" mode="depiction"/>
					<void:inDataset rdf:resource="{$url}"/>
				</xsl:element>

				<xsl:apply-templates select="descendant::tei:facsimile" mode="structure"/>
				<xsl:apply-templates select="descendant::tei:facsimile[tei:surface]" mode="annotation"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:fileDesc">
		<xsl:apply-templates select="tei:titleStmt//tei:title"/>
		<xsl:apply-templates select="tei:sourceDesc//tei:author"/>
		<xsl:apply-templates select="tei:sourceDesc//tei:extent"/>
		<xsl:apply-templates select="tei:sourceDesc//tei:imprint/tei:date[@when]|tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:date[@when]"/>
	</xsl:template>

	<xsl:template match="tei:profileDesc">
		<xsl:apply-templates select="tei:abstract"/>

		<!-- genres -->
		<xsl:apply-templates select="tei:textClass/tei:classCode"/>
		
		<!-- subjects -->
		<xsl:apply-templates select="tei:particDesc//*[@ref]|descendant::tei:term[@ref]"/>
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
	
	<xsl:template match="tei:persName[@ref] | tei:orgName[@ref] | tei:term[@ref]">
		<xsl:variable name="uri" select="@ref"/>
		
		<dcterms:subject rdf:resource="{@ref}"/>
	</xsl:template>

	<xsl:template match="tei:author">
		<xsl:choose>
			<xsl:when test="*/@ref">
				<dcterms:creator rdf:resource="{*/@ref}"/>
			</xsl:when>
			<xsl:when test="tei:idno[@type='URI']">
				<dcterms:creator rdf:resource="{tei:idno[@type='URI']}"/>
			</xsl:when>
			<xsl:otherwise>
				<dcterms:creator>
					<xsl:value-of select="normalize-space(.)"/>
				</dcterms:creator>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:abstract">
		<dcterms:abstract>
			<xsl:value-of select="normalize-space(string-join(tei:p, ' '))"/>
		</dcterms:abstract>
	</xsl:template>

	<xsl:template match="tei:classCode">
		<xsl:if test="matches(@scheme, '^https?://')">
			<dcterms:type rdf:resource="{concat(@scheme, .)}"/>
		</xsl:if>
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

	<xsl:template match="tei:facsimile[@style = 'depiction']" mode="depiction">
		<xsl:apply-templates select="tei:graphic | tei:media[@type = 'IIIFService']"/>
	</xsl:template>

	<xsl:template match="tei:graphic" mode="depiction">
		<foaf:thumbnail rdf:resource="{concat($url, 'ui/media/thumbnail/', @url, '.jpg')}"/>
		<foaf:depiction rdf:resource="{concat($url, 'ui/media/reference/', @url, '.jpg')}"/>
	</xsl:template>

	<xsl:template match="tei:media[@type = 'IIIFService']">
		<foaf:thumbnail rdf:resource="{concat(@url, '/full/120,/0/default.jpg')}"/>
		<foaf:depiction rdf:resource="{concat(@url, '/full/!600,600/0/default.jpg')}"/>
	</xsl:template>

	<xsl:template match="tei:facsimile" mode="structure">
		<xsl:variable name="itemUri" select="concat($objectUri, '#', @xml:id)"/>

		<dcmitype:Text rdf:about="{$itemUri}">
			<dcterms:title>
				<xsl:choose>
					<xsl:when test="tei:graphic">
						<xsl:choose>
							<xsl:when test="string(tei:graphic/@n)">
								<xsl:value-of select="tei:graphic/@n"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="tei:graphic/@url"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="tei:media">
						<xsl:choose>
							<xsl:when test="string(tei:media/@n)">
								<xsl:value-of select="tei:media/@n"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="tei:media/@url"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</dcterms:title>
			<dcterms:type rdf:resource="http://vocab.getty.edu/aat/300194222"/>
			<dcterms:isPartOf rdf:resource="{$objectUri}"/>
			<dcterms:source rdf:resource="{$objectUri}"/>
			<void:inDataset rdf:resource="{$url}"/>
		</dcmitype:Text>
	</xsl:template>

	<xsl:template match="tei:facsimile" mode="annotation">
		<xsl:variable name="id" select="@xml:id"/>
		<xsl:variable name="itemUri" select="concat($objectUri, '#', $id)"/>

		<xsl:for-each select="tei:surface/tei:desc/tei:ref[@target]">
			<xsl:element name="oa:Annotation" namespace="http://www.w3.org/ns/oa#">
				<xsl:attribute name="rdf:about" select="concat($objectUri, '.rdf#', $id, '/annotations/', format-number(position(), '0000'))"/>

				<oa:hasBody rdf:resource="{@target}"/>
				<oa:hasTarget rdf:resource="{$itemUri}"/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
