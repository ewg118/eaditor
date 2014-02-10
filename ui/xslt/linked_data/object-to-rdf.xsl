<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xhv="http://www.w3.org/1999/xhtml/vocab#" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" exclude-result-prefixes="mods ead xlink tei" version="2.0">
	<xsl:include href="../display/ead/rdf.xsl"/>
	<xsl:include href="../display/mods/rdf.xsl"/>
	<xsl:include href="../display/tei/rdf.xsl"/>

	<!-- url params -->
	<xsl:param name="uri" select="doc('input:request')/request/request-url"/>
	<xsl:param name="path">
		<xsl:choose>
			<xsl:when test="contains($uri, 'ark:/')">
				<xsl:value-of select="substring-before(substring-after(substring-after($uri, 'ark:/'), '/'), '.rdf')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before(substring-after($uri, 'id/'), '.rdf')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
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
		<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="root"/>
	</xsl:template>

	<xsl:template match="*" mode="root">
		<rdf:RDF>
			<xsl:choose>
				<xsl:when test="namespace-uri()='http://www.loc.gov/mods/v3'">
					<xsl:call-template name="mods-content"/>
				</xsl:when>
				<xsl:when test="namespace-uri()='urn:isbn:1-931666-22-9'">
					<xsl:call-template name="ead-content"/>
				</xsl:when>
				<xsl:when test="namespace-uri()='http://www.tei-c.org/ns/1.0'">
					<xsl:call-template name="tei-content"/>
				</xsl:when>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>
</xsl:stylesheet>
