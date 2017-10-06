<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2017 Ethan Gruber
	Numishare
	Apache License 2.0
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:mods="http://www.loc.gov/mods/v3">
	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:choose href="#data">
		<p:when test="descendant::mods:url[@note='IIIFService']">
			<!-- iterate through the daogrps with IIIF Services -->
			<p:for-each href="#data" select="descendant::mods:url[@note='IIIFService']" root="images" id="images">
				<!-- generate an XForms processor to request JSON -->
				<p:processor name="oxf:xslt">
					<p:input name="data" href="current()"/>
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
							<xsl:variable name="service" select="concat(normalize-space(.), '/info.json')"/>
							<xsl:template match="/">
								<xforms:submission method="get" action="{$service}">
									<xforms:header>
										<xforms:name>User-Agent</xforms:name>
										<xforms:value>XForms/EADitor</xforms:value>
									</xforms:header>
								</xforms:submission>
							</xsl:template>
						</xsl:stylesheet>
					</p:input>
					<p:output name="data" id="xforms-config"/>
				</p:processor>
				
				<p:processor name="oxf:xforms-submission">
					<p:input name="request" href="#request"/>
					<p:input name="submission" href="#xforms-config"/>
					<p:output name="response" id="json"/>
				</p:processor>
				
				<!-- wrap the JSON response into an XML element so that the URI can be passed through; the URI in the JSON may be escaped, whereas the URI stored in SPARQL may not be -->
				<p:processor name="oxf:xslt">
					<p:input name="data" href="current()"/>
					<p:input name="json" href="#json"/>
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
							<xsl:variable name="service" select="normalize-space(.)"/>
							<xsl:template match="/">
								<image uri="{$service}">
									<xsl:copy-of select="doc('input:json')"/>
								</image>
							</xsl:template>
						</xsl:stylesheet>
					</p:input>
					<p:output name="data" ref="images"/>
				</p:processor>		
			</p:for-each>
			
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="images" href="#images"/>
				<p:input name="data" href="aggregate('content', #data, #config)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/mods/iiif-manifest.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						<xsl:template match="/">
							<xsl:text>{"error":"No IIIF services"}</xsl:text>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
	

	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/json</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
