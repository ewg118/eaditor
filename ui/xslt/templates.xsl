<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:template name="header">
		<xsl:param name="recordId"/>
		<xsl:param name="manifestURI"/>
		
		<div class="navbar navbar-default navbar-static-top" role="navigation">
			<div class="container-fluid">
				<div class="navbar-header">
					<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
						<span class="sr-only">Toggle navigation</span>
						<span class="icon-bar"/>
						<span class="icon-bar"/>
						<span class="icon-bar"/>
					</button>
					<a class="navbar-brand" href="{$display_path}./">
						<xsl:value-of select="//config/title"/>
					</a>
				</div>
				<div class="navbar-collapse collapse">
					<ul class="nav navbar-nav">
						<li>
							<a href="{$display_path}results">Browse</a>
						</li>
						<li>
							<a href="{$display_path}search">Search</a>
						</li>
						<li>
							<a href="{$display_path}maps">Maps</a>
						</li>
						<xsl:if test="//config/sparql/endpoint = true()">
							<li>
								<a href="{$display_path}sparql">SPARQL</a>
							</li>
						</xsl:if>
					</ul>
					<xsl:if test="$pipeline = 'display'">
						<ul class="nav navbar-nav navbar-right">
							<xsl:if test="string($manifestURI)">
								<li>
									<a href="{$manifestURI}" title="IIIF Manifest">
										<img src="{$include_path}ui/images/logo-iiif-34x30.png" alt="IIIF Manifest" style="max-height:16px;"/>
										<xsl:text> Manifest</xsl:text>
									</a>
								</li>
							</xsl:if>
														
							<li>
								<a href="{$recordId}.xml">XML</a>
							</li>
							<li>
								<a href="{$recordId}.rdf">RDF/XML</a>
							</li>
							<xsl:if test="$collection-name != 'admin'">
								<li>
									<a
										href="{concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/eaditor/admin/', $collection-name, '/id/', $recordId)}"
										>Staff View</a>
								</li>
							</xsl:if>
						</ul>
					</xsl:if>
					<form class="navbar-form navbar-right" role="search" action="{$display_path}results" method="GET">
						<div class="input-group">
							<input type="text" class="form-control" placeholder="Search" name="q" id="srch-term"/>
							<div class="input-group-btn">
								<button class="btn btn-default" type="submit">
									<i class="glyphicon glyphicon-search"/>
								</button>
							</div>
						</div>
					</form>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="footer">
		<xsl:copy-of select="//config/content/footer/*"/>
	</xsl:template>

</xsl:stylesheet>
