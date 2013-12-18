<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">

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
			<div>
				<button onclick="annotate();">ADD ANNOTATION</button> 
				<button onlick="anno.destroy(map);">DESTROY ANNOTATIONS</button>
			</div>
			<div>
				<div id="annot"/>
				<!--<a id="map-annotate-button" href="#">ADD ANNOTATION</a>-->
			</div>

			<div id="slider">
				<xsl:apply-templates select="tei:facsimile"/>
			</div>
			<span style="display:none" id="image-path">
				<xsl:value-of select="concat($display_path, 'ui/media/archive/', tei:facsimile[1]/tei:graphic/@url, '.jpg')"/>
			</span>
			<span id="image-container"/>
			
		</div>		
	</xsl:template>

	<xsl:template match="tei:facsimile">
		<span class="page-image">
			<a href="{$display_path}ui/media/archive/{tei:graphic/@url}.jpg" title="{tei:graphic/@n}">
				<img src="{$display_path}ui/media/thumbnail/{tei:graphic/@url}.jpg" alt="{tei:graphic/@n}"/>
			</a>
		</span>
	</xsl:template>
</xsl:stylesheet>
