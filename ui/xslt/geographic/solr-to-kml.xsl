<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0" xmlns:xi="http://www.w3.org/2001/XInclude">

	<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
	<!-- request URL -->
	<xsl:param name="base-url" select="substring-before(doc('input:url')/request/request-url, 'feed/')"/>

	<xsl:param name="q">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='q']/value"/>
	</xsl:param>
	<xsl:variable name="encoded_q" select="encode-for-uri($q)"/>
	<xsl:param name="rows">0</xsl:param>
	<xsl:param name="start">
		<xsl:choose>
			<xsl:when test="string(doc('input:params')/request/parameters/parameter[name='start']/value)">
				<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='start']/value"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:variable name="service">
		<xsl:value-of select="concat($solr-url, '?q=', $encoded_q, '&amp;start=', $start, '&amp;facet.field=georef')"/>
	</xsl:variable>
	<xsl:param name="tokenized_q" select="tokenize($q, ' AND ')"/>

	<xsl:template match="/">
		<xsl:apply-templates select="document($service)/response"/>
	</xsl:template>

	<xsl:template match="response">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<xsl:for-each select="//lst[@name='georef']/int">
					<xsl:variable name="tokenized_georef" select="tokenize(@name, '\|')"/>
					<xsl:variable name="url" select="concat('http://www.geonames.org/', $tokenized_georef[1], '/')"/>
					<xsl:variable name="place" select="$tokenized_georef[2]"/>
					<xsl:variable name="coordinates" select="$tokenized_georef[3]"/>

					<Placemark>
						<name>
							<xsl:value-of select="$place"/>
						</name>
						<description>
							<xsl:value-of select="@name"/>
						</description>
						<Point>
							<coordinates>
								<xsl:value-of select="$coordinates"/>
							</coordinates>
						</Point>
					</Placemark>
				</xsl:for-each>
			</Document>
		</kml>
	</xsl:template>

</xsl:stylesheet>
