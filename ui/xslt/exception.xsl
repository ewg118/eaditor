<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="templates.xsl"/>
	
	<xsl:variable name="pipeline"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
	<xsl:variable name="path"/>
	<xsl:variable name="display_path"/>
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
				<title property="dcterms:title">
					<xsl:value-of select="/config/title"/>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>
				<link rel="stylesheet" href="{$include_path}ui/css/esln.css"/>
				<link rel="xeac:atom" type="application/atom+xml" href="{concat(/config/url, 'feed/')}"/>

				<xsl:if test="string(/config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="/config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
			<div id="page-wrap">
				<xsl:call-template name="index"/>
			</div>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="index">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-12">
					<h1>Error</h1>
					<xsl:apply-templates select="//exception"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="exception">
		<h2>
			<xsl:value-of select="type"/>
		</h2>
		<p>
			<xsl:value-of select="message"/>
		</p>
	</xsl:template>

</xsl:stylesheet>
