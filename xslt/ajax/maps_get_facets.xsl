<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:variable name="exist-url" select="/exist-url"/>
	<!-- load config.xml from eXist into a variable which is later processed with exsl:node-set -->
	<xsl:variable name="config" select="document(concat($exist-url, 'eaditor/config.xml'))"/>
	<xsl:variable name="solr-url" select="concat(exsl:node-set($config)/config/solr_published, 'select/')"/>
	
	<!-- URL parameters -->
	<xsl:param name="q">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	</xsl:param>	
	<xsl:variable name="encoded_q" select="encode-for-uri(concat($q, ' AND georef:*'))"/>
	<xsl:param name="tokenized_q" select="tokenize($q, ' AND ')"/>

	
	<xsl:param name="start">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
	</xsl:param>
	<xsl:param name="category">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='category']/value"/>
	</xsl:param>
	<xsl:param name="sort">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
	</xsl:param>
	<xsl:param name="offset" as="xs:integer">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='offset']/value"/>
	</xsl:param>
	<xsl:param name="limit" as="xs:integer">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='limit']/value"/>
	</xsl:param>
	
	<!-- Solr query URL -->
	<xsl:variable name="service">
		<xsl:value-of select="concat($solr-url, '?q=', $encoded_q, '&amp;category=', $category, '&amp;facet.field=', $category, '&amp;facet.sort=', $sort, '&amp;f.', $category, '.facet.offset=', $offset, '&amp;facet.limit=', $limit, '&amp;rows=0')"/>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>test</title>
			</head>
			<body>
				<ul>
					<xsl:apply-templates select="document($service)/descendant::lst[@name='facet_fields']/lst[@name=$category]"/>
				</ul>
			</body>
		</html>
		
	</xsl:template>

	<xsl:template match="lst[@name=$category]">		
		<xsl:if test="not($category = 'category_facet')">
			<xsl:variable name="facet" select="@name"/>
			<xsl:choose>
				<xsl:when test="count(int) &gt; 1">
					<li>
						<div class="ui-widget-header ui-corner-all ui-helper-clearfix">
							<xsl:choose>
								<xsl:when test="$sort = 'count'">
									<span class="sort_facet" id="{$category}-index" label="{$q}">Sort alphabetically</span>
								</xsl:when>
								<xsl:when test="$sort = 'index'">
									<span class="sort_facet" id="{$category}-count" label="{$q}">Sort by occurrences</span>
								</xsl:when>
							</xsl:choose>
							<span style="float:right" class="close_facets" id="{$category}-close">
								<span class="ui-icon ui-icon-circle-close"/>
							</span>
							<xsl:call-template name="paging"/>
						</div>

					</li>
				</xsl:when>
				<xsl:otherwise>
					<li>
						<div class="ui-widget-header ui-corner-all ui-helper-clearfix">
							<span style="float:right" class="close_facets" id="{$category}-close">
								<span class="ui-icon ui-icon-circle-close"/>
							</span>
						</div>
					</li>
				</xsl:otherwise>
			</xsl:choose>


			<xsl:for-each select="int">
				<xsl:variable name="matching_term">
					<xsl:value-of select="concat($facet, ':&#x022;', @name, '&#x022;')"/>
				</xsl:variable>

				<li class="term">
					<xsl:choose>
						<xsl:when test="contains($q, $matching_term)">
							<xsl:variable name="new_query">
								<xsl:for-each select="$tokenized_q[not($matching_term = .)]">
									<xsl:value-of select="."/>
									<xsl:if test="position() != last()">
										<xsl:text> AND </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<div class="fn">
								<xsl:value-of select="@name"/>
							</div>

							<div class="ft">
								<xsl:text> [</xsl:text>
								<span href="?q={if (string($new_query)) then $new_query else '*:*'}">X</span>
								<xsl:text>]</xsl:text>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div class="fn">
								<span href="?q={$facet}:&#x022;{@name}&#x022;">
									<xsl:value-of select="@name"/>
								</span>
							</div>
							<div class="ft">
								<xsl:value-of select="."/>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</li>
			</xsl:for-each>			
			<xsl:if test="$limit != 11">
				<div class="ui-widget-header ui-corner-all ui-helper-clearfix ui-multiselect-hasfilter">
					<xsl:call-template name="paging"/>
				</div>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="paging">
		<xsl:variable name="new_query">
			<xsl:value-of select="concat($q, ' AND georef:*')"/>
		</xsl:variable>
		<xsl:variable name="next">
			<xsl:value-of
				select="count(document(concat($solr-url, '?q=', encode-for-uri($new_query), '&amp;category=', $category, '&amp;facet.field=', $category, '&amp;facet.sort=', $sort, '&amp;facet.limit=', $limit, '&amp;f.', $category, '.facet.offset=', $offset + $limit, '&amp;rows=', 0))//lst[@name='facet_fields']/lst[@name=$category]/int)"
			/>
		</xsl:variable>
		<div style="display:table;width:100%">
			<span style="float:left;font-weight:bold">
				<xsl:text>Page: </xsl:text>
				<xsl:value-of select="($offset div $limit) + 1"/>
			</span>
			<div style="float:right">
				<xsl:choose>
					<xsl:when test="$offset = 0">
						<span>Previous</span>
					</xsl:when>
					<xsl:otherwise>
						<span id="{$category}-prev" class="page-facets" label="{$q}" title="{$offset - $limit}:{$sort}">Previous</span>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> | </xsl:text>
				<xsl:choose>
					<xsl:when test="number($next)= 0">
						<span>Next</span>
					</xsl:when>
					<xsl:otherwise>
						<span id="{$category}-next" class="page-facets" label="{$q}" title="{$offset + $limit}:{$sort}">Next</span>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
