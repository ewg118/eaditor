<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
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
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
				<!-- url params -->
				<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>

				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>

				<xsl:variable name="service">
					<xsl:choose>
						<!-- when there is a collection name, apply collection name in Solr query -->
						<xsl:when test="/config/aggregator = 'true'">
							<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri($q), '&amp;start=0&amp;rows=0&amp;facet.field=georef&amp;facet=true')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($solr-url, '?q=collection-name:', $collection-name, '+AND+', encode-for-uri($q),
								'&amp;start=0&amp;rows=0&amp;facet.field=georef&amp;facet=true')"/>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:variable>

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
		<p:output name="data" id="generator-config"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
