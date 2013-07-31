<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0" xmlns:xi="http://www.w3.org/2001/XInclude">
	<xsl:template match="/">
		<xsl:apply-templates select="/response"/>
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
