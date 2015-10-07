<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:eaditor="https://github.com/ewg118/eaditor" exclude-result-prefixes="xs eaditor xs xi" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../serializations/solr/html-templates.xsl"/>

	<xsl:variable name="flickr-api-key" select="/config/flickr_api_key"/>
	<xsl:variable name="display_path">../</xsl:variable>
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
				<xsl:apply-templates select="//doc"/>
				<xsl:call-template name="paging"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="sort_category" select="substring-before($sort, ' ')"/>
		<xsl:variable name="regularized_sort">
			<xsl:value-of select="eaditor:normalize_fields($sort_category, $lang)"/>
		</xsl:variable>

		<div class="result_div row">
			<xsl:variable name="objectUri">
				<xsl:choose>
					<xsl:when test="//config/ark[@enabled='true']">
						<xsl:choose>
							<xsl:when test="string(str[@name='cid'])">
								<xsl:value-of select="concat($display_path, 'ark:/', //config/ark/naan, '/', str[@name='recordId'], '/', str[@name='cid'])"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($display_path, 'ark:/', //config/ark/naan, '/', str[@name='recordId'])"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="string(str[@name='cid'])">
								<xsl:value-of select="concat($display_path, 'id/', str[@name='recordId'], '/', str[@name='cid'])"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($display_path, 'id/', str[@name='recordId'])"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<div class="col-md-7">
				<h3>
					<a href="{$objectUri}">
						<xsl:value-of select="str[@name='unittitle_display']"/>
					</a>
				</h3>
				<dl class="dl-horizontal">
					<dt>
						<xsl:value-of select="eaditor:normalize_fields('date', $lang)"/>
					</dt>
					<dd>
						<xsl:choose>
							<xsl:when test="string(str[@name='unitdate_display'])">
								<xsl:value-of select="str[@name='unitdate_display']"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>[Unknown]</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</dd>
					<xsl:if test="string(str[@name='publisher_display'])">
						<dt>
							<xsl:value-of select="eaditor:normalize_fields('publisher', $lang)"/>
						</dt>
						<dd>
							<xsl:value-of select="str[@name='publisher_display']"/>
							<xsl:if test="str[@name='agencycode_facet']">
								<xsl:value-of select="concat(' (', str[@name='agencycode_facet'], ')')"/>
							</xsl:if>
						</dd>
					</xsl:if>
					<xsl:if test="string(str[@name='physdesc_display'])">
						<dt>
							<xsl:value-of select="eaditor:normalize_fields('physdesc', $lang)"/>
						</dt>
						<dd>
							<xsl:value-of select="str[@name='physdesc_display']"/>
						</dd>
					</xsl:if>
					<xsl:if test="string(arr[@name='level_facet']/str[1])">
						<dt>
							<xsl:value-of select="eaditor:normalize_fields('level_facet', $lang)"/>
						</dt>
						<dd>
							<xsl:value-of select="arr[@name='level_facet']/str[1]"/>
						</dd>
					</xsl:if>
				</dl>
			</div>
			<xsl:if test="count(arr[@name='collection_thumb']/str) &gt; 0">
				<div class="col-md-5 img-container text-right">
					<xsl:apply-templates select="arr[@name='collection_thumb']/str[position() &lt;=5]"/>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
</xsl:stylesheet>
