<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output doctype-public="-//W3C//DTD HTML 4.01//EN" method="html" encoding="UTF-8"/>
	<xsl:include href="templates.xsl"/>
	<xsl:variable name="exist-url" select="/exist-url"/>
	<xsl:variable name="config" as="node()*">
		<xsl:copy-of select="document(concat($exist-url, 'eaditor/config.xml'))"/>
	</xsl:variable>
	<xsl:variable name="ui-theme" select="$config/config/theme/jquery_ui_theme"/>
	<xsl:variable name="display_path">../</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="$config/config/title"/>
					<xsl:text>: Search</xsl:text>
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
				
				<script type="text/javascript" src="{$display_path}ui/javascript/jquery.livequery.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/search.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/toggle_search_options.js"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<div class="yui3-g">
					<div class="yui3-u-1">
						<div class="content">
							<h1>Search</h1>
							<p>Use the drop down menu below for keyword or particular field searches.</p>
							<xsl:call-template name="search_forms"/>
							<select style="display:none" id="ajax-temp"/>
						</div>
					</div>
				</div>
				<xsl:call-template name="footer"/>
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
				<input type="submit" value="Search" id="search_button"/>
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
