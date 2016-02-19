<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output doctype-public="-//W3C//DTD HTML 4.01//EN" method="html" encoding="UTF-8"/>
	<xsl:include href="../templates.xsl"/>
	<!-- pipeline variables -->
	<xsl:variable name="pipeline"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'eaditor/'), '/')"/>
	<xsl:variable name="path"/>
	<xsl:variable name="display_path">./</xsl:variable>	
	<xsl:variable name="include_path">
		<xsl:choose>
			<xsl:when test="/content/config/aggregator='true'">./</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="if (contains(/content/config/url, 'localhost')) then '../' else /content/config/url"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/config/title"/>
					<xsl:text>: Search</xsl:text>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>
				<xsl:if test="string(/config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="/config/google_analytics"/>
					</script>
				</xsl:if>
				<script type="text/javascript" src="{$include_path}ui/javascript/search.js"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="content"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template name="content">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-8">
					<h1>Search</h1>
					<p>Use the drop down menu below for keyword or particular field searches.</p>
					<xsl:call-template name="search_forms"/>
					<select style="display:none" id="ajax-temp"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="search_options">
		<option value="text" class="search_option" id="keyword_option">Keyword</option>
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
			<form id="advancedSearchForm" method="GET" action="results">
				<div class="inputContainer">
					<div class="searchItemTemplate">
						<select id="search_option_1" class="category_list form-control">
							<xsl:call-template name="search_options"/>
						</select>
						<div style="display:inline;" class="option_container" id="container_1">
							<input type="text" id="search_text" class="search_text form-control" style="display: inline;"/>
						</div>
						<a class="gateTypeBtn" href="#">
							<span class="glyphicon glyphicon-plus"/>
						</a>
					</div>
				</div>
				<input name="q" id="q_input" type="hidden"/>
				<input type="submit" value="Search" id="search_button" class="btn btn-default"/>
			</form>
		</div>

		<div id="searchItemTemplate" class="searchItemTemplate">
			<select id="search_option" class="category_list form-control">
				<xsl:call-template name="search_options"/>
			</select>
			<div style="display:inline;" class="option_container" id="container">
				<input type="text" id="search_text" class="search_text form-control" style="display: inline;"/>
			</div>
			<a class="gateTypeBtn" href="#">
				<span class="glyphicon glyphicon-plus"/>
			</a>
			<a class="removeBtn" href="#" style="display:none;">
				<span class="glyphicon glyphicon-remove"/>
			</a>
		</div>
	</xsl:template>
</xsl:stylesheet>
