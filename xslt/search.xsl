<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml"  xmlns:exsl="http://exslt.org/common" xmlns="http://www.w3.org/1999/xhtml" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:include href="header-public.xsl"/>
	<xsl:include href="footer-public.xsl"/>
	<xsl:variable name="exist-url" select="/exist-url"/>
	<xsl:variable name="config" select="document(concat($exist-url, 'eaditor/config.xml'))"/>
	<xsl:variable name="ui-theme" select="exsl:node-set($config)/config/theme/jquery_ui_theme"/>
	<xsl:variable name="display_path">../</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="exsl:node-set($config)/config/title"/>
					<xsl:text>: Search</xsl:text>
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
				<link rel="stylesheet" href="{$display_path}css/ui.selectmenu.css"/>			
				
				<script type="text/javascript" src="{$display_path}javascript/jquery-1.4.2.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery-ui-1.8.12.custom.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery.livequery.js"/>
				<script type="text/javascript" src="{$display_path}javascript/ui.selectmenu.js"/>
				<script type="text/javascript" src="{$display_path}javascript/search.js"/>
				<script type="text/javascript" src="{$display_path}javascript/toggle_search_options.js"/>
				<script type="text/javascript" src="{$display_path}javascript/menu.js"/>
				<script type="text/javascript">
					$(function(){						
						$('#advancedSearchForm .searchItemTemplate select').selectmenu({'style':'dropdown', 'width':150});
					});
				</script>
			</head>
			<body class="yui-skin-sam">
				<div id="doc4" class="yui-t2">
					<!-- header -->
					<xsl:call-template name="header-public"/>

					<div id="bd">
						<h1>Search</h1>
						<p>Use the drop down menu below for keyword or particular field searches.</p>
						<xsl:call-template name="search_forms"/>
						<select style="display:none" id="ajax-temp"/>
					</div>

					<!-- footer -->
					<xsl:call-template name="footer-public"/>
				</div>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template name="search_options">
		<option value="fulltext" class="search_option" id="keyword_option">Keyword</option>		
		<option value="corpname_text" class="search_option" id="corpname_option">Corporate Name</option>
		<option value="famname_text" class="search_option" id="famname_option">Family Name</option>
		<option value="unitid_display" class="search_option" id="unitid_option">Finding Aid ID</option>
		<option value="genreform_facet" class="search_option" id="genreform_option">Genre/Format</option>
		<option value="geogname_text" class="search_option" id="geogname_option">Geographical Location</option>
		<option value="persname_text" class="search_option" id="persname_option">Personal Name</option>
		<option value="subject_text" class="search_option" id="subject_option">Subject</option>
	</xsl:template>
	
	<xsl:template name="search_forms">
		<div class="search-form">
			<form id="advancedSearchForm" method="GET" action="../results/">
				<div id="searchItemTemplate_1" class="searchItemTemplate">
					<select id="search_option_1" class="category_list">
						<xsl:call-template name="search_options"/>
					</select>
					<div style="display:inline;" class="option_container" id="container_1">
						<input type="text" id="search_text" class="search_text" style="display: inline;"/>
					</div>
					<a class="gateTypeBtn" href="#">add »</a>
					<a id="removeBtn_1" class="removeBtn" href="#">« remove</a>
				</div>				
				<br/>
				<br/>
				<br/>
				<input name="q" id="q_input" type="hidden"/>
				<input type="submit" value="Search" id="search_button" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only ui-state-focus"/>
			</form>
		</div>

		<div id="searchItemTemplate" class="searchItemTemplate">
			<select id="search_option" class="category_list">
				<xsl:call-template name="search_options"/>
			</select>
			<div style="display:inline;" class="option_container" id="container">
				<input type="text" id="search_text" class="search_text" style="display: inline;"/>
			</div>
			<a class="gateTypeBtn" href="#">add »</a>
			<a id="removeBtn_1" class="removeBtn" href="#">« remove</a>
		</div>
	</xsl:template>
</xsl:stylesheet>
