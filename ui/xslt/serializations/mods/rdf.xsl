<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:arch="http://purl.org/archival/vocab/arch#"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:schema="http://schema.org/" xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:svcs="http://rdfs.org/sioc/services#"
	xmlns:void="http://rdfs.org/ns/void#" xmlns:doap="http://usefulinc.com/ns/doap#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
	exclude-result-prefixes="xsl xs mods xlink eaditor" version="2.0">
	<xsl:include href="../../functions.xsl"/>

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
			<xsl:apply-templates select="//mods:mods"/>
		</rdf:RDF>
	</xsl:template>

	<!-- ***************** MODS-TO-RDF ******************-->

	<xsl:template match="mods:mods">
		<schema:ArchiveItem rdf:about="{$objectUri}">
			<dcterms:title>
				<xsl:value-of select="mods:titleInfo/mods:title"/>
			</dcterms:title>
			<xsl:apply-templates select="mods:relatedItem"/>
			<xsl:apply-templates select="mods:accessCondition[@type = 'rights']"/>
			<xsl:apply-templates select="mods:location/mods:url"/>
			<xsl:apply-templates select="mods:abstract"/>
			<xsl:apply-templates select="descendant::mods:name | mods:topic | mods:occupation | mods:form | mods:geographic | mods:genre" mode="topic"/>
			<void:inDataset rdf:resource="{$url}"/>
		</schema:ArchiveItem>

		<!-- add IIIF service metadata -->
		<xsl:apply-templates select="mods:location/mods:url[@note = 'IIIFService']" mode="WebResrouce"/>
	</xsl:template>

	<xsl:template match="mods:relatedItem">
		<xsl:apply-templates select="mods:originInfo/mods:dateCreated"/>
		<xsl:apply-templates select="mods:physicalDescription"/>
	</xsl:template>

	<xsl:template match="mods:accessCondition[@type = 'rights']">
		<dcterms:rights rdf:resource="{mods:url}"/>
	</xsl:template>

	<xsl:template match="mods:dateCreated">
		<dcterms:date>
			<xsl:if test=". castable as xs:date or . castable as xs:gYearMonth or . castable as xs:gYear">
				<xsl:attribute name="rdf:datatype" select="eaditor:date_dataType(.)"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</dcterms:date>
	</xsl:template>

	<xsl:template match="mods:abstract">
		<dcterms:abstract>
			<xsl:value-of select="."/>
		</dcterms:abstract>
	</xsl:template>

	<xsl:template match="mods:physicalDescription">
		<xsl:apply-templates select="mods:extent | mods:form"/>
	</xsl:template>

	<xsl:template match="mods:extent">
		<dcterms:extent>
			<xsl:value-of select="."/>
		</dcterms:extent>
	</xsl:template>

	<xsl:template match="mods:form">
		<dcterms:type>
			<xsl:choose>
				<xsl:when test="@valueURI">
					<xsl:attribute name="rdf:resource" select="@valueURI"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</dcterms:type>
	</xsl:template>

	<!-- images -->
	<xsl:template match="mods:location/mods:url">
		<xsl:choose>
			<xsl:when test="@access = 'preview'">
				<foaf:thumbnail rdf:resource="{.}"/>
			</xsl:when>
			<xsl:when test="@usage = 'primary display'">
				<foaf:depiction rdf:resource="{.}"/>
			</xsl:when>
			<xsl:when test="@access = 'raw object' and @note = 'IIIFService'">
				<edm:isShownBy rdf:resource="{.}/full/full/0/default.jpg"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:url[@note = 'IIIFService']" mode="WebResrouce">
		<edm:WebResource rdf:about="{concat(., '/full/full/0/default.jpg')}">
			<svcs:has_service rdf:resource="{.}"/>
			<dcterms:isReferencedBy rdf:resource="{.}/info.json"/>
		</edm:WebResource>
		<svcs:Service rdf:about="{.}">
			<dcterms:conformsTo rdf:resource="http://iiif.io/api/image"/>
			<doap:implements rdf:resource="http://iiif.io/api/image/2/level1.json"/>
		</svcs:Service>
	</xsl:template>

	<!-- topic terms -->
	<xsl:template match="*" mode="topic">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="local-name() = 'form'">dcterms:type</xsl:when>
				<xsl:when test="local-name() = 'geographic'">dcterms:coverage</xsl:when>
				<xsl:otherwise>dcterms:subject</xsl:otherwise>
			</xsl:choose>

		</xsl:variable>

		<xsl:element name="{$element}" namespace="http://purl.org/dc/terms/">
			<xsl:choose>
				<xsl:when test="string(@valueURI)">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="@valueURI"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="
							if (mods:namePart) then
								mods:namePart
							else
								."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>

	</xsl:template>
</xsl:stylesheet>
