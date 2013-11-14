<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
				<xsl:variable name="facets">
					<xsl:for-each select="tokenize(/config/theme/facets, ',')">
						<xsl:text>&amp;facet.field=</xsl:text>
						<xsl:value-of select="."/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="service">					
					<xsl:value-of select="concat($solr-url, '?q=georef:*&amp;start=0&amp;rows=0&amp;facet.limit=1&amp;facet=true', $facets)"/>
				</xsl:variable>
				
				<xsl:template match="/">
					<xsl:copy-of select="document($service)/response"/>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>


</p:config>
