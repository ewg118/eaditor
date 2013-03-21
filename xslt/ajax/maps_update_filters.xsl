<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" xmlns:eaditor="http://code.google.com/p/eaditor/" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../results_functions.xsl"/>
	<xsl:output method="xml" encoding="UTF-8"/>
	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>
	<!-- load config.xml from eXist into a variable which is later processed with exsl:node-set -->
	<xsl:variable name="config" select="document(concat($exist-url, 'eaditor/config.xml'))"/>
	<xsl:variable name="solr-url" select="concat(exsl:node-set($config)/config/solr_published, 'select/')"/>
	<xsl:variable name="facets">
		<xsl:for-each select="tokenize(exsl:node-set($config)/config/theme/facets, ',')">
			<xsl:text>&amp;facet.field=</xsl:text>
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:variable>
	
	<!-- URL parameters -->
	<xsl:param name="q">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	</xsl:param>	
	<xsl:variable name="encoded_q" select="encode-for-uri(concat($q, ' AND georef:*'))"/>
	
	<!-- Solr query URL -->
	<xsl:variable name="service">
		<xsl:value-of select="concat($solr-url, '?q=', $encoded_q, '&amp;facet=true&amp;start=0&amp;rows=0&amp;facet.limit=1', $facets, '&amp;facet.sort=index')"/>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>test</title>
			</head>
			<body>
				<ul>
					<xsl:for-each
						select="document($service)//lst[@name='facet_fields']/lst[count(int) &gt; 0 and not(@name='geogname_facet')]">
						<li class="filter_facet ui-widget ui-state-default ui-corner-all" id="{@name}_link" label="{$q}">
							<div class="filter_heading">
								<xsl:value-of select="eaditor:normalize_fields(@name)"/>
							</div>
							<ul class="filter_terms ui-widget ui-widget-content ui-corner-all hidden" id="{@name}-list"/>
						</li>
					</xsl:for-each>
				</ul>
			</body>
		</html>		
	</xsl:template>

</xsl:stylesheet>
