<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:datetime="http://exslt.org/dates-and-times" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="xs datetime xlink"
	version="2.0">

	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
		<add>
			<doc>
				<field name="id">
					<xsl:value-of select="ead:ead/@id"/>
				</field>

				<!-- get info from archdesc/did, mostly for display -->
				<xsl:apply-templates select="//ead:archdesc/ead:did"/>

				<!-- facets -->
				<xsl:if test="string(normalize-space(//ead:eadid/@mainagencycode))">
					<field name="agencycode_facet">
						<xsl:value-of select="normalize-space(//ead:eadid/@mainagencycode)"/>
					</field>
				</xsl:if>

				<xsl:for-each
					select="descendant::ead:corpname | descendant::ead:famname | descendant::ead:genreform | descendant::ead:geogname | descendant::ead:langmaterial/ead:language | descendant::ead:persname | descendant::ead:subject">
					
					<field name="{local-name()}_text">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:for-each>
				
				<field name="has_components">
					<xsl:value-of select="if (descendant::ead:c) then 'true' else 'false'"/>
				</field>
				
				<!-- timestamp -->
				<field name="timestamp">
					<xsl:variable name="timestamp" select="datetime:dateTime()"/>
					<xsl:choose>
						<xsl:when test="contains($timestamp, 'Z')">
							<xsl:value-of select="$timestamp"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($timestamp, 'Z')"/>
						</xsl:otherwise>
					</xsl:choose>
				</field>

				<!-- fulltext -->
				<field name="fulltext">
					<xsl:value-of select="ead:ead/@id"/>
					<xsl:text> </xsl:text>
					<xsl:for-each select="descendant-or-self::node()">
						<xsl:value-of select="text()"/>
						<xsl:text> </xsl:text>
						<xsl:if test="@normal">
							<xsl:value-of select="@normal"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</field>
			</doc>
		</add>
	</xsl:template>

	<xsl:template match="ead:archdesc/ead:did">	
		<field name="unittitle_display">
			<xsl:value-of select="normalize-space(ead:unittitle)"/>
		</field>
		<field name="unittitle_text">
			<xsl:value-of select="normalize-space(ead:unittitle)"/>
		</field>
	</xsl:template>

</xsl:stylesheet>
