<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
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

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'eaditor/'), '/')"/>
				<!-- request params -->
				<xsl:param name="verb" select="doc('input:request')/request/parameters/parameter[name='verb']/value"/>
				<xsl:param name="metadataPrefix" select="doc('input:request')/request/parameters/parameter[name='metadataPrefix']/value"/>
				<xsl:param name="set" select="doc('input:request')/request/parameters/parameter[name='set']/value"/>
				<xsl:param name="identifier" select="doc('input:request')/request/parameters/parameter[name='identifier']/value"/>
				<xsl:param name="from" select="doc('input:request')/request/parameters/parameter[name='from']/value"/>
				<xsl:param name="until" select="doc('input:request')/request/parameters/parameter[name='until']/value"/>
				<xsl:param name="resumptionToken" select="doc('input:request')/request/parameters/parameter[name='resumptionToken']/value"/>

				<!-- validate from, until, resumptionToken -->
				<xsl:variable name="from-validate" as="xs:boolean" select="$from castable as xs:date"/>
				<xsl:variable name="until-validate" as="xs:boolean" select="$until castable as xs:date"/>

				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>

				<xsl:variable name="q">
					<xsl:choose>
						<xsl:when test="string($identifier)">
							<xsl:text>oai_id:%22</xsl:text>
							<xsl:value-of select="normalize-space($identifier)"/>
							<xsl:text>%22</xsl:text>
						</xsl:when>
						<xsl:when test="string($from) or string($until)">
							<xsl:if test="$from-validate=true() or $until-validate=true()">
								<xsl:text>timestamp:[</xsl:text>
								<xsl:value-of select="if($from-validate=true()) then concat($from, 'T00:00:00.000Z') else '*'"/>
								<xsl:text>+TO+</xsl:text>
								<xsl:value-of select="if($until-validate=true()) then concat($until, 'T23:59:59.999Z') else '*'"/>
								<xsl:text>]</xsl:text>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>*:*</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="service">
					<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+', $q, '&amp;sort=timestamp%20desc&amp;rows=10000')"/>
				</xsl:variable>

				<xsl:template match="/">
					<xsl:copy-of select="document($service)/response"/>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>


</p:config>
