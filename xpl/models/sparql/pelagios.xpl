<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql/query"/>

				<xsl:variable name="query"><![CDATA[
PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX edm:	<http://www.europeana.eu/schemas/edm/>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX ecrm:	<http://erlangen-crm.org/current/>
PREFIX geo:	<http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX arch:	<http://purl.org/archival/vocab/arch#>
PREFIX oa:	<http://www.w3.org/ns/oa#>
PREFIX doap:	<http://usefulinc.com/ns/doap#>
PREFIX svcs:	<http://rdfs.org/sioc/services#>

DESCRIBE * WHERE {
 ?s dcterms:coverage ?place FILTER (strStarts(str(?place), 'https://pleiades.stoa.org'))  
  OPTIONAL {?s edm:isShownBy ?full .
  	?full svcs:has_service ?service}
}]]></xsl:variable>

				<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri($query), '&amp;output=xml')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
