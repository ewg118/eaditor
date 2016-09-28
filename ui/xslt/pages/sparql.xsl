<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../templates.xsl"/>

	<xsl:variable name="pipeline"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
	<xsl:variable name="path"/>
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path">
		<xsl:choose>
			<xsl:when test="/config/aggregator='true'">./</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="if (contains(/config/url, 'localhost')) then '../' else /config/url"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title><xsl:value-of select="/config/title"/>: SPARQL</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/codemirror.js"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/matchbrackets.js"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/sparql.js"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/sparql_functions.js"/>
				<link rel="stylesheet" href="{$include_path}ui/css/codemirror.css"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="body">
		<xsl:variable name="default-query"><![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX ecrm:	<http://erlangen-crm.org/current/>
PREFIX geo:	<http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX arch:	<http://purl.org/archival/vocab/arch#>
PREFIX oa:	<http://www.w3.org/ns/oa#>

SELECT * WHERE {
?s ?p ?o
} LIMIT 100]]></xsl:variable>

		<div class="container-fluid">
			<div class="row">
				<div class="col-md-12">
					<h1>SPARQL Query</h1>

					<form role="form" id="sparqlForm" action="{$display_path}query" method="GET" accept-charset="UTF-8">
						<textarea name="query" rows="20" class="form-control" id="code">
							<xsl:value-of select="$default-query"/>
						</textarea>
						<br/>
						<div class="form-group">
							<label for="output">Output</label>
							<select name="output" class="form-control">
								<option value="html">HTML</option>
								<option value="xml">SPARQL/XML</option>
								<option value="json">SPARQL/JSON</option>
								<option value="text">Text</option>
								<option value="csv">CSV</option>
							</select>
						</div>
						<button type="submit" class="btn btn-default">Submit</button>
					</form>
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
