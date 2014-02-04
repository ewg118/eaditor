<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
	This stylesheet preprocesses user-uploaded EAD finding aids, fixing consistency problems -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:isbn:1-931666-22-9"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
<!--	<xsl:strip-space elements="*"/>-->

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name()='ead']">
		<xsl:variable name="id">
			<xsl:choose>
				<xsl:when test="string(@id)">
					<xsl:value-of select="@id"/>
				</xsl:when>
				<xsl:when test="string(//*[local-name()='eadheader']/*[local-name()='eadid'])">
					<xsl:value-of
						select="normalize-space(//*[local-name()='eadheader']/*[local-name()='eadid'])"
					/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="generate-id(.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<ead xmlns="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink" id="{$id}">
			<xsl:apply-templates select="@*[not(name() = 'id')]|node()"/>
		</ead>
	</xsl:template>
	
	<xsl:template match="*[local-name()='dsc'] | *[local-name()='archdesc']">
		<xsl:variable name="id">
			<xsl:choose>
				<xsl:when test="string(@id)">
					<xsl:value-of select="@id"/>
				</xsl:when>				
				<xsl:otherwise>
					<xsl:value-of select="generate-id(.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:element name="{local-name()}">
			<xsl:attribute name="id" select="$id"/>
			<xsl:for-each select="@*[not(name()='id')]">
				<xsl:attribute name="{name()}">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name()='unittitle']">
		<unittitle>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:for-each>

			<xsl:apply-templates select="text()|node()[not(local-name() = 'unitdate')]"/>
		</unittitle>

		<!-- unitdate is separated out as a sibling of unittitle and child of the did -->
		<xsl:if test="string(*[local-name()='unitdate'][1])">
			<xsl:apply-templates select="*[local-name()='unitdate']"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name()='container'][@type]">
		<container>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}">
					<xsl:choose>
						<xsl:when test="name() = 'type'">
							<xsl:value-of select="lower-case(.)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:for-each>
			<xsl:value-of select="."/>
		</container>
	</xsl:template>

	<xsl:template
		match="*[local-name()='c01'] | *[local-name()='c02'] | *[local-name()='c03'] | *[local-name()='c04'] | *[local-name()='c05'] | *[local-name()='c06'] | *[local-name()='c07'] | *[local-name()='c08'] | *[local-name()='c09'] | *[local-name()='c10'] | *[local-name()='c11'] | *[local-name()='c12']">
		<xsl:variable name="id">
			<xsl:choose>
				<xsl:when test="string(@id)">
					<xsl:value-of select="@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="generate-id(.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
		<c id="{$id}">
			<xsl:for-each select="@*[not(name()='id')]">
				<xsl:attribute name="{name()}">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates select="node()"/>
		</c>
	</xsl:template>

	<xsl:template match="*[local-name()='controlaccess']">
		<controlaccess>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:for-each>
			<xsl:for-each
				select="descendant::*[local-name()='corpname'] | descendant::*[local-name()='famname'] | descendant::*[local-name()='function'] | descendant::*[local-name()='genreform'] | descendant::*[local-name()='geogname'] | descendant::*[local-name()='name'] | descendant::*[local-name()='occupation'] | descendant::*[local-name()='persname'] | descendant::*[local-name()='subject'] | descendant::*[local-name()='title']">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</controlaccess>
	</xsl:template>

	<!-- normalize space of childless elements -->
	<xsl:template match="node()[count(child::node()) = 0]">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>
</xsl:stylesheet>