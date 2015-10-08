<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:eaditor="https://github.com/ewg118/eaditor" exclude-result-prefixes="xs eaditor xs xi" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../serializations/solr/html-templates.xsl"/>

	<xsl:variable name="flickr-api-key" select="/config/flickr_api_key"/>
	<xsl:variable name="display_path"/>
	<xsl:variable name="pipeline">results_ajax</xsl:variable>

	<!-- URL parameters -->
	<xsl:param name="lang" select="doc('input:params')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="q" select="doc('input:params')/request/parameters/parameter[name='q']/value"/>
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:param name="sort">
		<xsl:if test="string(doc('input:params')/request/parameters/parameter[name='sort']/value)">
			<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='sort']/value"/>
		</xsl:if>
	</xsl:param>
	<xsl:param name="rows" as="xs:integer">10</xsl:param>
	<xsl:param name="start" as="xs:integer">
		<xsl:choose>
			<xsl:when test="string(doc('input:params')/request/parameters/parameter[name='start']/value)">
				<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='start']/value"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>

	<xsl:template match="/">
		<html>
			<head/>
			<body>
				<xsl:variable name="georef_string" select="replace(translate($tokenized_q[contains(., 'georef')], '&#x022;()', ''), 'georef:', '')"/>
				<xsl:variable name="georefs" select="tokenize($georef_string, ' OR ')"/>
				<h1>
					<xsl:text>Location</xsl:text>
					<xsl:if test="contains($georef_string, ' OR ')">
						<xsl:text>s</xsl:text>
					</xsl:if>
					<xsl:text>: </xsl:text>
					<xsl:for-each select="$georefs">
						<xsl:value-of select="tokenize(., '\|')[2]"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
					<small>
						<a id="clear_all" href="#">clear</a>
					</small>
				</h1>
				<xsl:call-template name="paging"/>
				<table class="table table-striped">
					<xsl:apply-templates select="descendant::doc"/>
				</table>
				<xsl:call-template name="paging"/>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
