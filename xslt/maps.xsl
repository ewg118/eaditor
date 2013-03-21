<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:include href="header-public.xsl"/>
	<xsl:include href="footer-public.xsl"/>
	<xsl:variable name="exist-url" select="/exist-url"/>
	<xsl:variable name="config" select="document(concat($exist-url, 'eaditor/config.xml'))"/>
	<xsl:variable name="flickr-api-key" select="exsl:node-set($config)/config/flickr_api_key"/>
	<xsl:variable name="solr-url" select="concat(exsl:node-set($config)/config/solr_published, 'select/')"/>
	<xsl:variable name="ui-theme" select="exsl:node-set($config)/config/theme/jquery_ui_theme"/>
	<xsl:variable name="display_path">../</xsl:variable>

	<!-- initial solr_query -->
	<xsl:variable name="service">
		<xsl:value-of select="concat($solr-url, '?q=georef:*&amp;start=0&amp;rows=0')"/>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="exsl:node-set($config)/config/title"/>
					<xsl:text>: Maps</xsl:text>
				</title>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/grids/grids-min.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/reset-fonts-grids/reset-fonts-grids.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/base/base-min.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/fonts/fonts-min.css"/>
				<!-- Core + Skin CSS -->
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/menu/assets/skins/sam/menu.css"/>

				<!-- EADitor styling -->
				<link rel="stylesheet" href="{$display_path}css/style.css"/>
				<link rel="stylesheet" href="{$display_path}css/themes/{$ui-theme}.css"/>

				<script type="text/javascript" src="{$display_path}javascript/jquery-1.4.2.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery-ui-1.8.12.custom.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery.livequery.js"/>
				<script type="text/javascript" src="{$display_path}javascript/menu.js"/>
				<!--<script type="text/javascript">
					$(document).ready(function(){
						$('a.thumbImage').livequery(function(){
							$(this).fancybox();
							});
					});
					</script>-->
				<xsl:if test="document($service)/response/result[@name='response']/@numFound &gt; 0">
					<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
					<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
					<script type="text/javascript" src="{$display_path}javascript/maps_get_facets.js"/>
					<script type="text/javascript" src="{$display_path}javascript/maps_functions.js"/>
				</xsl:if>
			</head>
			<body class="yui-skin-sam">
				<div id="backgroundPopup"/>
				<div id="doc4" class="yui-t2">
					<!-- header -->
					<xsl:call-template name="header-public"/>

					<div id="bd">
						<h1>Maps</h1>
						<div class="remove_facets"/>
						<xsl:choose>
							<xsl:when test="document($service)/response/result[@name='response']/@numFound &gt; 0">
								<div style="display:table;width:100%">
									<ul id="filter_list" section="maps"/>
								</div>
								<div id="basicMap"/>
								<a name="results"/>
								<div id="results"/>
								<div style="display:none" id="temp"/>
							</xsl:when>
							<xsl:otherwise>
								<h2> No results found. <a href="results?q=*:*">Start over.</a></h2>
							</xsl:otherwise>
						</xsl:choose>
						<input id="query" name="q" value="*:*" type="hidden"/>
					</div>

					<!-- footer -->
					<xsl:call-template name="footer-public"/>
				</div>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
