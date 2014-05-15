<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xhv="http://www.w3.org/1999/xhtml/vocab#"
	xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" exclude-result-prefixes="#all" version="2.0">
	<!-- ***************** MODS-TO-RDF ******************-->
	<xsl:template name="mods-content">
		<xsl:apply-templates select="//mods:mods"/>
	</xsl:template>

	<xsl:template match="mods:mods">
		<rdf:Description rdf:about="{$objectUri}">
			<dcterms:title>
				<xsl:value-of select="mods:titleInfo/mods:title"/>
			</dcterms:title>
			<xsl:apply-templates select="mods:relatedItem"/>
			<xsl:apply-templates select="descendant::mods:subject/mods:topic"/>
		</rdf:Description>
	</xsl:template>

	<xsl:template match="mods:relatedItem">
		<xsl:apply-templates select="mods:originInfo/mods:dateCreated"/>
		<xsl:apply-templates select="mods:physicalDescription"/>
	</xsl:template>

	<xsl:template match="mods:dateCreated">
		<dcterms:temporal>
			<xsl:value-of select="."/>
		</dcterms:temporal>
	</xsl:template>

	<xsl:template match="mods:physicalDescription">
		<xsl:if test="mods:extent">
			<dcterms:extent>
				<xsl:value-of select="mods:extent"/>
			</dcterms:extent>
		</xsl:if>
		<xsl:if test="mods:form">
			<dcterms:format>
				<xsl:value-of select="mods:form"/>
			</dcterms:format>
		</xsl:if>
	</xsl:template>

	<xsl:template match="mods:topic">
		<dcterms:subject>
			<xsl:value-of select="."/>
		</dcterms:subject>
	</xsl:template>
</xsl:stylesheet>
