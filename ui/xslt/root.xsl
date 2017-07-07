<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:variable name="include_path">
		<xsl:choose>
			<xsl:when test="/config/aggregator='true'"/>
			<xsl:otherwise>../</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/collections">
		<html>
			<head>
				<title>EADitor</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet"
					href="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>
                                <link rel="stylesheet" href="{$include_path}ui/css/esln.css"/>
			</head>
			<body>
				<xsl:call-template name="content"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="content">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-12">
					<h2>EADitor</h2>
					<p>Please select one of the following collections:</p>
					<ul>
						<xsl:for-each select="collection">
							<li>
								<a href="{@name}/">
									<xsl:value-of select="@name"/>
								</a>
							</li>
						</xsl:for-each>
					</ul>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
