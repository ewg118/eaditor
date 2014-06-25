<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eaditor="https://github.com/ewg118/eaditor" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="facets">
		<xsl:for-each select="tokenize(/content/config/theme/facets, ',')">
			<xsl:text>&amp;facet.field=</xsl:text>
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'results/'))"/>
	<xsl:variable name="solr-url" select="concat(/content/config/solr_published, 'select/')"/>
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="include_path">../../</xsl:variable>
	<xsl:variable name="pipeline">results</xsl:variable>

	<!-- URL parameters -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:param name="sort">
		<xsl:if test="string(doc('input:request')/request/parameters/parameter[name='sort']/value)">
			<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
		</xsl:if>
	</xsl:param>
	<xsl:param name="rows">10</xsl:param>
	<xsl:param name="start">
		<xsl:choose>
			<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='start']/value)">
				<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>

	<xsl:variable name="path"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'eaditor/'), '/')"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: Search Results</xsl:text>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>

				<script type="text/javascript" src="{$include_path}ui/javascript/result_functions.js"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/get_facets.js"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/facet_functions.js"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/bootstrap-multiselect.js"/>
				<link rel="stylesheet" href="{$include_path}ui/css/bootstrap-multiselect.css" type="text/css"/>
				<link rel="stylesheet" href="{$include_path}ui/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="results"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>


	</xsl:template>

	<xsl:template name="results">
		<xsl:apply-templates select="/content/response"/>
	</xsl:template>

	<xsl:template match="response">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-3">
					<xsl:if test="//result[@name='response']/@numFound &gt; 0">
						<div class="data_options">
							<h3>Data Options</h3>
							<a href="{$display_path}feed/?q={if (string($q)) then $q else '*:*'}">
								<img alt="Atom" title="Atom" src="{$include_path}ui/images/atom-medium.png"/>
							</a>
							<xsl:if test="count(//lst[@name='georef']/int) &gt; 0">
								<a href="{$display_path}query.kml?q={if (string($q)) then $q else '*:*'}">
									<img src="{$include_path}ui/images/googleearth.png" alt="KML" title="KML: Limit, 500 objects"/>
								</a>
							</xsl:if>
						</div>
						<h3>Refine Results</h3>
						<xsl:call-template name="quick_search"/>
						<xsl:apply-templates select="descendant::lst[@name='facet_fields']"/>
					</xsl:if>
				</div>
				<div class="col-md-9">
					<!--<xsl:if test="count(//lst[@name='georef']/int) &gt; 0">
						<div style="display:none">
							<div id="resultMap"/>
						</div>
					</xsl:if>-->
					<xsl:call-template name="remove_facets"/>
					<xsl:choose>
						<xsl:when test="//result[@name='response']/@numFound &gt; 0">
							<xsl:call-template name="paging"/>
							<xsl:call-template name="sort"/>
							<table class="table table-striped">
								<xsl:apply-templates select="descendant::doc"/>
							</table>
							<xsl:call-template name="paging"/>
						</xsl:when>
						<xsl:otherwise>
							<h2> No results found. <a href="{$display_path}results/?q=*:*">Start over.</a></h2>
						</xsl:otherwise>
					</xsl:choose>
					<span style="display:none" id="pipeline">
						<xsl:value-of select="$pipeline"/>
					</span>
					<select style="display:none" id="ajax-temp"/>
					<ul style="display:none" id="decades-temp"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="sort_category" select="substring-before($sort, ' ')"/>
		<xsl:variable name="regularized_sort">
			<xsl:value-of select="eaditor:normalize_fields($sort_category, $lang)"/>
		</xsl:variable>

		<tr>
			<td>
				<dl class="dl-horizontal">
					<dt>
						<xsl:value-of select="eaditor:normalize_fields('title', $lang)"/>
					</dt>
					<dd>
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
						<a href="{$objectUri}">
							<xsl:value-of select="str[@name='unittitle_display']"/>
						</a>
					</dd>
					<xsl:if test="string(str[@name='unitdate_display'])">
						<dt>
							<xsl:value-of select="eaditor:normalize_fields('date', $lang)"/>
						</dt>
						<dd>
							<xsl:value-of select="str[@name='unitdate_display']"/>
						</dd>
					</xsl:if>
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
					<!-- hierarchy -->
					<xsl:if test="count(arr[@name='dsc_hier']/str) &gt; 0">
						<xsl:variable name="ark" select="//config/ark/@enabled" as="xs:boolean"/>
						<xsl:variable name="naan" select="normalize-space(//config/ark/naan)"/>
						<dt>Organization</dt>
						<dd>
							<xsl:for-each select="arr[@name='dsc_hier']/str">
								<xsl:variable name="pieces" select="tokenize(., '\|')"/>
								<xsl:choose>
									<xsl:when test="$ark = true()">
										<a href="{$display_path}ark:/{$naan}/{$pieces[2]}">
											<xsl:value-of select="$pieces[3]"/>
											<xsl:text>: </xsl:text>
											<xsl:value-of select="$pieces[4]"/>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<a href="{$display_path}id/{$pieces[2]}">
											<xsl:value-of select="$pieces[3]"/>
											<xsl:text>: </xsl:text>
											<xsl:value-of select="$pieces[4]"/>
										</a>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="not(position()=last())">
									<xsl:text> | </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</dd>
					</xsl:if>
				</dl>
			</td>
			<td class="col-md-4">
				<xsl:if test="count(arr[@name='collection_thumb']/str) &gt; 0">
					<div style="float:right">
						<xsl:apply-templates select="arr[@name='collection_thumb']/str"/>
					</div>
				</xsl:if>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="arr[@name='collection_thumb']/str">
		<xsl:variable name="title" select="ancestor::doc/str[@name='unittitle_display']"/>
		<div class="thumbImage">
			<xsl:choose>
				<xsl:when test="contains(., 'flickr.com')">
					<xsl:variable name="photo_id" select="substring-before(tokenize(., '/')[last()], '_')"/>
					<xsl:variable name="flickr_uri" select="ancestor::doc/arr[@name='flickr_uri']/str[1]"/>		
					
					<a href="#{generate-id()}" title="{$title}">
						<img class="ci" src="{.}"/>
					</a>					
					<div style="display:none">
						<div id="{generate-id()}">
							<span href="{$flickr_uri}" class="flickr-link">
								<img src="{ancestor::doc/arr[@name='collection_reference']/str[contains(., $photo_id)]}"/>
							</span>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="position" select="position()"/>
					<xsl:choose>
						<xsl:when test="ancestor::doc/arr[@name='collection_reference']/str[position()=$position]">
							<a href="{ancestor::doc/arr[@name='collection_reference']/str[position()=$position]}" title="{$title}">
								<img src="{.}" alt="thumb"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<img src="{.}" alt="thumb"/>
						</xsl:otherwise>
					</xsl:choose>					
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template name="paging">
		<xsl:variable name="start_var" as="xs:integer">
			<xsl:choose>
				<xsl:when test="string($start)">
					<xsl:value-of select="$start"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
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

		<xsl:variable name="current" select="$start_var div $rows + 1"/>
		<xsl:variable name="total" select="ceiling($numFound div $rows)"/>

		<div class="paging_div row">
			<div class="col-md-6">
				<xsl:variable name="startRecord" select="$start_var + 1"/>
				<xsl:variable name="endRecord">
					<xsl:choose>
						<xsl:when test="$numFound &gt; ($start_var + $rows)">
							<xsl:value-of select="$start_var + $rows"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$numFound"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<span>
					<b>
						<xsl:value-of select="$startRecord"/>
					</b>
					<xsl:text> to </xsl:text>
					<b>
						<xsl:value-of select="$endRecord"/>
					</b>
					<text> of </text>
					<b>
						<xsl:value-of select="$numFound"/>
					</b>
					<xsl:text> total results.</xsl:text>
				</span>
			</div>

			<!-- paging functionality -->
			<div class="col-md-6 page-nos">
				<div class="btn-toolbar" role="toolbar">
					<div class="btn-group" style="float:right">
						<xsl:choose>
							<xsl:when test="$start_var &gt;= $rows">
								<a class="btn btn-default" title="First" href="./?q={encode-for-uri($q)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default" title="Previous" href="./?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="First" href="./?q={encode-for-uri($q)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default disabled" title="Previous" href="./?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
						<!-- current page -->
						<button type="button" class="btn btn-default disabled">
							<b>
								<xsl:value-of select="$current"/>
							</b>
						</button>
						<!-- next page -->
						<xsl:choose>
							<xsl:when test="$numFound - $start_var &gt; $rows">
								<a class="btn btn-default" title="Next" href="./?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default" href="./?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="Next" href="./?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default disabled" href="./?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="sort">
		<xsl:variable name="sort_categories_string">
			<xsl:text>agency,genreform,language,timestamp,unittitle_display,year_num</xsl:text>
		</xsl:variable>
		<xsl:variable name="sort_categories" select="tokenize(normalize-space($sort_categories_string), ',')"/>

		<div class="sort_div">
			<form role="form" class="sortForm" action="." method="GET">
				<select class="sortForm_categories form-control">
					<option>Select from list...</option>
					<xsl:for-each select="$sort_categories">
						<xsl:choose>
							<xsl:when test="contains($sort, .)">
								<option value="{.}" selected="selected">
									<xsl:value-of select="eaditor:normalize_fields(., $lang)"/>
								</option>
							</xsl:when>
							<xsl:otherwise>
								<option value="{.}">
									<xsl:value-of select="eaditor:normalize_fields(., $lang)"/>
								</option>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</select>
				<select class="sortForm_order form-control">
					<xsl:choose>
						<xsl:when test="contains(substring-after($sort, ' '), 'asc')">
							<option value="asc" selected="selected">Ascending</option>
						</xsl:when>
						<xsl:otherwise>
							<option value="asc">Ascending</option>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="contains(substring-after($sort, ' '), 'desc')">
							<option value="desc" selected="selected">Descending</option>
						</xsl:when>
						<xsl:otherwise>
							<option value="desc">Descending</option>
						</xsl:otherwise>
					</xsl:choose>
				</select>
				<xsl:if test="string($lang)">
					<input type="hidden" name="lang" value="{$lang}"/>
				</xsl:if>
				<input type="hidden" name="q" value="{if (string($q)) then $q else '*:*'}"/>
				<input type="hidden" name="sort" value="" class="sort_param"/>
				<xsl:choose>
					<xsl:when test="string($sort)">
						<input id="sort_button" type="submit" value="Sort Results" class="btn btn-default"/>
					</xsl:when>
					<xsl:otherwise>
						<input id="sort_button" type="submit" value="Sort Results" class="btn btn-default"/>
					</xsl:otherwise>
				</xsl:choose>
			</form>
		</div>
	</xsl:template>

	<xsl:template name="quick_search">
		<div class="quick_search">
			<form role="form" action="." method="GET" id="qs_form">
				<input type="hidden" name="q" id="qs_query" value="{$q}"/>
				<xsl:if test="string($lang)">
					<input type="hidden" name="lang" value="{$lang}"/>
				</xsl:if>
				<input type="text" class="form-control" id="qs_text" placeholder="Search"/>
				<button class="btn btn-default" type="submit">
					<i class="glyphicon glyphicon-search"/>
				</button>
			</form>
		</div>
	</xsl:template>

	<xsl:template match="lst[@name='facet_fields']">
		<xsl:for-each select="lst[not(@name='georef')][descendant::int]">
			<xsl:variable name="val" select="@name"/>
			<xsl:variable name="new_query">
				<xsl:for-each select="$tokenized_q[not(contains(., $val))]">
					<xsl:value-of select="."/>
					<xsl:if test="position() != last()">
						<xsl:text> AND </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="title">
				<xsl:value-of select="eaditor:normalize_fields(@name, $lang)"/>
			</xsl:variable>
			<xsl:variable name="select_new_query">
				<xsl:choose>
					<xsl:when test="string($new_query)">
						<xsl:value-of select="$new_query"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>*:*</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="@name='century_num'">
					<!--<button class="ui-multiselect ui-widget ui-state-default ui-corner-all" type="button" title="Date" aria-haspopup="true"
						style="width: 180px;" id="{@name}_link" label="{$q}">
						<span class="ui-icon ui-icon-triangle-2-n-s"/>
						<span>Date</span>
					</button>
					<div class="ui-multiselect-menu ui-widget ui-widget-content ui-corner-all date-div" style="width: 175px;">
						<div class="ui-widget-header ui-corner-all ui-multiselect-header ui-helper-clearfix ui-multiselect-hasfilter">
							<ul class="ui-helper-reset">
								<li class="ui-multiselect-close">
									<a class="ui-multiselect-close century-close" href="#">
										<span class="ui-icon ui-icon-circle-close"/>
									</a>
								</li>
							</ul>
						</div>
						<ul class="century-multiselect-checkboxes ui-helper-reset" id="{@name}-list" style="height: 175px;">
							<xsl:for-each select="int">
								<li>
									<span class="expand_century" century="{@name}" q="{$q}">
										<img src="{$include_path}ui/images/{if (contains($q, concat(':', @name))) then 'minus' else 'plus'}.gif" alt="expand"/>
									</span>
									<xsl:choose>
										<xsl:when test="contains($q, concat(':',@name))">
											<input type="checkbox" value="{@name}" checked="checked" class="century_checkbox"/>
										</xsl:when>
										<xsl:otherwise>
											<input type="checkbox" value="{@name}" class="century_checkbox"/>
										</xsl:otherwise>
									</xsl:choose>
									<!-\- output for 1800s, 1900s, etc. -\->
									<xsl:value-of select="eaditor:normalize_century(@name)"/>
									<ul id="century_{@name}_list" class="decades-list" style="{if(contains($q, concat(':',@name))) then '' else 'display:none'}">
										<!-\-<xsl:if test="contains($q, concat(':',@name))">
											<xsl:copy-of
												select="document(concat($request-uri, 'get_decades/?q=', encode-for-uri($q), '&amp;century=', @name, '&amp;pipeline=', $pipeline))//li"
											/>
										</xsl:if>-\->
									</ul>
								</li>
							</xsl:for-each>
						</ul>
					</div>-->
				</xsl:when>
				<xsl:otherwise>
					<select id="{@name}-select" title="{$title}" q="{$q}" new_query="{if (contains($q, @name)) then $select_new_query else ''}" class="multiselect" multiple="multiple">
						<xsl:if test="contains($q, @name)">
							<xsl:copy-of
								select="document(concat($request-uri, 'get_facets/?q=', encode-for-uri($q), '&amp;category=', @name, '&amp;sort=index&amp;limit=-1&amp;pipeline=', $pipeline))//option"
							/>
						</xsl:if>
					</select>
				</xsl:otherwise>
			</xsl:choose>
			<br/>
		</xsl:for-each>
		<form method="GET" action="./" id="facet_form">
			<input type="hidden" name="q" id="facet_form_query" value="{if (string($q)) then $q else '*:*'}"/>
			<br/>
			<div class="submit_div">
				<input type="submit" value="Refine Search" id="search_button" class="btn btn-default"/>
			</div>
		</form>
	</xsl:template>

	<xsl:template name="remove_facets">
		<div class="remove_facets">
			<xsl:choose>
				<xsl:when test="$q = '*:*'">
					<h1>All Terms <!--<xsl:if test="count(//lst[@name='georef']/int) &gt; 0">
							<a href="#resultMap" id="map_results">Map Results</a>
						</xsl:if>-->
					</h1>
				</xsl:when>
				<xsl:otherwise>
					<h1>Filters <!--<xsl:if test="count(//lst[@name='georef']/int) &gt; 0">
							<a href="#resultMap" id="map_results">Map Results</a>
						</xsl:if>-->
					</h1>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:for-each select="$tokenized_q">
				<xsl:variable name="val" select="."/>
				<xsl:variable name="new_query">
					<xsl:for-each select="$tokenized_q[not($val = .)]">
						<xsl:value-of select="."/>
						<xsl:if test="position() != last()">
							<xsl:text> AND </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<!--<xsl:value-of select="."/>-->
				<xsl:choose>
					<xsl:when test="not(. = '*:*') and not(substring(., 1, 1) = '(')">
						<xsl:variable name="field" select="substring-before(., ':')"/>
						<xsl:variable name="name">
							<xsl:choose>
								<xsl:when test="string($field)">
									<xsl:value-of select="eaditor:normalize_fields($field, $lang)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="eaditor:normalize_fields($field, $lang)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="term">
							<xsl:choose>
								<xsl:when test="string(substring-before(., ':'))">
									<xsl:value-of select="replace(substring-after(., ':'), '&#x022;', '')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="replace(., '&#x022;', '')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<div class="stacked_term bg-info row">
							<!-- establish orientation based on language parameter -->
							<div class="col-md-10">
								<span>
									<b><xsl:value-of select="$name"/>: </b>
									<xsl:choose>
										<xsl:when test="$field='century_num'">
											<!--<xsl:value-of select="numishare:normalize_century($term)"/>-->
										</xsl:when>
										<xsl:when test="contains($field, '_hier')">
											<xsl:variable name="tokens" select="tokenize(substring($term, 2, string-length($term)-2), '\+')"/>
											<xsl:for-each select="$tokens[position() &gt; 1]">
												<xsl:sort/>
												<xsl:value-of select="normalize-space(substring-after(., '|'))"/>
												<xsl:if test="not(position()=last())">
													<xsl:text>--</xsl:text>
												</xsl:if>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$term"/>
										</xsl:otherwise>
									</xsl:choose>
								</span>
							</div>
							<div class="col-md-2 right">
								<a href="{$display_path}results/?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
									<span class="glyphicon glyphicon-remove"/>
								</a>
							</div>
						</div>

					</xsl:when>
					<!-- if the token contains a parenthisis, then it was probably sent from the search widget and the token must be broken down further to remove other facets -->
					<xsl:when test="substring(., 1, 1) = '('">
						<xsl:variable name="tokenized-fragments" select="tokenize(., ' OR ')"/>

						<div class="stacked_term bg-info row">
							<div class="col-md-10">
								<span>
									<xsl:for-each select="$tokenized-fragments">
										<xsl:variable name="field" select="substring-before(translate(., '()', ''), ':')"/>
										<xsl:variable name="after-colon" select="substring-after(., ':')"/>

										<xsl:variable name="value">
											<xsl:choose>
												<xsl:when test="substring($after-colon, 1, 1) = '&#x022;'">
													<xsl:analyze-string select="$after-colon" regex="&#x022;([^&#x022;]+)&#x022;">
														<xsl:matching-substring>
															<xsl:value-of select="concat('&#x022;', regex-group(1), '&#x022;')"/>
														</xsl:matching-substring>
													</xsl:analyze-string>
												</xsl:when>
												<xsl:when test="substring($after-colon, 1, 1) = '('">
													<xsl:analyze-string select="$after-colon" regex="\(([^\)]+)\)">
														<xsl:matching-substring>
															<xsl:value-of select="concat('(', regex-group(1), ')')"/>
														</xsl:matching-substring>
													</xsl:analyze-string>
												</xsl:when>
												<xsl:otherwise>
													<xsl:analyze-string select="$after-colon" regex="([0-9]+)">
														<xsl:matching-substring>
															<xsl:value-of select="regex-group(1)"/>
														</xsl:matching-substring>
													</xsl:analyze-string>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>

										<xsl:variable name="q_string" select="concat($field, ':', $value)"/>

										<!--<xsl:variable name="value" select="."/>-->
										<xsl:variable name="new_multicategory">
											<xsl:for-each select="$tokenized-fragments[not(contains(.,$q_string))]">
												<xsl:variable name="other_field" select="substring-before(translate(., '()', ''), ':')"/>
												<xsl:variable name="after-colon" select="substring-after(., ':')"/>

												<xsl:variable name="other_value">
													<xsl:choose>
														<xsl:when test="substring($after-colon, 1, 1) = '&#x022;'">
															<xsl:analyze-string select="$after-colon" regex="&#x022;([^&#x022;]+)&#x022;">
																<xsl:matching-substring>
																	<xsl:value-of select="concat('&#x022;', regex-group(1), '&#x022;')"/>
																</xsl:matching-substring>
															</xsl:analyze-string>
														</xsl:when>
														<xsl:when test="substring($after-colon, 1, 1) = '('">
															<xsl:analyze-string select="$after-colon" regex="\(([^\)]+)\)">
																<xsl:matching-substring>
																	<xsl:value-of select="concat('(', regex-group(1), ')')"/>
																</xsl:matching-substring>
															</xsl:analyze-string>
														</xsl:when>
														<xsl:otherwise>
															<xsl:analyze-string select="$after-colon" regex="([0-9]+)">
																<xsl:matching-substring>
																	<xsl:value-of select="regex-group(1)"/>
																</xsl:matching-substring>
															</xsl:analyze-string>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:variable>
												<xsl:value-of select="concat($other_field, ':', encode-for-uri($other_value))"/>
												<xsl:if test="position() != last()">
													<xsl:text> OR </xsl:text>
												</xsl:if>
											</xsl:for-each>
										</xsl:variable>
										<xsl:variable name="multicategory_query">
											<xsl:choose>
												<xsl:when test="contains($new_multicategory, ' OR ')">
													<xsl:value-of select="concat('(', $new_multicategory, ')')"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$new_multicategory"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>


										<b>
											<xsl:value-of select="eaditor:normalize_fields($field, $lang)"/>
											<xsl:text>: </xsl:text>
										</b>

										<xsl:choose>
											<xsl:when test="$field='century_num'">
												<!--<xsl:value-of select="numishare:normalize_century($value)"/>-->
											</xsl:when>
											<xsl:when test="contains($field, '_hier')">
												<xsl:variable name="tokens" select="tokenize(substring($value, 2, string-length($value)-2), '\+')"/>
												<xsl:for-each select="$tokens[position() &gt; 1]">
													<xsl:sort/>
													<xsl:value-of select="normalize-space(replace(substring-after(., '|'), '&#x022;', ''))"/>
													<xsl:if test="not(position()=last())">
														<xsl:text>--</xsl:text>
													</xsl:if>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$value"/>
											</xsl:otherwise>
										</xsl:choose>

										<!-- concatenate the query with the multicategory removed with the new multicategory, or if the multicategory is empty, display just the $new_query -->
										<a
											href="{$display_path}results/?q={if (string($multicategory_query) and string($new_query)) then concat($new_query, ' AND ', $multicategory_query) else if (string($multicategory_query) and not(string($new_query))) then $multicategory_query else $new_query}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
											<span class="glyphicon glyphicon-remove"/>
										</a>

										<xsl:if test="position() != last()">
											<xsl:text> OR </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</span>
							</div>
							<div class="col-md-2 right">
								<a href="{$display_path}results/?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
									<span class="glyphicon glyphicon-remove"/>
								</a>
							</div>
						</div>
					</xsl:when>
					<xsl:when test="not(contains(., ':'))">
						<div class="stacked_term bg-info row">
							<div class="col-md-12">
								<span>
									<b>Keyword: </b>
									<xsl:value-of select="."/>
								</span>
							</div>
						</div>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			<!-- remove sort term -->
			<xsl:if test="string($sort)">
				<xsl:variable name="field" select="substring-before($sort, ' ')"/>
				<xsl:variable name="name">
					<xsl:value-of select="eaditor:normalize_fields($field, $lang)"/>
				</xsl:variable>

				<xsl:variable name="order">
					<xsl:choose>
						<xsl:when test="substring-after($sort, ' ') = 'asc'">Acending</xsl:when>
						<xsl:when test="substring-after($sort, ' ') = 'desc'">Descending</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<div class="stacked_term bg-info row">
					<div class="col-md-10">
						<span>
							<b>Sort Category: </b>
							<xsl:value-of select="$name"/>
							<xsl:text>, </xsl:text>
							<xsl:value-of select="$order"/>
						</span>
					</div>
					<div class="col-md-2">
						<a class="remove_filter" href="?q={$q}">
							<span class="glyphicon glyphicon-remove"/>
						</a>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="string($tokenized_q[2])">
				<div class="stacked_term bg-info row">
					<div class="col-md-12">
						<a id="clear_all" href="?q=*:*"><span class="glyphicon glyphicon-remove"/>Clear All Terms</a>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
</xsl:stylesheet>
