<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:eaditor="https://github.com/ewg118/eaditor" exclude-result-prefixes="#all" version="2.0">

	<xsl:include href="../../functions.xsl"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/*[not(local-name() = 'config')]"/>
	</xsl:template>

	<xsl:template match="mods:modsCollection">
		<xsl:apply-templates select="mods:mods"/>
	</xsl:template>

	<xsl:template match="mods:mods">
		<add>
			<doc>
				<field name="id">
					<xsl:value-of select="mods:recordInfo/mods:recordIdentifier"/>
				</field>
				<field name="recordId">
					<xsl:value-of select="mods:recordInfo/mods:recordIdentifier"/>
				</field>
				<field name="collection-name">
					<xsl:value-of select="$collection-name"/>
				</field>
				<field name="oai_set">mods</field>
				<field name="oai_id">
					<xsl:text>oai:</xsl:text>
					<xsl:value-of select="substring-before(substring-after($url, 'http://'), '/')"/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select="mods:recordInfo/mods:recordIdentifier"/>
				</field>
				<field name="timestamp">
					<xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"/>
				</field>
				<field name="unittitle_display">
					<xsl:value-of select="mods:titleInfo/mods:title"/>
				</field>
				<field name="publisher_display">
					<xsl:value-of select="mods:recordInfo/mods:recordContentSource"/>
				</field>
				<field name="unitid_display">
					<xsl:value-of select="mods:identifier"/>
				</field>

				<!-- process dates -->
				<xsl:apply-templates select="mods:relatedItem[@type = 'original']/mods:originInfo/mods:dateCreated"/>

				<field name="physdesc_display">
					<xsl:if test="mods:relatedItem/mods:physicalDescription/mods:form">
						<xsl:value-of select="mods:relatedItem/mods:physicalDescription/mods:form"/>
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:value-of select="mods:relatedItem/mods:physicalDescription/mods:extent"/>
				</field>
				<xsl:for-each select="mods:name | mods:subject/* | //mods:physicalDescription/mods:form">
					<xsl:variable name="facet">
						<xsl:choose>
							<xsl:when test="local-name() = 'form'">genreform</xsl:when>
							<xsl:when test="local-name() = 'genre'">genreform</xsl:when>
							<xsl:when test="local-name() = 'geographic'">geogname</xsl:when>
							<xsl:when test="local-name() = 'name'">
								<xsl:choose>
									<xsl:when test="@type = 'personal'">persname</xsl:when>
									<xsl:when test="@type = 'corporate'">corpname</xsl:when>
									<xsl:otherwise>persname</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="local-name() = 'occupation'">occupation</xsl:when>
							<xsl:when test="local-name() = 'topic'">subject</xsl:when>
						</xsl:choose>
					</xsl:variable>

					<field name="{$facet}_facet">
						<xsl:value-of select="
								if (mods:namePart) then
									mods:namePart
								else
									."/>
					</field>
					<field name="{$facet}_text">
						<xsl:value-of select="
								if (mods:namePart) then
									mods:namePart
								else
									."/>
					</field>
					<xsl:if test="string(@valueURI)">
						<field name="{$facet}_uri">
							<xsl:value-of select="@valueURI"/>
						</field>
					</xsl:if>
				</xsl:for-each>
				<field name="text">
					<xsl:for-each select="descendant-or-self::node()">
						<xsl:value-of select="text()"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</field>

				<xsl:apply-templates select="mods:location/mods:url[not(@note = 'IIIFService')]"/>
			</doc>
		</add>
	</xsl:template>

	<xsl:template match="mods:dateCreated">
		<field name="unitdate_display">
			<xsl:value-of select="."/>
		</field>
		<xsl:call-template name="eaditor:get_date_hierarchy">
			<xsl:with-param name="date" select="."/>
			<xsl:with-param name="upload" select="false()"/>
			<xsl:with-param name="multiDate" select="false()"/>
			<xsl:with-param name="position" select="1"/>
		</xsl:call-template>
	</xsl:template>

	<!-- images -->
	<xsl:template match="mods:url">
		<field>
			<xsl:attribute name="name">
				<xsl:choose>
					<xsl:when test="@access = 'preview'">collection_thumb</xsl:when>
					<xsl:when test="@usage = 'primary display'">collection_reference</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="."/>
		</field>
	</xsl:template>
</xsl:stylesheet>
