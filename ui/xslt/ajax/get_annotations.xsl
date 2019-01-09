<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	author: Ethan Gruber, gruber@numismatics.org 
	date modified: June 2014
	function: read the TEI-based annotations in a tei:facsimile to generate the JSON model required by annotorious
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:param name="doc" select="doc('input:request')/request/parameters/parameter[name='doc']/value"/>
	<xsl:param name="facsimile" select="doc('input:request')/request/parameters/parameter[name = 'facsimile']/value"/>

	<!-- generate JSON; be sure to call templates inside xsl:variable to allow create strings by which to normalize space -->

	<xsl:template match="/">
		<xsl:text>[</xsl:text>
		<xsl:apply-templates select="descendant::tei:facsimile[@xml:id = $facsimile]/tei:surface"/>
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template match="tei:surface">
		<xsl:variable name="id" select="parent::tei:facsimile/@xml:id"/>
		<xsl:variable name="text">
			<xsl:apply-templates select="tei:desc"/>
		</xsl:variable>
		
		<xsl:text>{"id":"</xsl:text>
		<xsl:value-of select="@xml:id"/>
		<xsl:text>",</xsl:text>
		<xsl:text>"src":"map://openlayers/something","text":"</xsl:text>
		<xsl:value-of select="normalize-space($text)"/>
		<xsl:text>","shapes":[{"type":"rect","units":"pixel","geometry":{"x":</xsl:text>
		<xsl:value-of select="number(@ulx)"/>
		<xsl:text>,"width":</xsl:text>
		<xsl:value-of select="number(@lrx) - number(@ulx)"/>
		<xsl:text>,"y":</xsl:text>
		<xsl:value-of select="number(@uly)"/>
		<xsl:text>,"height":</xsl:text>
		<xsl:value-of select="number(@lry) - number(@uly)"/>
		<xsl:text>}}],"context":"</xsl:text>
		<xsl:value-of select="concat(doc('input:request')/request/request-uri, '?doc=', $doc, '&amp;id=', $id)"/>
		<xsl:text>"}</xsl:text>
		<xsl:if test="not(position() = last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- handle the creation of HTML from tei:desc; don't forget to use single quotes -->
	<xsl:template match="tei:desc">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:ref">
		<xsl:variable name="content">
			<![CDATA[<a href=']]><xsl:value-of select="normalize-space(@target)"/><![CDATA[' target='_blank'>]]><xsl:value-of select="normalize-space(.)"
			/><![CDATA[</a>]]>
		</xsl:variable>
		<xsl:value-of select="normalize-space($content)"/>
	</xsl:template>
</xsl:stylesheet>
