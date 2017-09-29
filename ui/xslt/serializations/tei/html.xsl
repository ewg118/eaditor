<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- path and document params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
	<xsl:variable name="pipeline">display</xsl:variable>
	<xsl:variable name="uri" select="doc('input:request')/request/request-url"/>
	<xsl:variable name="eadid" select="/content/tei:TEI/@xml:id"/>

	<!-- config variables -->
	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:variable name="objectUri">
		<xsl:choose>
			<xsl:when test="//config/ark[@enabled = 'true']">
				<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', $eadid)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($url, 'id/', $eadid)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- display path -->
	<xsl:variable name="display_path">
		<xsl:variable name="default">
			<xsl:choose>
				<xsl:when test="$mode = 'private'">
					<xsl:text>../../</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="contains($uri, 'ark:/')">
							<xsl:text>../../</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>../</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- after default path is set, replace ../ when it is an aggregate collection -->
		<xsl:choose>
			<xsl:when test="/content/config/aggregator = 'true'">
				<xsl:value-of select="concat($default, '../')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$default"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- check to see if the server port is 80, meaning Apache proxypass -->
	<xsl:variable name="include_path"
		select="
			if (doc('input:request')/request/server-port = '80') then
				$display_path
			else
				concat('../', $display_path)"/>

	<!-- url params -->
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:param name="mode">
		<xsl:choose>
			<xsl:when test="contains($uri, 'admin/')">private</xsl:when>
			<xsl:otherwise>public</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:variable name="mirador" as="xs:boolean" select="descendant::tei:media[@type = 'IIIFService'] and string(//config/mirador)"/>
	<xsl:variable name="manifestURI" select="concat($url, 'manifest/', $eadid)"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/tei:TEI"/>
	</xsl:template>

	<xsl:template match="tei:TEI">
		<html>
			<head
				prefix="dcterms: http://purl.org/dc/terms/     foaf: http://xmlns.com/foaf/0.1/     owl:  http://www.w3.org/2002/07/owl#     rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
				skos: http://www.w3.org/2004/02/skos/core#     dcterms: http://purl.org/dc/terms/     arch: http://purl.org/archival/vocab/arch#     xsd: http://www.w3.org/2001/XMLSchema#">
				<title id="{$eadid}">
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
				</title>
				<!-- alternates -->
				<meta charset="utf-8"/>
				<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
				<link rel="alternate" type="text/xml" href="{$objectUri}.xml"/>
				<link rel="alternate" type="application/rdf+xml" href="{$objectUri}.rdf"/>

				<meta name="viewport" content="width=device-width, initial-scale=1"/>

				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>

				<!-- if there are IIIF Services, then use mirador, otherwise render Annotorious -->
				<xsl:choose>
					<xsl:when test="$mirador = true()">
						<script type="text/javascript" src="{concat(//config/mirador, 'build/mirador/mirador.min.js')}"/>
						<link type="text/css" rel="stylesheet" href="{concat(//config/mirador, 'build/mirador/css/mirador-combined.css')}"/>

						<!-- mirador -->
						<script type="text/javascript" src="{$include_path}ui/javascript/display_mirador_functions.js"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- add annotorious for TEI files: must be added before jquery to resolve conflicts -->
						<link type="text/css" rel="stylesheet" href="http://annotorious.github.com/latest/annotorious.css"/>
						<script src="{$include_path}ui/javascript/OpenLayers.js" type="text/javascript"/>
						<script type="text/javascript" src="http://annotorious.github.com/latest/annotorious.min.js"/>

						<!-- include annotation functions for TEI files -->
						<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
						<script type="text/javascript" src="{$include_path}ui/javascript/display_annotation_functions.js"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<div class="container-fluid">
					<xsl:call-template name="tei-content"/>
				</div>
				<div id="path" style="display:none">../</div>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>
	<!-- ******************** TEI PAGE LAYOUT *********************** -->
	<xsl:template name="tei-content">
		<div class="row">
			<div class="col-md-12">
				<h1>
					<xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
				</h1>
				<h2>
					<xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/>
				</h2>
			</div>
		</div>
		<div class="row">
			<div class="col-md-4">
				<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
				<xsl:call-template name="index"/>
			</div>
			<div class="col-md-8">
				<xsl:call-template name="facsimiles"/>
			</div>
		</div>
		<xsl:if test="tei:text">
			<div class="row">
				<div class="col-md-12">
					<xsl:apply-templates select="tei:text"/>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- ******************** INDEX TEMPLATE *********************** -->
	<xsl:template name="index">
		<xsl:variable name="references" select="distinct-values(descendant::tei:ref)"/>
		<xsl:variable name="facs" as="element()*">
			<xsl:element name="facsimiles" namespace="http://www.tei-c.org/ns/1.0">
				<xsl:copy-of select="descendant::tei:facsimile"/>
			</xsl:element>
		</xsl:variable>

		<!-- get nomisma RDF -->
		<xsl:variable name="nomisma-rdf" as="element()*">
			<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
				xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">
				<xsl:variable name="id-param">
					<xsl:for-each select="distinct-values(descendant::tei:ref[contains(@target, 'nomisma.org')]/@target)">
						<xsl:value-of select="substring-after(., 'id/')"/>
						<xsl:if test="not(position() = last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
				<xsl:if test="string-length($id-param) &gt; 0">
					<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
				</xsl:if>
			</rdf:RDF>
		</xsl:variable>

		<xsl:variable name="viaf-rdf" as="element()*">
			<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
				xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">

				<xsl:for-each select="distinct-values(descendant::tei:ref[contains(@target, 'viaf.org')]/@target)">
					<xsl:variable name="pieces" select="tokenize(., '/')"/>
					<xsl:variable name="uri" select="concat('http://viaf.org/viaf/', $pieces[5])"/>
					<xsl:if test="doc-available(concat($uri, '/rdf'))">
						<xsl:copy-of select="document(concat($uri, '/rdf'))/descendant::*[@rdf:about = $uri]"/>
					</xsl:if>
				</xsl:for-each>
			</rdf:RDF>
		</xsl:variable>

		<xsl:if test="count($references) &gt; 0">
			<h3>Index</h3>
			<ul>
				<xsl:for-each select="$references">
					<xsl:sort/>
					<xsl:variable name="label" select="."/>
					<xsl:variable name="uri" select="$facs/descendant::tei:ref[. = $label][1]/@target"/>
					<xsl:variable name="facet">
						<xsl:choose>
							<xsl:when test="contains($uri, 'nomisma.org')">
								<xsl:variable name="type" select="$nomisma-rdf//*[@rdf:about = $uri]/name()"/>
								<xsl:choose>
									<xsl:when test="$type = 'nmo:Region' or $type = 'nmo:Mint'">geogname</xsl:when>
									<xsl:otherwise>subject</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="contains($uri, 'geonames.org')">geogname</xsl:when>
							<xsl:when test="contains($uri, 'viaf.org')">
								<xsl:choose>
									<xsl:when test="$viaf-rdf//*[@rdf:about = $uri]/rdf:type/@rdf:resource = 'http://xmlns.com/foaf/0.1/Organization'"
										>corpname</xsl:when>
									<xsl:when test="$viaf-rdf//*[@rdf:about = $uri]/rdf:type/@rdf:resource = 'http://xmlns.com/foaf/0.1/Person'"
										>persname</xsl:when>
								</xsl:choose>
							</xsl:when>
							<!-- wikipedia links cannot easily be parsed, ignore indexing -->
							<xsl:when test="contains($uri, 'wikipedia')"/>
							<!-- ignore ANS coins; not useful as subject terms -->
							<xsl:when test="contains($uri, 'numismatics.org/collection')"/>
							<xsl:otherwise>subject</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<li>
						<xsl:choose>
							<xsl:when test="string-length($facet) &gt; 0">
								<strong>
									<a href="{$display_path}results?q={$facet}_facet:&#x022;{$label}&#x022;">
										<xsl:value-of select="$label"/>
									</a>
									<a href="{$uri}" target="_blank">
										<span class="glyphicon glyphicon-new-window"/>
									</a>
								</strong>
							</xsl:when>
							<xsl:otherwise>
								<strong>
									<xsl:value-of select="$label"/>
									<a href="{$uri}" target="_blank">
										<span class="glyphicon glyphicon-new-window"/>
									</a>
								</strong>
							</xsl:otherwise>
						</xsl:choose>
						<p> Appears on: <xsl:for-each select="$facs//tei:facsimile[descendant::tei:ref[@target = $uri]]">
								<xsl:choose>
									<xsl:when test="$mirador = true()">
										<xsl:variable name="canvas" select="concat($url, 'manifest/', $eadid, '/canvas/', @xml:id)"/>
										<a href="#{@xml:id}" class="page-image" canvas="{$canvas}">
											<xsl:choose>
												<xsl:when test="string(tei:media/@n)">
													<xsl:value-of select="tei:media/@n"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="tei:media/@url"/>
												</xsl:otherwise>
											</xsl:choose>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<a href="{$include_path}ui/media/archive/{tei:graphic/@url}.jpg" class="page-image" facs="{@xml:id}">
											<xsl:choose>
												<xsl:when test="string(tei:graphic/@n)">
													<xsl:value-of select="tei:graphic/@n"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="tei:graphic/@url"/>
												</xsl:otherwise>
											</xsl:choose>
										</a>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="not(position() = last())">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</p>
					</li>
				</xsl:for-each>
			</ul>
		</xsl:if>
	</xsl:template>

	<!-- ******************** FACSIMILE TEMPLATES *********************** -->
	<xsl:template name="facsimiles">
		<xsl:choose>
			<xsl:when test="$mirador = true()">
				<!--<iframe title="Mirador" id="iiif-iframe" src="{//config/mirador}?manifest={$manifestURI}&amp;publisher={encode-for-uri(//config/publisher)}"
					allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" width="100%" height="800px"/>-->

				<div style="width:100%;height:800px" id="mirador-div"/>
			</xsl:when>
			<xsl:otherwise>
				<div>
					<xsl:call-template name="page-navigation"/>
					<div>
						<div id="annot"/>
					</div>
					<table id="slider">
						<tr>
							<td id="left-scroll">
								<span class="glyphicon glyphicon-arrow-left"/>
							</td>
							<td>
								<div id="slider-thumbs">
									<xsl:apply-templates select="tei:facsimile" mode="slider"/>
								</div>
							</td>
							<td id="right-scroll">
								<span class="glyphicon glyphicon-arrow-right"/>
							</td>
						</tr>
					</table>
				</div>
			</xsl:otherwise>
		</xsl:choose>

		<!-- controls -->
		<div class="hidden">
			<span id="display_path">
				<xsl:value-of select="$display_path"/>
			</span>
			<span id="doc">
				<xsl:value-of select="$eadid"/>
			</span>

			<xsl:choose>
				<xsl:when test="$mirador = true()">
					<span id="miradorURI">
						<xsl:value-of select="//config/mirador"/>
					</span>
					<span id="manifestURI">
						<xsl:value-of select="$manifestURI"/>
					</span>
					<span id="publisher">
						<xsl:value-of select="//config/publisher"/>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<span id="image-path">
						<xsl:value-of select="concat($include_path, 'ui/media/archive/', tei:facsimile[1]/tei:graphic/@url, '.jpg')"/>
					</span>
					<span id="image-id">
						<xsl:value-of select="tei:facsimile[1]/@xml:id"/>
					</span>
					<span id="first-page">
						<xsl:value-of select="tei:facsimile[1]/@xml:id"/>
					</span>
					<span id="last-page">
						<xsl:value-of select="tei:facsimile[last()]/@xml:id"/>
					</span>
					<span id="image-container"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template match="tei:facsimile" mode="slider">
		<a href="{$include_path}ui/media/archive/{tei:graphic/@url}.jpg" title="{tei:graphic/@n}" class="page-image" id="{@xml:id}">
			<img src="{$include_path}ui/media/thumbnail/{tei:graphic/@url}.jpg" alt="{tei:graphic/@n}">
				<xsl:if test="position() = 1">
					<xsl:attribute name="class">selected</xsl:attribute>
				</xsl:if>
			</img>
		</a>
	</xsl:template>

	<xsl:template name="page-navigation">
		<div class="highlight">
			<a href="#" id="prev-page" class="disabled"><span class="glyphicon glyphicon-arrow-left"/>Previous</a>
			<span id="goto-container">
				<xsl:text>Go to page: </xsl:text>
				<select id="goto-page" class="form-control">
					<xsl:for-each select="tei:facsimile">
						<option value="{@xml:id}">
							<xsl:choose>
								<xsl:when test="tei:graphic/@n">
									<xsl:value-of select="tei:graphic/@n"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="tei:graphic/@url"/>
								</xsl:otherwise>
							</xsl:choose>
						</option>
					</xsl:for-each>
				</select>
			</span>
			<a href="#" id="next-page">Next<span class="glyphicon glyphicon-arrow-right"/></a>
		</div>
	</xsl:template>

	<!-- ******************** TEI TEMPLATES *********************** -->
	<xsl:template match="tei:fileDesc">
		<xsl:apply-templates select="tei:publicationStmt"/>
		<xsl:apply-templates select="tei:notesStmt/tei:note[@type = 'abstract']"/>
	</xsl:template>

	<xsl:template match="tei:author">
		<xsl:value-of select="normalize-space(child::*)"/>
		<xsl:if test="child::*/@ref">
			<small>
				<a href="{child::*/@ref}">
					<span class="glyphicon glyphicon-new-window"/>
				</a>
			</small>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:publicationStmt">
		<div>
			<h3>Publication Statement</h3>
			<dl class="dl-horizontal">
				<xsl:if test="tei:publisher">
					<dt>Publisher</dt>
					<dd>
						<xsl:value-of select="tei:publisher"/>
					</dd>
				</xsl:if>
				<xsl:if test="tei:pubPlace">
					<dt>Publication Place</dt>
					<dd>
						<xsl:value-of select="tei:pubPlace"/>
					</dd>
				</xsl:if>
				<xsl:if test="tei:idno[@type = 'donum']">
					<dt>Donum</dt>
					<dd>
						<a href="http://numismatics.org/library/{tei:idno[@type='donum']}">
							<xsl:text>http://numismatics.org/library/</xsl:text>
							<xsl:value-of select="tei:idno[@type = 'donum']"/>
						</a>
					</dd>
				</xsl:if>
			</dl>
		</div>
	</xsl:template>

	<xsl:template match="tei:note[@type = 'abstract']">
		<div>
			<h3>Abstract</h3>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="tei:p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

</xsl:stylesheet>
