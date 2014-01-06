<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eaditor="https://github.com/ewg118/eaditor"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:template name="tei-content">
		<div class="yui3-g">
			<div class="yui3-u-1">
				<div class="content">
					<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
					<xsl:call-template name="facsimiles"/>
					<xsl:apply-templates select="tei:text"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="tei:fileDesc">
		<h1>
			<xsl:value-of select="tei:titleStmt/tei:title"/>
		</h1>
	</xsl:template>

	<!--<xsl:template match="tei:text">
		<div>
			<xsl:apply-templates/>
		</div>
	</xsl:template>-->

	<xsl:template name="facsimiles">
		<div>
			<!--<div>
				<button id="map-annotate-button">ADD ANNOTATION</button>
			</div>-->
			<div>
				<div id="annot"/>
			</div>

			<div id="slider">
				<xsl:apply-templates select="tei:facsimile"/>
			</div>
			<span style="display:none" id="image-path">
				<xsl:value-of select="concat($display_path, 'ui/media/archive/', tei:facsimile[1]/tei:graphic/@url, '.jpg')"/>
			</span>
			<span style="display:none" id="image-id">
				<xsl:value-of select="tei:facsimile[1]/@xml:id"/>
			</span>
			<span id="image-container"/>
			<span style="visibility:hidden">
				<xsl:call-template name="eaditor:generateAnnotationJson">
					<xsl:with-param name="id">nnan187715_0001</xsl:with-param>
				</xsl:call-template>
			</span>			
		</div>
	</xsl:template>

	<xsl:template match="tei:facsimile">
		<span class="page-image" id="{@xml:id}">
			<a href="{$include_path}ui/media/archive/{tei:graphic/@url}.jpg" title="{tei:graphic/@n}">
				<img src="{$include_path}ui/media/thumbnail/{tei:graphic/@url}.jpg" alt="{tei:graphic/@n}"/>
			</a>
		</span>
	</xsl:template>

	<xsl:template name="eaditor:generateAnnotationJson">
		<xsl:param name="id"/>
		<xsl:apply-templates select="descendant::tei:facsimile[@xml:id=$id]/tei:surface" mode="annotation"/>
	</xsl:template>
	
	<xsl:template match="tei:surface" mode="annotation">
		<span id="{parent::tei:facsimile/@xml:id}-object">
			{"src":"map://openlayers/something","text":"test","shapes":[{"type":"rect","geometry":{"x":<xsl:value-of select="number(@ulx)"/>,"width":<xsl:value-of select="number(@lrx) -  number(@ulx)"/>,"y":<xsl:value-of select="number(@uly)"/>,"height":<xsl:value-of select="number(@uly) -  number(@lry)"/>}}],"context":"<xsl:value-of select="$uri"/>"}
		</span>		
	</xsl:template>
</xsl:stylesheet>
