<?xml version="1.0" encoding="UTF-8"?>
<!--
	Function: Construct the EADitor index page	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<!-- if there is a SPARQL endpoint, query whether to include a Pelagios RDF export link -->
	<p:choose href="#data">
		<p:when test="string(/config/sparql/query)">
			<!-- ask if there are objects in the SPARQL endpoint with a Pleiades URI dcterms:coverage -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">


						<!-- config variables -->
						<xsl:variable name="sparql_endpoint" select="/config/sparql/query"/>

						<xsl:variable name="query"><![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:	<http://purl.org/dc/terms/>

ASK {
 ?s dcterms:coverage ?place FILTER (strStarts(str(?place), 'https://pleiades.stoa.org'))  
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
				<p:output name="data" id="ask-url-generator-config"/>
			</p:processor>

			<!-- get the data from fuseki -->
			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#ask-url-generator-config"/>
				<p:output name="data" id="ask-response"/>
			</p:processor>

			<!-- pass the SPARQL response into the XSLT transformation -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="sparql-response" href="#ask-response"/>
				<p:input name="config" href="../../../ui/xslt/pages/index.xsl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:identity">
				<p:input name="data">
					<sparql xmlns="http://www.w3.org/2005/sparql-results#">
						<head> </head>
						<boolean>false</boolean>
					</sparql>
				</p:input>
				<p:output name="data" id="ask-response"/>
			</p:processor>

			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="sparql-response" href="#ask-response"/>
				<p:input name="config" href="../../../ui/xslt/pages/index.xsl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>


</p:config>
