<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gx="http://www.google.com/kml/ext/2.2"
	exclude-result-prefixes="xs ead mods rdf geo xlink" version="2.0">

	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/ead:ead"/>
	</xsl:template>

	<xsl:template match="ead:ead">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<xsl:variable name="id" select="ead:eadheader/ead:eadid"/>
				
				<xsl:apply-templates select="descendant::ead:geogname[string(@source) and string(@authfilenumber)]">
					<xsl:with-param name="id" select="$id"/>
				</xsl:apply-templates>
			</Document>
		</kml>
	</xsl:template>

	<!-- **************** EAD TO KML ******************* -->

	<xsl:template match="ead:geogname">
		<xsl:param name="id"/>

		<xsl:variable name="coordinates">
			<xsl:variable name="authfilenumber" select="@authfilenumber"/>
			
			<xsl:choose>
				<xsl:when test="@source='geonames'">
					<xsl:variable name="geonames_data" as="node()*">
						<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $authfilenumber, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					</xsl:variable>

					<xsl:value-of select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
				</xsl:when>
				<xsl:when test="@source='pleiades'">
					<xsl:value-of select="concat(/content/pleiades/place[@id=$authfilenumber]/long, ',', /content/pleiades/place[@id=$authfilenumber]/lat)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string($coordinates)">
			<Placemark xmlns="http://earth.google.com/kml/2.0" xmlns:gx="http://www.google.com/kml/ext/2.2">
				<name>
					<xsl:value-of select="."/>
				</name>

				<xsl:if test="ancestor::ead:c">
					<xsl:variable name="objectUri">
						<xsl:choose>
							<xsl:when test="//config/ark[@enabled='true']">
								<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', $id, '/', ancestor::ead:c[1]/@id)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($url, 'id/', $id, '/', ancestor::ead:c[1]/@id)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<description>
						<![CDATA[<a href="]]><xsl:value-of select="$objectUri"/><![CDATA[">]]>
						<xsl:value-of select="ancestor::ead:c[1]/ead:did/ead:unittitle"/>
						<xsl:if test="string(ancestor::ead:c[1]/ead:did/ead:unitdate)">
							<xsl:text>, </xsl:text>
							<xsl:value-of select="ancestor::ead:c[1]/ead:did/ead:unitdate"/>
						</xsl:if>
						<![CDATA[</a>]]>
					</description>
				</xsl:if>
				<Point>
					<coordinates>
						<xsl:value-of select="$coordinates"/>
					</coordinates>
				</Point>
				<!-- display timespan -->
				<xsl:choose>
					<xsl:when test="ancestor::ead:c">
						<!-- get the unitdate of the nearest component if the geogname is located in a component -->
						<xsl:if test="string(ancestor::ead:c[1]/ead:did/ead:unitdate/@normal)">
							<xsl:call-template name="get-timestamp">
								<xsl:with-param name="normal" select="ancestor::ead:c[1]/ead:did/ead:unitdate/@normal"/>
							</xsl:call-template>
						</xsl:if>

					</xsl:when>
					<xsl:otherwise>
						<!-- otherwise, get the unitdate of the archdesc/did -->
						<xsl:if test="string(ancestor::ead:archdesc/ead:did/ead:unitdate/@normal)">
							<xsl:call-template name="get-timestamp">
								<xsl:with-param name="normal" select="ancestor::ead:archdesc/ead:did/ead:unitdate/@normal"/>
							</xsl:call-template>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</Placemark>
		</xsl:if>
	</xsl:template>

	<xsl:template name="get-timestamp">
		<xsl:param name="normal"/>
		<xsl:choose>
			<xsl:when test="contains($normal, '/')">
				<gx:TimeSpan xmlns:gx="http://www.google.com/kml/ext/2.2">
					<gx:begin>
						<xsl:value-of select="tokenize($normal, '/')[1]"/>
					</gx:begin>
					<gx:end>
						<xsl:value-of select="tokenize($normal, '/')[2]"/>
					</gx:end>
				</gx:TimeSpan>
			</xsl:when>
			<xsl:otherwise>
				<gx:TimeStamp xmlns:gx="http://www.google.com/kml/ext/2.2">
					<gx:when>
						<xsl:value-of select="$normal"/>
					</gx:when>
				</gx:TimeStamp>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- **************** MODS TO KML ******************* -->
	<xsl:template name="mods-content">
		<xsl:variable name="id" select="mods:recordInfo/mods:recordIdentifier"/>

	</xsl:template>
</xsl:stylesheet>
