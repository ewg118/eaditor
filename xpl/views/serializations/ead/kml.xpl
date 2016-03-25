<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xforms="http://www.w3.org/2002/xforms">

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

	<!-- iterate through geognames with a @source of 'pleiades' in order to aggregate coordinates -->
	<p:for-each href="#data" select="descendant::ead:geogname[@source='pleiades'][not(@authfilenumber=preceding::ead:geogname/@authfilenumber)]" root="pleiades" id="pleiades">
		<!-- construct a URL generator config -->
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="data" href="current()"/>
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
					<xsl:variable name="service" select="concat('http://pleiades.stoa.org/places/', ead:geogname/@authfilenumber, '/json2')"/>
					
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
		
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="data" href="#json"/>
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
					
					<xsl:template match="/json">
						<place id="{tokenize(documenturi, '/')[last()]}">
							<lat>
								<xsl:value-of select="reprPoint/_[2]"/>
							</lat>
							<long>
								<xsl:value-of select="reprPoint/_[1]"/>
							</long>
						</place>
					</xsl:template>
				</xsl:stylesheet>
			</p:input>
			<p:output name="data" ref="pleiades"/>
		</p:processor>
	</p:for-each>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', #config, #pleiades, #data)"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/ead/kml.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>

	<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/vnd.google-earth.kml+xml</content-type>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>

</p:config>
