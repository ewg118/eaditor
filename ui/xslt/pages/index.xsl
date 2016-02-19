<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:include href="../templates.xsl"/>

	<!-- pipeline variables -->
	<xsl:variable name="pipeline"/>
	<xsl:variable name="path"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'eaditor/'), '/')"/>
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path">
		<xsl:choose>
			<xsl:when test="/content/config/aggregator='true'"/>
			<xsl:otherwise>
				<xsl:value-of select="if (contains(/content/config/url, 'localhost')) then './' else /content/config/url"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/config/title"/>
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
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="index"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="index">
		<div class="jumbotron">
			<div class="container">
				<div class="row">
					<div class="col-md-12">
						<h1>
							<xsl:value-of select="/config/title"/>
						</h1>
						<p>
							<xsl:value-of select="/config/description"/>
						</p>
					</div>
				</div>
			</div>
		</div>
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-8">
					<xsl:copy-of select="/config/content/index/*"/>
				</div>
				<div class="col-md-4">
					<div class="highlight">
						<h3>Export Options</h3>
						<a href="feed/?q=*:*" style="margin:5px">
							<img src="{$include_path}ui/images/atom-large.png" title="Atom" alt="Atom"/>
						</a>
						<xsl:if test="/config/export/oai-pmh='true'">
							<a href="oai/?verb=ListRecords&amp;metadataPrefix=oai_dc&amp;set=ead" style="margin:5px">
								<img src="{$include_path}ui/images/oai-pmh.png" title="OAI-PMH" alt="OAI-PMH"/>
							</a>
						</xsl:if>
						<xsl:if test="/config/export/pelagios='true'">
							<a href="pelagios.void.rdf" style="margin:5px">
								<img src="{$include_path}ui/images/pelagios_icon.png" title="Pelagios" alt="Pelagios"/>
							</a>
						</xsl:if>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
