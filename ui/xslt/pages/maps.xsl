<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eaditor="https://github.com/ewg118/eaditor" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	
	<xsl:variable name="display_path">./</xsl:variable>
	
	<xsl:variable name="include_path">
		<xsl:choose>
			<xsl:when test="/content/config/aggregator='true'">./</xsl:when>
			<xsl:otherwise>../</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="pipeline">maps</xsl:variable>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'eaditor/'), '/')"/>

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
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>
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
					<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
					<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/maps_functions.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/facet_functions.js"/>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="content"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="content">
		<div id="backgroundPopup"/>
		<div class="container-fluid">
			<xsl:choose>
				<xsl:when test="/content//result[@name='response']/@numFound &gt; 0">
					<div class="row">
						<div class="col-md-12">
							<h1>Maps</h1>
							<p>View maps in <a href="maps/fullscreen">fullscreen</a>.</p>
						</div>
					</div>
					<div class="row">
						<div class="col-md-3">
							<xsl:apply-templates select="//lst[@name='facet_fields']/lst[descendant::int]"/>
						</div>
						<div class="col-md-9">
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

				<button class="ui-multiselect ui-widget ui-state-default ui-corner-all hierarchical-facet" type="button" title="{$title}" aria-haspopup="true" style="width: 200px;" id="{@name}_link"
					label="{$q}">
					<span class="ui-icon ui-icon-triangle-2-n-s"/>
					<span>
						<xsl:value-of select="$title"/>
					</span>
				</button>

				<div class="ui-multiselect-menu ui-widget ui-widget-content ui-corner-all hierarchical-div" id="{substring-before(@name, '_hier')}-container" style="width: 200px;">
					<div class="ui-widget-header ui-corner-all ui-multiselect-header ui-helper-clearfix ui-multiselect-hasfilter">
						<ul class="ui-helper-reset">
							<li class="ui-multiselect-close">
								<a class="ui-multiselect-close hier-close" href="#"> close<span class="ui-icon ui-icon-circle-close"/>
								</a>
							</li>
						</ul>
					</div>
					<ul class="{substring-before(@name, '_hier')}-multiselect-checkboxes ui-helper-reset hierarchical-list" id="{@name}-list" style="height: 195px;" title="{$title}"/>
				</div>-->
			</xsl:when>
			<xsl:when test="@name='century_num'">
				<!--<div class="btn-group"> </div>
				<button class="dropdown-toggle btn btn-default" data-toggle="dropdown" type="button" title="Date" aria-haspopup="true" style="width: 250px;" id="{@name}_link" label="{$q}"> Date <b
						class="caret"/>
				</button>
				<ul class="dropdown-menu" style="max-height: 250px; width:250px; overflow-y: auto; overflow-x: hidden;">
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
							<ul id="century_{@name}_list" class="decades-list" style="{if(contains($q, concat(':',@name))) then '' else 'display:none'}"/>
						</li>
					</xsl:for-each>
				</ul>-->
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
				<select id="{@name}-select" multiple="multiple" class="multiselect" title="{$title}" q="{$q}" new_query="{if (contains($q, @name)) then $select_new_query else ''}"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
</xsl:stylesheet>
