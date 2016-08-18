<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	exclude-result-prefixes="#all">
	
	<xsl:param name="set">
		<xsl:choose>
			<xsl:when test="not(string(doc('input:harvester')/harvester/@date))">
				<xsl:value-of select="doc('input:harvester')/harvester/@url"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(doc('input:harvester')/harvester/@url, 'amp;from=', @date)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	
	<xsl:template match="/">
		<files>
			<xsl:apply-templates select="/oai:OAI-PMH"/>
		</files>
	</xsl:template>
	
	<xsl:template match="oai:OAI-PMH">
		<xsl:apply-templates select="descendant::oai:record"/>
		
		<xsl:if test="descendant::oai:resumptionToken">
			<xsl:apply-templates select="document(concat($set, '&amp;resumptionToken=', descendant::oai:resumptionToken))/oai:OAI-PMH"/>			
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="oai:record">
		<xsl:if test="oai:metadata[descendant::dc:relation[ends-with(., 'xml')]]">
			<file>
				<url>
					<xsl:value-of select="descendant::dc:relation[ends-with(., 'xml')][1]"/>
				</url>
				<date>
					<xsl:value-of select="oai:header/oai:datestamp"/>
				</date>
			</file>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>