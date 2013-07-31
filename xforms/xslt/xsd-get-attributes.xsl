<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber, American Numismatic Society
	Modified: September, 2011
	Function: Accept a URL parameter called 'element' that is used to extract all of the attributes associated with that element.  Multiple levels of attributeGroups are also interated through -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="xs exsl" version="2.0">
	<xsl:param name="element">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='element']/value"/>
	</xsl:param>
	<xsl:template match="/">
		<!-- load XML attribute node into a variable for exsl:node-set() processing -->
		<xsl:variable name="chunk">
			<attributes>
				<xsl:apply-templates select="//xs:complexType[@name=$element]"/>
			</attributes>
		</xsl:variable>

		<!-- use exsl:node-set() function to sort attributes alphabetically by name -->
		<attributes>
			<xsl:for-each select="exsl:node-set($chunk)//attribute">
				<xsl:sort select="@name"/>
				<attribute name="{@name}"/>
			</xsl:for-each>
		</attributes>
	</xsl:template>

	<xsl:template match="xs:complexType">
		<xsl:apply-templates select="xs:attribute"/>
		<xsl:for-each select="xs:attributeGroup">
			<xsl:variable name="ref" select="@ref"/>
			<xsl:apply-templates select="//xs:attributeGroup[@name=$ref]"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="xs:attribute">
		<attribute name="{@name}"/>
	</xsl:template>

	<xsl:template match="xs:attributeGroup">
		<xsl:apply-templates select="xs:attribute"/>
		<xsl:for-each select="xs:attributeGroup">
			<xsl:variable name="ref" select="@ref"/>
			<xsl:apply-templates select="//xs:attributeGroup[@name=$ref]"/>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
