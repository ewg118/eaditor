<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:oa="http://www.w3.org/ns/oa#"
	xmlns:pelagios="http://pelagios.github.io/vocab/terms#" xmlns:relations="http://pelagios.github.io/vocab/relations#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<rdf:RDF>
			<foaf:Organization rdf:about="{$url}pelagios.rdf#agents/me">
				<foaf:name>
					<xsl:value-of select="/content/config/publisher"/>
				</foaf:name>
			</foaf:Organization>
			<xsl:apply-templates select="descendant::doc"/>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="id" select="if (string(str[@name='cid'])) then str[@name='cid'] else str[@name='recordId']"/>
		<xsl:variable name="objectUri">
			<xsl:choose>
				<xsl:when test="//config/ark[@enabled='true']">
					<xsl:choose>
						<xsl:when test="string(str[@name='cid'])">
							<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', str[@name='recordId'], '/', str[@name='cid'])"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', str[@name='recordId'])"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string(str[@name='cid'])">
							<xsl:value-of select="concat($url, 'id/', str[@name='recordId'], '/', str[@name='cid'])"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($url, 'id/', str[@name='recordId'])"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="date" select="date[@name='timestamp']"/>

		<pelagios:AnnotatedThing rdf:about="{$url}pelagios.rdf#{$id}">
			<dcterms:title>
				<xsl:value-of select="str[@name='unittitle_display']"/>
			</dcterms:title>
			<foaf:homepage rdf:resource="{$objectUri}"/>
			<xsl:for-each select="distinct-values(arr[@name='genreform_uri']/str[contains(., 'vocab.getty.edu')])">
				<dcterms:format rdf:resource="{.}"/>
			</xsl:for-each>
		</pelagios:AnnotatedThing>

		<xsl:for-each select="distinct-values(arr[@name='pleiades_uri']/str)">
			<oa:Annotation rdf:about="{$url}pelagios.rdf#{$id}/annotations/{format-number(position(), '000')}">
				<oa:hasBody rdf:resource="{.}#this"/>
				<oa:hasTarget rdf:resource="{$url}pelagios.rdf#{$id}"/>
				<pelagios:relation rdf:resource="http://pelagios.github.io/vocab/relations#attestsTo"/>
				<oa:annotatedBy rdf:resource="{$url}pelagios.rdf#agents/me"/>
				<oa:annotatedAt rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
					<xsl:value-of select="$date"/>
				</oa:annotatedAt>
			</oa:Annotation>
		</xsl:for-each>

		<!--<oac:Annotation rdf:about="{$url}pelagios.rdf#{$id}">
			
			<xsl:for-each select="distinct-values(arr[@name='pleiades_uri']/str)">
				<oac:hasBody rdf:resource="{.}#this"/>
			</xsl:for-each>
			<oac:hasTarget rdf:resource="{$objectUri}"/>
		</oac:Annotation>-->
	</xsl:template>
</xsl:stylesheet>
