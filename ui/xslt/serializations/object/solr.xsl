<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	exclude-result-prefixes="#all" version="2.0">

	<!-- includes -->
	<xsl:include href="../ead/solr.xsl"/>
	<xsl:include href="../mods/solr.xsl"/>
	<xsl:include href="../tei/solr.xsl"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'eaditor/'), '/')"/>
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>

	<xsl:variable name="places" as="node()*">
		<places>
			<xsl:for-each select="descendant::ead:geogname[@source='geonames' and string(@authfilenumber)]">
				<xsl:variable name="geonames_data" as="node()*">
					<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', @authfilenumber, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
				</xsl:variable>

				<place authfilenumber="{@authfilenumber}">
					<xsl:value-of select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
				</place>
			</xsl:for-each>
		</places>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/*[not(local-name()='config')]"/>
	</xsl:template>
</xsl:stylesheet>
