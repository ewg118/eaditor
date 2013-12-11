<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">

	<xsl:template name="tei-content">
		<div class="yui3-g">
			<div class="yui3-u-1">
				<div class="content">
					<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="tei:fileDesc">
		<h1>
			<xsl:value-of select="tei:titleStmt/tei:title"/>
		</h1>
	</xsl:template>
</xsl:stylesheet>
