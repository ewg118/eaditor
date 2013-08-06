<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">	
	<xsl:include href="display/ead/ead.xsl"/>
	<xsl:include href="display/ead/dsc.xsl"/>
	<xsl:include href="display/mods/mods.xsl"/>
	<xsl:include href="templates.xsl"/>
	<xsl:include href="functions.xsl"/>

	<!-- config variables -->
	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="ui-theme" select="/content/config/theme/jquery_ui_theme"/>
	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="$mode='private'">
				<xsl:text>../../</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>../</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="id">
		<xsl:choose>
			<xsl:when test="//mods:recordIdentifier">
				<xsl:value-of select="//mods:recordIdentifier"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="//ead:ead/@id"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- url params -->
	<xsl:param name="lang" select="doc('input:params')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="mode">
		<xsl:choose>
			<xsl:when test="contains(doc('input:request')/request/request-url, 'admin/')">private</xsl:when>
			<xsl:otherwise>public</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/ead:ead|/content/mods:modsCollection/mods:mods"/>
	</xsl:template>

	<xsl:template match="ead:ead|mods:mods">
		<html>
			<head>
				<title>
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper"/>
				</title>
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
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:choose>
					<xsl:when test="namespace-uri()='http://www.loc.gov/mods/v3'">
						<xsl:call-template name="mods-content"/>
					</xsl:when>
					<xsl:when test="namespace-uri()='urn:isbn:1-931666-22-9'">
						<xsl:call-template name="ead-content"/>
					</xsl:when>
				</xsl:choose>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="icons">
		<div class="submenu">
			<div class="icon">
				<a href="{$display_path}admin/show/{$id}">Staff View</a>
			</div>
			<div class="icon">
				<a href="{$display_path}xml/{$id}">
					<img src="{$display_path}images/xml.png" title="XML" alt="XML"/>
				</a>
			</div>
			<div class="icon">
				<!-- addthis could go here -->
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
