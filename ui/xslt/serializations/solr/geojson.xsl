<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xsl:template match="/">
		
		<xsl:choose>
			<xsl:when test="count(//lst[@name='georef']/int) &gt; 0">
				<xsl:text>{"type": "FeatureCollection","features": [</xsl:text>
				<xsl:apply-templates select="//lst[@name='georef']/int"/>
				<xsl:text>]}</xsl:text>
			</xsl:when>
			<xsl:otherwise>{}</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	

	<xsl:template match="int">
		<xsl:variable name="tokenized_georef" select="tokenize(@name, '\|')"/>
		<xsl:variable name="url" select="concat('http://www.geonames.org/', $tokenized_georef[1])"/>
		<xsl:variable name="place" select="$tokenized_georef[2]"/>
		<xsl:variable name="coordinates" select="$tokenized_georef[3]"/>
		
		<!-- long comes before lat in index -->
		<xsl:variable name="long" select="normalize-space(substring-before($coordinates, ','))"/>
		<xsl:variable name="lat" select="normalize-space(substring-after($coordinates, ','))"/>
		
		<!-- only include features that have valid lat and long -->
		<xsl:if test="$lat castable as xs:decimal and $long castable as xs:decimal">
			<xsl:text>{"type": "Feature","label":"</xsl:text>
			<xsl:value-of select="$place"/>
			<xsl:text>",</xsl:text>		
			<!-- geometry -->
			<xsl:text>"geometry": {"type": "Point","coordinates": [</xsl:text>
			<xsl:value-of select="$long"/>
			<xsl:text>, </xsl:text>
			<xsl:value-of select="$lat"/>
			<xsl:text>]},</xsl:text>
			
			<!-- properties -->
			<xsl:text>"properties": {"toponym": "</xsl:text>
			<xsl:value-of select="$place"/>
			<xsl:text>","gazetteer_label": "</xsl:text>
			<xsl:value-of select="$place"/>
			<xsl:text>", "gazetteer_uri": "</xsl:text>
			<xsl:value-of select="$url"/>
			<xsl:text>","type": "relatedPlace","georef":"</xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text>"</xsl:text>
			<xsl:text>}}</xsl:text>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
