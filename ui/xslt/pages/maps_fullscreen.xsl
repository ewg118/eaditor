<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eaditor="https://github.com/ewg118/eaditor" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="mapboxKey" select="/content/config/mapboxKey"/>
	<!-- pipeline variables -->
	
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="include_path">
		<xsl:choose>
			<xsl:when test="/content/config/aggregator='true'">./</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="if (contains(/content/config/url, 'localhost')) then '../' else /content/config/url"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="pipeline">maps</xsl:variable>

	<xsl:param name="q" select="doc('input:params')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="lang" select="doc('input:params')/request/parameters/parameter[name='lang']/value"/>
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: Maps</xsl:text>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$include_path}ui/css/fullscreen.css"/>
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>

				<!-- map functions -->
				<xsl:if test="/content//result[@name='response']/@numFound &gt; 0">
					<script type="text/javascript" src="{$include_path}ui/javascript/bootstrap-multiselect.js"/>
					<link rel="stylesheet" href="{$include_path}ui/css/bootstrap-multiselect.css" type="text/css"/>
					<link rel="stylesheet" href="{$include_path}ui/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/jquery.fancybox.pack.js?v=2.1.5"/>

					<!-- maps -->
					<link rel="stylesheet" href="https://unpkg.com/leaflet@0.7.7/dist/leaflet.css"/>
					<link rel="stylesheet" href="{$include_path}ui/css/MarkerCluster.css"/>
					<link rel="stylesheet" href="{$include_path}ui/css/MarkerCluster.Default.css"/>
					
					<!-- js -->
					<script src="https://unpkg.com/leaflet@0.7.7/dist/leaflet.js"/>					
					<script type="text/javascript" src="{$include_path}ui/javascript/leaflet.ajax.min.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/leaflet.markercluster.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/maps_functions.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/facet_functions.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/map_fullscreen_functions.js"/>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="content"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="content">
		<div class="container-fluid" style="height:100%">
			<xsl:choose>
				<xsl:when test="/content//result[@name='response']/@numFound &gt; 0">
					<div id="legend">
						<h4>
							<a href="#map_filters" id="show_filters">Refine Results</a>
						</h4>
						<small>
							<a href="{$display_path}maps/"><span class="glyphicon glyphicon-arrow-left"/>Return</a>
						</small>
					</div>
					<div style="display:none">
						<div id="map_filters">
							<h2>Refine Results</h2>
							<xsl:apply-templates select="/content//lst[@name='facet_fields']/lst[descendant::int]"/>
							<input type="button" class="btn btn-default" id="close" value="Close"/>
						</div>
					</div>
					<div class="row" style="height:100%">
						<div class="col-md-12" style="height:100%">
							<div id="mapcontainer"/>
						</div>
					</div>
					<div class="row">
						<div class="col-md-12">
							<a name="results"/>
							<div id="results"/>
						</div>
					</div>
					<div style="display:none">
						<input id="facet_form_query" name="q" value="*:*" type="hidden"/>
						<xsl:if test="string($lang)">
							<input type="hidden" name="lang" value="{$lang}"/>
						</xsl:if>
						<span id="pipeline">
							<xsl:value-of select="$pipeline"/>
						</span>
						<span id="mapboxKey">
							<xsl:value-of select="$mapboxKey"/>
						</span>
						<span id="path">
							<xsl:value-of select="$display_path"/>
						</span>
						<select id="ajax-temp"/>
						<ul id="decades-temp"/>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="row">
						<div class="col-md-12">
							<h2> No results found.</h2>
						</div>
					</div>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template match="lst">

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
		<xsl:choose>
			<xsl:when test="contains(@name, '_hier')">
				<!--<xsl:variable name="title" select="eaditor:normalize_fields(@name, $lang)"/>

					<button class="ui-multiselect ui-widget ui-state-default ui-corner-all hierarchical-facet" type="button" title="{$title}" aria-haspopup="true"
						style="width: 200px;" id="{@name}_link" label="{$q}">
						<span class="ui-icon ui-icon-triangle-2-n-s"/>
						<span>
							<xsl:value-of select="$title"/>
						</span>
					</button>

					<div class="ui-multiselect-menu ui-widget ui-widget-content ui-corner-all hierarchical-div" id="{substring-before(@name, '_hier')}-container"
						style="width: 200px;">
						<div class="ui-widget-header ui-corner-all ui-multiselect-header ui-helper-clearfix ui-multiselect-hasfilter">
							<ul class="ui-helper-reset">
								<li class="ui-multiselect-close">
									<a class="ui-multiselect-close hier-close" href="#"> close<span class="ui-icon ui-icon-circle-close"/>
									</a>
								</li>
							</ul>
						</div>
						<ul class="{substring-before(@name, '_hier')}-multiselect-checkboxes ui-helper-reset hierarchical-list" id="{@name}-list" style="height: 195px;"
							title="{$title}"/>
					</div>-->
			</xsl:when>
			<xsl:when test="@name='century_num'">
				<!--<button class="ui-multiselect ui-widget ui-state-default ui-corner-all" type="button" title="Date" aria-haspopup="true" style="width: 200px;" id="{@name}_link"
						label="{$q}">
						<span class="ui-icon ui-icon-triangle-2-n-s"/>
						<span>Date</span>
					</button>
					<div class="ui-multiselect-menu ui-widget ui-widget-content ui-corner-all date-div" style="width: 200px;">
						<div class="ui-widget-header ui-corner-all ui-multiselect-header ui-helper-clearfix ui-multiselect-hasfilter">
							<ul class="ui-helper-reset">
								<li class="ui-multiselect-close">
									<a class="ui-multiselect-close century-close" href="#"> close<span class="ui-icon ui-icon-circle-close"/>
									</a>
								</li>
							</ul>
						</div>
						<ul class="century-multiselect-checkboxes ui-helper-reset" id="{@name}-list" style="height: 195px;"/>
					</div>-->
			</xsl:when>
			<xsl:otherwise>

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
				<div class="col-md-4">
					<select id="{@name}-select" multiple="multiple" class="multiselect" title="{$title}" q="{$q}" new_query="{if (contains($q, @name)) then $select_new_query else ''}"/>
				</div>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
</xsl:stylesheet>
