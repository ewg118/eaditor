<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:datetime="http://exslt.org/dates-and-times"
	exclude-result-prefixes="#all" version="2.0">

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
				<field name="oai_id">
					<xsl:text>oai:</xsl:text>
					<xsl:value-of select="substring-before(substring-after($url, 'http://'), '/')"/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select="mods:recordInfo/mods:recordIdentifier"/>
				</field>
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
				<field name="unittitle_display">
					<xsl:value-of select="mods:titleInfo/mods:title"/>
				</field>
				<field name="publisher_display">
					<xsl:value-of select="mods:recordInfo/mods:recordContentSource"/>
				</field>
				<field name="unitid_display">
					<xsl:value-of select="mods:identifier"/>
				</field>
				<field name="unitdate_display">
					<xsl:value-of select="mods:originInfo/mods:dateCreated"/>
				</field>
				<field name="physdesc_display">
					<xsl:if test="mods:relatedItem/mods:physicalDescription/mods:form">
						<xsl:value-of select="mods:relatedItem/mods:physicalDescription/mods:form"/>
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:value-of select="mods:relatedItem/mods:physicalDescription/mods:extent"/>
				</field>
				<field name="genreform_facet">
					<xsl:value-of select="normalize-space(mods:physicalDescription/mods:form)"/>
				</field>
				<xsl:if test="mods:relatedItem/mods:physicalDescription/mods:form">
					<field name="genreform_facet">
						<xsl:value-of select="normalize-space(mods:relatedItem/mods:physicalDescription/mods:form)"/>
					</field>
				</xsl:if>
				<xsl:for-each select="mods:name/mods:namePart[1]|mods:subject/mods:topic">
					<xsl:variable name="category" select="if(parent::mods:name[@type='personal']) then 'persname' else if (parent::mods:name[@type='corporate']) then 'corpname' else 'subject'"/>

					<field name="{$category}_facet">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:for-each>
				<field name="fulltext">
					<xsl:for-each select="descendant-or-self::node()">
						<xsl:value-of select="text()"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</field>
			</doc>
		</add>
	</xsl:template>
</xsl:stylesheet>
