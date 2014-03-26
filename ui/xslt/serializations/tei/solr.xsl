<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:datetime="http://exslt.org/dates-and-times" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0">

	<xsl:template match="tei:TEI">
		<add>
			<doc>
				<field name="id">
					<xsl:value-of select="@xml:id"/>
				</field>
				<field name="recordId">
					<xsl:value-of select="@xml:id"/>
				</field>
				<field name="collection-name">
					<xsl:value-of select="$collection-name"/>
				</field>
				<field name="oai_id">
					<xsl:text>oai:</xsl:text>
					<xsl:value-of select="substring-before(substring-after($url, 'http://'), '/')"/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select="@xml:id"/>
				</field>
				<field name="timestamp">
					<xsl:variable name="timestamp" select="datetime:dateTime()"/>
					<xsl:choose>
						<xsl:when test="contains($timestamp, 'Z')">
							<xsl:value-of select="$timestamp"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($timestamp, 'Z')"/>
						</xsl:otherwise>
					</xsl:choose>
				</field>

			</doc>
		</add>
	</xsl:template>
</xsl:stylesheet>
