<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs eaditor exsl xs xi" version="2.0"
	xmlns:xi="http://www.w3.org/2001/XInclude" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common"
	xmlns:eaditor="http://code.google.com/p/eaditor/">
	<xsl:include href="../results_functions.xsl"/>

	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>
	<!-- load config.xml from eXist into a variable which is later processed with exsl:node-set -->
	<xsl:variable name="config" select="document(concat($exist-url, 'eaditor/config.xml'))"/>
	<xsl:variable name="flickr-api-key" select="exsl:node-set($config)/config/flickr_api_key"/>
	<xsl:variable name="solr-url" select="concat(exsl:node-set($config)/config/solr_published, 'select/')"/>
	<xsl:variable name="ui-theme" select="exsl:node-set($config)/config/theme/jquery_ui_theme"/>
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="pipeline">results</xsl:variable>

	<!-- URL parameters -->
	<xsl:param name="q">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='q']/value"/>
	</xsl:param>
	<xsl:param name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:variable name="encoded_q" select="encode-for-uri($q)"/>
	<xsl:param name="sort">
		<xsl:if test="string(doc('input:params')/request/parameters/parameter[name='sort']/value)">
			<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='sort']/value"/>
		</xsl:if>
	</xsl:param>
	<xsl:variable name="encoded_sort" select="encode-for-uri($sort)"/>
	<xsl:param name="rows" as="xs:integer">10</xsl:param>
	<xsl:param name="start" as="xs:integer">
		<xsl:choose>
			<xsl:when test="string(doc('input:params')/request/parameters/parameter[name='start']/value)">
				<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='start']/value"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<!-- request URL -->
	<xsl:param name="base-url" select="substring-before(doc('input:url')/request/request-url, 'results/')"/>

	<!-- Solr query URL -->
	<xsl:variable name="service">
		<xsl:choose>
			<xsl:when test="string($sort)">
				<xsl:value-of select="concat($solr-url, '?q=', $encoded_q, '&amp;start=', $start, '&amp;sort=', $encoded_sort, '&amp;rows=', $rows)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($solr-url, '?q=', $encoded_q, '&amp;start=', $start, '&amp;rows=', $rows)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="response" select="document($service)"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>results_ajax</title>
			</head>
			<body>
				<div id="temp-results">
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
						<a id="clear_results" href="#">clear</a>
					</h1>
					<xsl:call-template name="paging"/>
					<xsl:apply-templates select="exsl:node-set($response)//doc"/>
					<xsl:call-template name="paging"/>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="sort_category" select="substring-before($sort, ' ')"/>
		<xsl:variable name="regularized_sort">
			<xsl:value-of select="eaditor:normalize_fields($sort_category)"/>
		</xsl:variable>

		<div class="result_div">
			<dl class="result_info">
				<div>
					<dt>
						<b>Title</b>
					</dt>
					<dd>
						<a href="{$display_path}show/{str[@name='id']}">
							<xsl:value-of select="str[@name='unittitle_display']"/>
						</a>
					</dd>
				</div>
				<div>
					<dt>
						<b>Date</b>
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
				</div>
				<xsl:if test="string(str[@name='publisher_display'])">
					<div>
						<dt>
							<b>Publisher</b>
						</dt>
						<dd>
							<xsl:value-of select="str[@name='publisher_display']"/>
							<xsl:if test="str[@name='agencycode_facet']">
								<xsl:value-of select="concat(' (', str[@name='agencycode_facet'], ')')"/>
							</xsl:if>
						</dd>
					</div>
				</xsl:if>
				<xsl:if test="string(str[@name='physdesc_display'])">
					<div>
						<dt>
							<b>Physical Description</b>
						</dt>
						<dd>
							<xsl:value-of select="str[@name='physdesc_display']"/>
						</dd>
					</div>
				</xsl:if>

			</dl>
			<xsl:if test="count(arr[@name='thumb_image']/str) &gt; 0">
				<div style="float:right">
					<xsl:apply-templates select="arr[@name='thumb_image']/str"/>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="arr[@name='thumb_image']/str">
		<div class="thumbImage">
			<xsl:choose>
				<xsl:when test="contains(., 'flickr.com')">
					<xsl:variable name="photo_id" select="substring-before(tokenize(., '/')[last()], '_')"/>
					<xsl:variable name="flickr_uri" select="eaditor:get_flickr_uri($photo_id)"/>
					<a href="#{generate-id()}">
						<img class="gi" src="{.}"/>
					</a>
					<div style="display:none">
						<div id="{generate-id()}">
							<span href="{$flickr_uri}" class="flickr-link">
								<img class="gi" src="{ancestor::doc/arr[@name='reference_image']/str[contains(., $photo_id)]}"/>
							</span>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<img src="."/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template name="paging">
		<xsl:variable name="start_var">
			<xsl:choose>
				<xsl:when test="number($start)">
					<xsl:value-of select="$start"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="numFound">
			<xsl:value-of select="number(exsl:node-set($response)/response/result[@name='response']/@numFound)"/>
		</xsl:variable>

		<xsl:variable name="next">
			<xsl:value-of select="$start_var+$rows"/>
		</xsl:variable>

		<xsl:variable name="previous">
			<xsl:choose>
				<xsl:when test="$start_var &gt;= $rows">
					<xsl:value-of select="$start_var - $rows"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="current" select="number($start_var div $rows + 1)"/>
		<xsl:variable name="total" select="ceiling($numFound div $rows)"/>

		<div class="paging_div">
			<div style="float:left;">
				<xsl:text>Displaying records </xsl:text>
				<b>
					<xsl:value-of select="$start_var + 1"/>
				</b>
				<xsl:text> to </xsl:text>
				<xsl:choose>
					<xsl:when test="$numFound &gt; ($start_var + $rows)">
						<b>
							<xsl:value-of select="$start_var + $rows"/>
						</b>
					</xsl:when>
					<xsl:otherwise>
						<b>
							<xsl:value-of select="$numFound"/>
						</b>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> of </xsl:text>
				<b>
					<xsl:value-of select="$numFound"/>
				</b>
				<xsl:text> total results.</xsl:text>
			</div>

			<!-- paging functionality -->
			<div style="float:right;">
				<xsl:choose>
					<xsl:when test="$start_var &gt;= $rows">
						<xsl:choose>
							<xsl:when test="string($sort)">
								<a class="pagingBtn" href="?q={$q}&amp;start={$previous}&amp;sort={$sort}">«Previous</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="pagingBtn" href="?q={$q}&amp;start={$previous}">«Previous</a>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:when>
					<xsl:otherwise>
						<span class="pagingSep">«Previous</span>
					</xsl:otherwise>
				</xsl:choose>

				<!-- always display links to the first two pages -->
				<xsl:if test="$start_var div $rows &gt;= 3">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="?q={$q}&amp;start=0&amp;sort={$sort}">
								<xsl:text>1</xsl:text>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="?q={$q}&amp;start=0">
								<xsl:text>1</xsl:text>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>
				<xsl:if test="$start_var div $rows &gt;= 4">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="?q={$q}&amp;start={$rows}&amp;sort={$sort}">
								<xsl:text>2</xsl:text>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="?q={$q}&amp;start={$rows}">
								<xsl:text>2</xsl:text>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>

				<!-- display only if you are on page 6 or greater -->
				<xsl:if test="$start_var div $rows &gt;= 5">
					<span class="pagingSep">...</span>
				</xsl:if>

				<!-- always display links to the previous two pages -->
				<xsl:if test="$start_var div $rows &gt;= 2">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="?q={$q}&amp;start={$start_var - ($rows * 2)}&amp;sort={$sort}">
								<xsl:value-of select="($start_var div $rows) -1"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="?q={$q}&amp;start={$start_var - ($rows * 2)}">
								<xsl:value-of select="($start_var div $rows) -1"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="$start_var div $rows &gt;= 1">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="?q={$q}&amp;start={$start_var - $rows}&amp;sort={$sort}">
								<xsl:value-of select="$start_var div $rows"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="?q={$q}&amp;start={$start_var - $rows}">
								<xsl:value-of select="$start_var div $rows"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>

				<span class="pagingBtn">
					<b>
						<xsl:value-of select="$current"/>
					</b>
				</span>

				<!-- next two pages -->
				<xsl:if test="($start_var div $rows) + 1 &lt; $total">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="?q={$q}&amp;start={$start_var + $rows}&amp;sort={$sort}">
								<xsl:value-of select="($start_var div $rows) +2"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="?q={$q}&amp;start={$start_var + $rows}">
								<xsl:value-of select="($start_var div $rows) +2"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>
				<xsl:if test="($start_var div $rows) + 2 &lt; $total">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="?q={$q}&amp;start={$start_var + ($rows * 2)}&amp;sort={$sort}">
								<xsl:value-of select="($start_var div $rows) +3"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="?q={$q}&amp;start={$start_var + ($rows * 2)}">
								<xsl:value-of select="($start_var div $rows) +3"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>
				<xsl:if test="$start_var div $rows &lt;= $total - 6">
					<span class="pagingSep">...</span>
				</xsl:if>

				<!-- last two pages -->
				<xsl:if test="$start_var div $rows &lt;= $total - 5">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="?q={$q}&amp;start={($total * $rows) - ($rows * 2)}&amp;sort={$sort}">
								<xsl:value-of select="$total - 1"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="?q={$q}&amp;start={($total * $rows) - ($rows * 2)}">
								<xsl:value-of select="$total - 1"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="$start_var div $rows &lt;= $total - 4">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="?q={$q}&amp;start={($total * $rows) - $rows}&amp;sort={$sort}">
								<xsl:value-of select="$total"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="?q={$q}&amp;start={($total * $rows) - $rows}">
								<xsl:value-of select="$total"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="$numFound - $start_var &gt; $rows">
						<xsl:choose>
							<xsl:when test="string($sort)">
								<a class="pagingBtn" href="?q={$q}&amp;start={$next}&amp;sort={$sort}">Next»</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="pagingBtn" href="?q={$q}&amp;start={$next}">Next»</a>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<span class="pagingSep">Next»</span>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>

	<!--<xsl:template name="sort">
		<xsl:variable name="sort_categories_string">
			<xsl:text>agency_facet,unitdate_display,genreform_facet,language_facet</xsl:text>
		</xsl:variable>
		<xsl:variable name="sort_categories" select="tokenize(normalize-space($sort_categories_string), ',')"/>

		<div class="sort_div">
			<form class="sortForm" action="{$display_path}results/">
				<select class="sortForm_categories">
					<option value="null">Select from list...</option>
					<xsl:for-each select="$sort_categories">
						<xsl:choose>
							<xsl:when test="contains($sort, .)">
								<option value="{.}" selected="selected">
									<xsl:value-of select="eaditor:normalize_fields(.)"/>
								</option>
							</xsl:when>
							<xsl:otherwise>
								<option value="{.}">
									<xsl:value-of select="eaditor:normalize_fields(.)"/>
								</option>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</select>
				<select class="sortForm_order">
					<xsl:choose>
						<xsl:when test="contains($sort, 'asc')">
							<option value="asc" selected="selected">Ascending</option>
						</xsl:when>
						<xsl:otherwise>
							<option value="asc">Ascending</option>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="contains($sort, 'desc')">
							<option value="desc" selected="selected">Descending</option>
						</xsl:when>
						<xsl:otherwise>
							<option value="desc">Descending</option>
						</xsl:otherwise>
					</xsl:choose>
				</select>
				<input type="hidden" name="q" value="{$q}"/>
				<input type="hidden" name="sort" value="" class="sort_param"/>
				<xsl:choose>
					<xsl:when test="string($sort)">
						<input id="sort_button" type="submit" value="Sort Results"/>
					</xsl:when>
					<xsl:otherwise>
						<input id="sort_button" type="submit" value="Sort Results"/>
					</xsl:otherwise>
				</xsl:choose>
			</form>
		</div>
	</xsl:template>-->

	<!-- ********************************** FUNCTIONS ************************************ -->
	<xsl:function name="eaditor:get_flickr_uri">
		<xsl:param name="photo_id"/>
		<xsl:value-of
			select="document(concat('http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&amp;api_key=', $flickr-api-key, '&amp;photo_id=', $photo_id, '&amp;format=rest'))/rsp/photo/urls/url[@type='photopage']"
		/>
	</xsl:function>
</xsl:stylesheet>
