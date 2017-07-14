<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:ead="urn:isbn:1-931666-22-9" exclude-result-prefixes="#all" version="2.0">

	<!-- config variables -->
	<xsl:variable name="url" select="/config/url"/>
	<xsl:variable name="geonames_api_key" select="/config/geonames_api_key"/>	
	<xsl:variable name="geonames-url">http://api.geonames.org</xsl:variable>
	<xsl:variable name="eadid" select="doc('input:ead')/ead:ead/ead:eadheader/ead:eadid"/>
	
	<!-- read config to establish URI space -->
	<xsl:variable name="uri_space">
		<xsl:choose>
			<xsl:when test="/config/ark[@enabled='true']">
				<xsl:value-of select="concat($url, 'ark:/', /config/ark/naan, '/')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
				
				<xsl:value-of select="concat($url, $collection-name, '/id/')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<!-- generate unique list of georeferenceable places -->
		<xsl:variable name="places" as="node()*">
			<places>
				<xsl:for-each
					select="doc('input:ead')/descendant::ead:geogname[@source = 'geonames'][not(@authfilenumber = preceding::ead:geogname[@source = 'geonames']/@authfilenumber)]">
					<xsl:variable name="geonames_data" as="node()*">
						<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', @authfilenumber, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					</xsl:variable>
					
					<xsl:if test="$geonames_data//lng and $geonames_data//lat">
						<place uri="http://www.geonames.org/{@authfilenumber}" long="{$geonames_data//lng}" lat="{$geonames_data//lat}">
							<xsl:value-of select="."/>
						</place>
					</xsl:if>					
				</xsl:for-each>
				<xsl:for-each
					select="doc('input:ead')/descendant::ead:geogname[@source = 'pleiades'][not(@authfilenumber = preceding::ead:geogname[@source = 'pleiades']/@authfilenumber)]">
					<xsl:variable name="authfilenumber" select="@authfilenumber"/>
					
					<xsl:if test="number(doc('input:pleiades')//place[@id = $authfilenumber]/long) and number(doc('input:pleiades')//place[@id = $authfilenumber]/lat)">
						<place uri="http://pleiades.stoa.org/places/{@authfilenumber}" long="{doc('input:pleiades')//place[@id = $authfilenumber]/long}" lat="{doc('input:pleiades')//place[@id = $authfilenumber]/lat}">
							<xsl:value-of select="."/>
						</place>
					</xsl:if>					
				</xsl:for-each>
			</places>
		</xsl:variable>


		<!--<xml>
			<xsl:copy-of select="$places"/>
		</xml>-->

		<xsl:choose>
			<xsl:when test="count($places/place) &gt; 0">
				<xsl:text>{"type": "FeatureCollection","features": [</xsl:text>
				<xsl:apply-templates select="$places/place"/>
				<xsl:text>]}</xsl:text>
			</xsl:when>
			<xsl:otherwise>{}</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="place">
		<xsl:text>{"type": "Feature","label":"</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>",</xsl:text>
		<!-- geometry -->
		<xsl:text>"geometry": {"type": "Point","coordinates": [</xsl:text>
		<xsl:value-of select="@long"/>
		<xsl:text>, </xsl:text>
		<xsl:value-of select="@lat"/>
		<xsl:text>]},</xsl:text>
		
		<!-- properties -->
		<xsl:text>"properties": {"toponym": "</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>","gazetteer_label": "</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>", "gazetteer_uri": "</xsl:text>
		<xsl:value-of select="@uri"/>
		<xsl:text>","type": "relatedPlace"</xsl:text>
		<xsl:call-template name="relatedComponents">
			<xsl:with-param name="uri" select="@uri"/>
		</xsl:call-template>
		<xsl:text>}}</xsl:text>
		<xsl:if test="not(position() = last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<!-- process all components related to these places in order to generate links within the document -->
	<xsl:template name="relatedComponents">
		<xsl:param name="uri"/>
		<xsl:variable name="authfilenumber" select="tokenize($uri, '/')[last()]"/>
		
		<xsl:text>,"relatedComponent":[</xsl:text>
		<xsl:choose>
			<xsl:when test="contains($uri, 'geonames.org')">				
				<xsl:apply-templates select="doc('input:ead')/descendant::ead:c[ead:controlaccess/ead:geogname[@source='geonames'][@authfilenumber=$authfilenumber]]"/>
			</xsl:when>
			<xsl:when test="contains($uri, 'pleiades.stoa.org')">			
				<xsl:apply-templates select="doc('input:ead')/descendant::ead:c[ead:controlaccess/ead:geogname[@source='pleiades'][@authfilenumber=$authfilenumber]]"/>
			</xsl:when>
		</xsl:choose>
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<!-- create a JSON object for the component URI and title -->
	<xsl:template match="ead:c">
		<xsl:text>{</xsl:text>
		<xsl:text>"title":"</xsl:text>
		<xsl:value-of select="ead:did/ead:unittitle"/>	
		<xsl:text>","uri":"</xsl:text>
		<xsl:value-of select="concat($uri_space, $eadid, '#', @id)"/>
		<xsl:text>"</xsl:text>
		<xsl:text>}</xsl:text>
		<xsl:if test="not(position() = last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
