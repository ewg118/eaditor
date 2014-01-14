<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	Function: Get the appropriate data model given URL parameter 'uri',
	to be passed to get_label XPL for XSL processing into JSON.
	JSON is used by backend Annotorious annotations containing html links.
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

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

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:param name="uri" select="doc('input:request')/request/parameters/parameter[name='uri']/value"/>
				<xsl:template match="/">
					<xsl:choose>
						<xsl:when test="contains($uri, 'http://nomisma.org/')">
							<xsl:copy-of select="document(concat($uri, '.rdf'))/*"/>
						</xsl:when>
						<xsl:when test="contains($uri, 'http://numismatics.org/collection/')">
							<xsl:copy-of select="document(concat($uri, '.rdf'))/*"/>
						</xsl:when>
						<xsl:otherwise>
							<response>
								<xsl:value-of select="$uri"/>
							</response>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>