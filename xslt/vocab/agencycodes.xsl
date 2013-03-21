<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
	Get @mainagencycodes from eXist, weed out duplicates -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:template match="/">
		<temp>
			<xsl:for-each select="distinct-values(//ead:eadid/@mainagencycode)">
				<xsl:sort/>
				<agencycode value="{.}">
					<xsl:value-of select="."/>
				</agencycode>
			</xsl:for-each>

		</temp>
	</xsl:template>	
</xsl:stylesheet>
