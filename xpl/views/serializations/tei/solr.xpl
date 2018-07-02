<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:tei="http://www.tei-c.org/ns/1.0">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>	
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<!-- read the TEI file and look for a classCode with a Getty URI-->
	<!--<p:choose href="#data">
		<p:when test="descendant::tei:classCode[contains(@scheme, 'vocab.getty.edu/aat')]">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:template match="/">
							<xsl:apply-templates select="descendant::tei:classCode[contains(@scheme, 'vocab.getty.edu/aat')][1]"/>
						</xsl:template>
						
						<xsl:template match="tei:classCode">
							<xsl:variable name="uri" select="concat(@scheme, .)"/>
							<xsl:variable name="file" select="concat('http://vocab.getty.edu/download/rdf?uri=', encode-for-uri($uri), '.rdf')"/>
							
							<config>
								<url>
									<xsl:value-of select="$file"/>
								</url>
								<mode>binary</mode>
								
								<content-type>application/xml</content-type>
							</config>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
			
			<!-\-<p:processor name="oxf:url-generator">
				<p:input name="config" href="#generator-config"/>
				<p:output name="data" ref="data"/>
			</p:processor>-\->
			
			<!-\-<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #config, #data, #rdf)"/>		
				<p:input name="config" href="../../../../ui/xslt/serializations/tei/solr.xsl"/>
				<p:output name="data" ref="data"/>
			</p:processor>-\->
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #config, #data)"/>		
				<p:input name="config" href="../../../../ui/xslt/serializations/tei/solr.xsl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>-->
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', #config, #data)"/>		
		<p:input name="config" href="../../../../ui/xslt/serializations/tei/solr.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>

</p:config>
