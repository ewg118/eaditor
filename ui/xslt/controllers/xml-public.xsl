<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber [gruber at numismatics dot org]
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	Modified: June 2011
	Function: Identity transform for the xml pipeline in EADitor.  Internal components are suppressed unless they have external
	descendants, in which case only the unittitles are displayed 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:ead="urn:isbn:1-931666-22-9" exclude-result-prefixes="#all" version="2.0">
	<xsl:output encoding="utf-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ead:c">
		<xsl:variable name="audience">
			<xsl:choose>
				<xsl:when test="string(@audience)">
					<xsl:value-of select="@audience"/>
				</xsl:when>
				<xsl:when test="not(string(@audience)) and parent::ead:dsc">
					<xsl:text>external</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="audience">
						<xsl:with-param name="id" select="@id"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$audience='internal' and descendant::ead:c[@audience='external']">
				<c xmlns="urn:isbn:1-931666-22-9">
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:for-each>
					<did>
						<xsl:apply-templates select="ead:did/ead:unittitle"/>
					</did>
					<xsl:apply-templates select="ead:c"/>
				</c>
			</xsl:when>
			<xsl:when test="$audience='external'">
				<c xmlns="urn:isbn:1-931666-22-9">
					<xsl:for-each select="@*">
						<xsl:attribute name="{name()}">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:for-each>					
					<xsl:apply-templates select="node()"/>
				</c>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- suppress internal non-component elements -->
	<xsl:template match="*[not(self::ead:eadheader)][not(local-name()='c') and @audience='internal']"/>

	<xsl:template name="audience">
		<xsl:param name="id"/>
		<xsl:choose>
			<xsl:when test="//ead:c[@id=$id]/parent::ead:dsc">
				<xsl:choose>
					<xsl:when test="string(//ead:c[@id=$id]/parent::node()/@audience)">
						<xsl:value-of select="//ead:c[@id=$id]/parent::node()/@audience"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>external</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="not(string(//ead:c[@id=$id]/parent::node()/@audience))">
						<xsl:call-template name="audience">
							<xsl:with-param name="id" select="//ead:c[@id=$id]/parent::node()/@id"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="//ead:c[@id=$id]/parent::node()/@audience"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- MODS -->
	<!-- suppress images, depending on rights statements -->	
	<xsl:template match="mods:url[parent::mods:location]">
		<xsl:variable name="rights" select="ancestor::mods:mods/mods:accessCondition[@type='rights']/mods:url"/>
		
		<xsl:choose>
			<xsl:when test="@access='preview'">
				<xsl:copy-of select="self::node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$rights = 'http://rightsstatements.org/vocab/InC-NC/1.0/' or $rights = 'http://rightsstatements.org/vocab/NoC-US/1.0/'">
						<xsl:copy-of select="self::node()"/>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
