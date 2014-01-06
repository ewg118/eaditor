<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:variable name="include_path"/>

	<xsl:template match="collections">
		<html>
			<head>
				<title>EADitor</title>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.8.0/build/cssgrids/grids-min.css"/>
				<!-- EADitor styling -->
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>
			</head>
			<body>
				<xsl:call-template name="content"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="content">
		<div class="yui3-g">
			<div class="yui3-u-1">
				<div class="content">
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
