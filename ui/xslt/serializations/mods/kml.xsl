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
		<xsl:apply-templates select="/content//mods:mods"/>
	</xsl:template>

	<xsl:template match="mods:mods">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				
			</Document>
		</kml>
	</xsl:template>
</xsl:stylesheet>
