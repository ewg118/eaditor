<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="display/ead/ead.xsl"/>
	<xsl:include href="display/ead/dsc.xsl"/>
	<xsl:include href="display/mods/mods.xsl"/>
	<xsl:include href="templates.xsl"/>
	<xsl:include href="functions.xsl"/>

	<!-- path and document params -->
	<xsl:param name="path" select="substring-after(doc('input:request')/request/request-url, 'id/')"/>
	<xsl:variable name="doc">
		<xsl:choose>
			<xsl:when test="contains($path, '/')">
				<xsl:value-of select="tokenize($path, '/')[1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="contains($path, '.')">
						<xsl:variable name="pieces" select="tokenize($path, '\.')"/>

						<xsl:for-each select="$pieces[not(position()=last())]">
							<xsl:value-of select="."/>
							<xsl:if test="not(position()=last())">
								<xsl:text>.</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$path"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="id">
		<xsl:if test="contains($path, '/')">
			<xsl:variable name="last-piece" select="substring-after($path, '/')"/>
			<xsl:choose>
				<xsl:when test="contains($last-piece, '.')">
					<xsl:variable name="pieces" select="tokenize($last-piece, '\.')"/>
					<xsl:for-each select="$pieces[not(position()=last())]">
						<xsl:value-of select="."/>
						<xsl:if test="not(position()=last())">
							<xsl:text>.</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$last-piece"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:variable>

	<!-- config variables -->
	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="ui-theme" select="/content/config/theme/jquery_ui_theme"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<!-- display path -->
	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="$mode='private'">
				<xsl:choose>
					<xsl:when test="string($id)">
						<xsl:text>../../../</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>../../</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string($id)">
						<xsl:text>../../</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>../</xsl:text>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- boolean variable as to whether there are mappable points -->
	<xsl:variable name="hasPoints" select="boolean(descendant::ead:geogname[string(@authfilenumber) and string(@source)])"/>
	
	<!-- url params -->
	<xsl:param name="lang" select="doc('input:params')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="mode">
		<xsl:choose>
			<xsl:when test="contains(doc('input:request')/request/request-url, 'admin/')">private</xsl:when>
			<xsl:otherwise>public</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/*[not(local-name()='config')]"/>
	</xsl:template>

	<xsl:template match="ead:ead|mods:mods">
		<html xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#">
			<head>
				<title>
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper"/>
				</title>
				<!-- alternates -->
				<link rel="alternate" type="text/xml" href="{concat($url, 'id/', $path)}.xml"/>
				<link rel="alternate" type="application/rdf+xml" href="{concat($url, 'id/', $path)}.rdf"/>
				
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.8.0/build/cssgrids/grids-min.css"/>
				<!-- EADitor styling -->
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
				<link rel="stylesheet" href="{$display_path}ui/css/themes/{$ui-theme}.css"/>

				<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"/>
				<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/jquery-ui.min.js"/>

				<!-- menu -->
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.core.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.widget.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.position.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.button.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.menu.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.menubar.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/menu.js"/>

				<xsl:if test="$hasPoints = true()">
					<!-- mapping -->
					<link type="text/css" href="{$display_path}ui/css/timeline-2.3.0.css" rel="stylesheet"/>
					<script src="http://www.openlayers.org/api/OpenLayers.js" type="text/javascript"/>
					<!--<script src="http://maps.google.com/maps/api/js?sensor=false" type="text/javascript"/>-->
					<script type="text/javascript" src="{$display_path}ui/javascript/mxn.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/timeline-2.3.0.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/timemap_full.pack.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/param.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/loaders/xml.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/loaders/kml.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/display_functions.js"/>
				</xsl:if>
				<script type="text/javascript" langage="javascript">
					$(document).ready(function () {
						$("#tabs").tabs();
						<!--$(".thumbImage a").fancybox();
						$('.flickr-link').click(function () {
							var href = $(this).attr('href');
							$.fancybox.close();
							window.open(href, '_blank');
						});-->
					});
				</script>
				
				
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="icons"/>
				<xsl:choose>
					<xsl:when test="namespace-uri()='http://www.loc.gov/mods/v3'">
						<xsl:call-template name="mods-content"/>
					</xsl:when>
					<xsl:when test="namespace-uri()='urn:isbn:1-931666-22-9'">
						<xsl:call-template name="ead-content"/>
					</xsl:when>
				</xsl:choose>
				<div id="path" style="display:none">
					<xsl:value-of select="$path"/>
				</div>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="icons">
		<div class="submenu">
			<div class="icon">
				<a href="{$display_path}admin/id/{$doc}">Staff View</a>
			</div>
			<div class="icon">
				<a href="{$path}.xml">
					<img src="{$display_path}images/xml.png" title="XML" alt="XML"/>
				</a>
			</div>
			<div class="icon">
				<!-- addthis could go here -->
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
