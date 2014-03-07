<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
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
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:param name="uri" select="/request/parameters/parameter[name='uri']/value"/>

				<xsl:template match="/">
					<parser>
						<xsl:choose>
							<xsl:when test="contains($uri, 'http://nomisma.org/')">true</xsl:when>
							<xsl:when test="contains($uri, 'http://numismatics.org/collection/')">true</xsl:when>
							<xsl:when test="contains($uri, 'http://numismatics.org/library/')">true</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</parser>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="parser-config"/>
	</p:processor>

	<p:choose href="#parser-config">
		<p:when test="parser='true'">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="../exist-config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:param name="uri" select="doc('input:request')/request/parameters/parameter[name='uri']/value"/>
						<xsl:template match="/">
							<xsl:variable name="service">
								<xsl:choose>
									<xsl:when test="contains($uri, 'http://nomisma.org/')">
										<xsl:value-of select="concat($uri, '.rdf')"/>
									</xsl:when>
									<xsl:when test="contains($uri, 'http://numismatics.org/collection/')">
										<xsl:value-of select="concat($uri, '.rdf')"/>
									</xsl:when>
									<xsl:when test="contains($uri, 'http://numismatics.org/library/')">
										<xsl:value-of select="concat('http://donum.numismatics.org/cgi-bin/koha/opac-export.pl?format=dc&amp;op=export&amp;bib=', substring-after($uri, 'library/'))"/>
									</xsl:when>
								</xsl:choose>
							</xsl:variable>
							<config>
								<url>
									<xsl:value-of select="$service"/>
								</url>
								<mode>xml</mode>
								<content-type>application/xml</content-type>
								<encoding>utf-8</encoding>
							</config>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="generator-config"/>
			</p:processor>
			
			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#generator-config"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="../exist-config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:param name="uri" select="doc('input:request')/request/parameters/parameter[name='uri']/value"/>
						<xsl:template match="/">
							<response>
								<xsl:value-of select="$uri"/>
							</response>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>

	
</p:config>
