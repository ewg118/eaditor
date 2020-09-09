<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- path and document params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
	<xsl:variable name="pipeline">display</xsl:variable>
	<xsl:variable name="uri" select="doc('input:request')/request/request-url"/>
	<xsl:variable name="recordId" select="/content/tei:TEI/@xml:id"/>

	<!-- config variables -->
	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:variable name="objectUri">
		<xsl:choose>
			<xsl:when test="//config/ark[@enabled = 'true']">
				<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', $recordId)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($url, 'id/', $recordId)"/>
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
	<xsl:variable name="manifestURI" select="concat($url, 'manifest/', $recordId)"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/tei:TEI"/>
	</xsl:template>

	<xsl:template match="tei:TEI">
		<html>
			<head
				prefix="dcterms: http://purl.org/dc/terms/     foaf: http://xmlns.com/foaf/0.1/     owl:  http://www.w3.org/2002/07/owl#     rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
				skos: http://www.w3.org/2004/02/skos/core#     dcterms: http://purl.org/dc/terms/     arch: http://purl.org/archival/vocab/arch#     xsd: http://www.w3.org/2001/XMLSchema#">
				<title id="{$recordId}">
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
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/display_functions.js"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>


				<!-- if there are IIIF Services, then use mirador, otherwise render Annotorious -->
				<xsl:choose>
					<xsl:when test="$mirador = true()">
						<script type="text/javascript" src="{concat(//config/mirador, 'build/mirador/mirador.min.js')}"/>
						<!--<link type="text/css" rel="stylesheet" href="{concat(//config/mirador, 'build/mirador/css/mirador-combined.css')}"/>-->

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
				<xsl:call-template name="header">
					<xsl:with-param name="manifestURI" select="$manifestURI"/>
					<xsl:with-param name="recordId" select="$recordId"/>
				</xsl:call-template>
				<div class="container-fluid">
					<xsl:call-template name="tei-content"/>
				</div>

				<!-- controls -->
				<div class="hidden">
					<span id="display_path">
						<xsl:value-of select="$display_path"/>
					</span>
					<span id="doc">
						<xsl:value-of select="$recordId"/>
					</span>
					<div id="path">../</div>
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
				<xsl:apply-templates select="tei:teiHeader"/>
			</div>
		</div>
		<div class="row">
			<div class="col-md-12">
				<xsl:call-template name="facsimiles"/>
			</div>
		</div>

		<div class="row">
			<div class="col-md-12">
				<xsl:call-template name="index"/>
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
		<xsl:variable name="terms" as="element()*">
			<xsl:element name="terms" namespace="http://www.tei-c.org/ns/1.0">
				<xsl:copy-of select="descendant::tei:term[@facs]"/>
			</xsl:element>
		</xsl:variable>

		<xsl:variable name="references" as="node()*">
			<references>
				<xsl:for-each select="tei:facsimile/descendant::tei:ref | descendant::tei:term[@facs]">
					<xsl:variable name="val" select="normalize-space(.)"/>

					<xsl:if test="not(preceding::node()/text() = $val)">
						<ref>
							<xsl:choose>
								<xsl:when test="@target">
									<xsl:attribute name="uri" select="@target"/>
								</xsl:when>
								<xsl:when test="@ref">
									<xsl:attribute name="uri" select="@ref"/>
								</xsl:when>
							</xsl:choose>

							<!-- create an XML element for each matching facsimile reference based on matching URI (subject term) 
								These are a sequence that will match below-->
							<xsl:if test="self::tei:term">
								<xsl:variable name="ref" select="@ref"/>

								<xsl:for-each select="$terms//tei:term[@ref = $ref]">
									<facs>
										<xsl:value-of select="substring-after(@facs, '#')"/>
									</facs>
								</xsl:for-each>
							</xsl:if>

							<label>
								<xsl:value-of select="."/>
							</label>
						</ref>
					</xsl:if>

				</xsl:for-each>
			</references>
		</xsl:variable>

		<xsl:variable name="facs" as="element()*">
			<xsl:element name="facsimiles" namespace="http://www.tei-c.org/ns/1.0">
				<xsl:copy-of select="descendant::tei:facsimile"/>
			</xsl:element>
		</xsl:variable>

		<!-- get nomisma RDF -->
		<xsl:variable name="rdf" as="element()*">
			<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
				xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">

				<!-- get nomisma RDF -->
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

				<!-- get viaf RDF -->
				<xsl:for-each select="distinct-values(descendant::tei:ref[contains(@target, 'viaf.org')]/@target)">
					<xsl:variable name="pieces" select="tokenize(., '/')"/>
					<xsl:variable name="uri" select="concat('http://viaf.org/viaf/', $pieces[5])"/>
					<xsl:if test="doc-available(concat($uri, '/rdf'))">
						<xsl:copy-of select="document(concat($uri, '/rdf'))/descendant::*[@rdf:about = $uri]"/>
					</xsl:if>
				</xsl:for-each>
			</rdf:RDF>
		</xsl:variable>

		<xsl:if test="count($references//ref) &gt; 0">
			<h3>Index</h3>
			<p>The index terms annotated in this document are arranged in the following categories. The numbers that appear in parentheses refer to the page
				number of the document.</p>

			<xsl:if test="$references//ref[contains(@uri, 'coinhoards.org')]">
				<div>
					<h4>Hoards <small>
							<a href="#" class="toggle-button" id="toggle-hoards" title="Click to hide or show the section">
								<span class="glyphicon glyphicon-triangle-bottom"/>
							</a>
						</small></h4>
					<div id="hoards">
						<ul>
							<xsl:apply-templates select="$references//ref[contains(@uri, 'coinhoards.org')]">
								<xsl:sort/>

								<xsl:with-param name="facs" select="$facs"/>
								<xsl:with-param name="rdf" select="$rdf"/>
							</xsl:apply-templates>
						</ul>
					</div>

				</div>
			</xsl:if>

			<xsl:if
				test="$references//ref[contains(@uri, 'numismatics.org/pella/id') or contains(@uri, 'numismatics.org/sco/id') or contains(@uri, 'numismatics.org/pco/id') or contains(@uri, 'numismatics.org/ocre/id') or contains(@uri, 'numismatics.org/crro/id')]">
				<div>
					<h4>Coin Types <small>
							<a href="#" class="toggle-button" id="toggle-types" title="Click to hide or show the section">
								<span class="glyphicon glyphicon-triangle-bottom"/>
							</a>
						</small></h4>
					<div id="types">
						<ul>
							<xsl:apply-templates
								select="$references//ref[contains(@uri, 'numismatics.org/pella/id') or contains(@uri, 'numismatics.org/sco/id') or contains(@uri, 'numismatics.org/pco/id') or contains(@uri, 'numismatics.org/ocre/id') or contains(@uri, 'numismatics.org/crro/id')]">
								<xsl:sort/>

								<xsl:with-param name="facs" select="$facs"/>
								<xsl:with-param name="rdf" select="$rdf"/>
							</xsl:apply-templates>
						</ul>
					</div>

				</div>
			</xsl:if>

			<xsl:if test="$references//ref[contains(@uri, '/symbol/')]">
				<div>
					<h4>Symbols and Monograms <small>
							<a href="#" class="toggle-button" id="toggle-library" title="Click to hide or show the section">
								<span class="glyphicon glyphicon-triangle-bottom"/>
							</a>
						</small></h4>
					<div id="library">
						<ul>
							<xsl:apply-templates select="$references//ref[contains(@uri, '/symbol/')]">
								<xsl:sort/>

								<xsl:with-param name="facs" select="$facs"/>
								<xsl:with-param name="rdf" select="$rdf"/>
							</xsl:apply-templates>
						</ul>
					</div>
				</div>
			</xsl:if>

			<xsl:if
				test="$references//ref[contains(@uri, 'nomisma.org/id') or contains(@uri, 'viaf.org') or contains(@uri, 'geonames.org') or contains(@uri, 'wikidata.org') or contains(@uri, 'numismatics.org/authority')]">
				<div>
					<h4>Subjects (People, Places, etc.) <small>
							<a href="#" class="toggle-button" id="toggle-subjects" title="Click to hide or show the section">
								<span class="glyphicon glyphicon-triangle-bottom"/>
							</a>
						</small></h4>
					<div id="subjects">
						<ul>
							<xsl:apply-templates
								select="$references//ref[contains(@uri, 'nomisma.org/id') or contains(@uri, 'viaf.org') or contains(@uri, 'geonames.org') or contains(@uri, 'wikidata.org') or contains(@uri, 'numismatics.org/authority')]">
								<xsl:sort/>

								<xsl:with-param name="facs" select="$facs"/>
								<xsl:with-param name="rdf" select="$rdf"/>
							</xsl:apply-templates>
						</ul>
					</div>

				</div>
			</xsl:if>

			<xsl:if
				test="$references//ref[contains(@uri, 'numismatics.org/library') or contains(@uri, 'numismatics.org/digitallibrary') or contains(@uri, 'numismatics.org/archives')]">
				<div>
					<h4>ANS Library and Archives <small>
							<a href="#" class="toggle-button" id="toggle-library" title="Click to hide or show the section">
								<span class="glyphicon glyphicon-triangle-bottom"/>
							</a>
						</small></h4>
					<div id="library">
						<ul>
							<xsl:apply-templates
								select="$references//ref[contains(@uri, 'numismatics.org/library') or contains(@uri, 'numismatics.org/digitallibrary') or contains(@uri, 'numismatics.org/archives')]">
								<xsl:sort/>

								<xsl:with-param name="facs" select="$facs"/>
								<xsl:with-param name="rdf" select="$rdf"/>
							</xsl:apply-templates>
						</ul>
					</div>
				</div>
			</xsl:if>

			<xsl:if test="$references//ref[contains(@uri, 'numismatics.org/collection')]">
				<div>
					<h4>ANS Collection <small>
							<a href="#" class="toggle-button" id="toggle-collection" title="Click to hide or show the section">
								<span class="glyphicon glyphicon-triangle-right"/>
							</a>
						</small></h4>
					<div id="collection" style="display:none">
						<ul>
							<xsl:apply-templates select="$references//ref[contains(@uri, 'numismatics.org/collection')]">
								<xsl:sort/>

								<xsl:with-param name="facs" select="$facs"/>
								<xsl:with-param name="rdf" select="$rdf"/>
							</xsl:apply-templates>
						</ul>
					</div>
				</div>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- ******************** INDEX TERM TEMPLATES *********************** -->
	<xsl:template match="ref">
		<xsl:param name="facs"/>
		<xsl:param name="rdf"/>

		<xsl:variable name="label" select="label"/>
		<xsl:variable name="uri" select="@uri"/>
		<xsl:variable name="id" select="facs"/>

		<xsl:variable name="facet">
			<xsl:choose>
				<xsl:when test="contains($uri, 'nomisma.org')">
					<xsl:variable name="type" select="$rdf//*[@rdf:about = $uri]/name()"/>
					<xsl:choose>
						<xsl:when test="$type = 'nmo:Region' or $type = 'nmo:Mint'">geogname</xsl:when>
						<xsl:when test="$type = 'foaf:Person'">persname</xsl:when>
						<xsl:when test="$type = 'foaf:Organization'">corpname</xsl:when>
						<xsl:otherwise>subject</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($uri, 'geonames.org')">geogname</xsl:when>
				<xsl:when test="contains($uri, 'viaf.org')">
					<xsl:choose>
						<xsl:when test="$rdf//*[@rdf:about = $uri]/rdf:type/@rdf:resource = 'http://xmlns.com/foaf/0.1/Organization'">corpname</xsl:when>
						<xsl:when test="$rdf//*[@rdf:about = $uri]/rdf:type/@rdf:resource = 'http://xmlns.com/foaf/0.1/Person'">persname</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when
					test="
						contains($uri, 'numismatics.org/ocre') or contains($uri, 'numismatics.org/crro') or contains($uri, 'numismatics.org/pella') or contains($uri, 'numismatics.org/pco')
						or contains($uri, 'numismatics.org/sco')"
					>coinType</xsl:when>
				<xsl:when test="contains($uri, 'coinhoards.org')">hoard</xsl:when>
				<!-- wikipedia links cannot easily be parsed, ignore indexing -->
				<xsl:when test="contains($uri, 'wikipedia') or contains($uri, 'wikidata.org')"/>
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
						<xsl:text> </xsl:text>
						<small>
							<a href="{$uri}" target="_blank">
								<span class="glyphicon glyphicon-new-window"/>
							</a>
						</small>
					</strong>
				</xsl:when>
				<xsl:otherwise>
					<strong>
						<xsl:value-of select="$label"/>
						<xsl:text> </xsl:text>
						<small>
							<a href="{$uri}" target="_blank">
								<span class="glyphicon glyphicon-new-window"/>
							</a>
						</small>
					</strong>
				</xsl:otherwise>
			</xsl:choose>

			<!-- list of page numbers for the entity -->
			<xsl:text> (</xsl:text>
			<xsl:for-each select="$facs//tei:facsimile[descendant::tei:ref[@target = $uri]] | $facs//tei:facsimile[@xml:id = $id]">
				<xsl:choose>
					<xsl:when test="$mirador = true()">
						<xsl:variable name="canvas" select="concat($url, 'manifest/', $recordId, '/canvas/', @xml:id)"/>
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
			<xsl:text>)</xsl:text>
		</li>
	</xsl:template>

	<!-- ******************** FACSIMILE TEMPLATES *********************** -->
	<xsl:template name="facsimiles">
		<xsl:choose>
			<xsl:when test="$mirador = true()">
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
	<xsl:template match="tei:teiHeader">
		<h3>About this Item</h3>

		<dl class="dl-horizontal">
			<xsl:apply-templates select="tei:fileDesc/tei:titleStmt/tei:author"/>
			<xsl:apply-templates select="tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:date"/>
			<xsl:apply-templates select="tei:fileDesc/tei:publicationStmt"/>
			<xsl:apply-templates select="tei:profileDesc/tei:abstract"/>
		</dl>

		<xsl:if test="tei:profileDesc/tei:particDesc//*[@ref and not(@facs)] or tei:profileDesc//tei:term[@ref and not(@facs)]">
			<div>
				<h4>Subjects</h4>
				<ul>
					<xsl:apply-templates select="tei:profileDesc/tei:particDesc//*[@ref and not(@facs)] | tei:profileDesc//tei:term[@ref and not(@facs)]"/>
				</ul>
			</div>
		</xsl:if>

		<xsl:if test="tei:profileDesc/tei:textClass">
			<div>
				<h4>Genre/Format</h4>
				<ul>
					<xsl:apply-templates select="tei:profileDesc/tei:textClass/tei:classCode"/>
				</ul>
			</div>
		</xsl:if>

		<xsl:apply-templates select="tei:fileDesc/tei:notesStmt"/>
	</xsl:template>

	<xsl:template match="tei:classCode">
		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test=". = '300264354'">notebooks</xsl:when>
				<xsl:when test=". = '300026877'">correspondence</xsl:when>
				<xsl:when test=". = '300265639'">research notes</xsl:when>
				<xsl:when test=". = '300046300'">hoard photographs</xsl:when>
				<xsl:when test=". = '300027568'">invoices</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<li>
			<a href="{$display_path}results?q=genreform_facet:&#x022;{$label}&#x022;">
				<xsl:value-of select="$label"/>
			</a>
			<small>
				<xsl:text> </xsl:text>
				<a href="{concat(@scheme, normalize-space(.))}">
					<span class="glyphicon glyphicon-new-window"/>
				</a>
			</small>
		</li>
	</xsl:template>

	<xsl:template match="tei:persName[@ref] | tei:orgName[@ref] | tei:term[@ref]">
		<xsl:variable name="facet">
			<xsl:choose>
				<xsl:when test="self::tei:persName">persname</xsl:when>
				<xsl:when test="self::tei:orgName">corpname</xsl:when>
				<xsl:when test="self::tei:term">subject</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<li>
			<a href="{$display_path}results?q={$facet}_facet:&#x022;{normalize-space(.)}&#x022;">
				<xsl:value-of select="normalize-space(.)"/>
			</a>
			<small>
				<xsl:text> </xsl:text>
				<a href="{@ref}">
					<span class="glyphicon glyphicon-new-window"/>
				</a>
			</small>
		</li>
	</xsl:template>

	<xsl:template match="tei:publicationStmt">
		<xsl:apply-templates select="tei:publisher | tei:pubPlace | tei:idno[@type = 'donum']"/>

	</xsl:template>

	<xsl:template match="tei:notesStmt">
		<div>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="tei:publisher">
		<dt>
			<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="tei:name and tei:idno[@type = 'URI']">
					<xsl:value-of select="normalize-space(tei:name)"/>
					<small>
						<xsl:text> </xsl:text>
						<a href="{tei:idno[@type='URI']}">
							<span class="glyphicon glyphicon-new-window"/>
						</a>
					</small>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</dd>
	</xsl:template>

	<xsl:template match="tei:pubPlace | tei:author | tei:abstract | tei:date">
		<dt>
			<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="self::tei:author">
					<a href="{$display_path}results?q={lower-case(child::*/name())}_facet:&#x022;{normalize-space(child::*)}&#x022;">
						<xsl:value-of select="normalize-space(child::*)"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="child::*/@ref">
				<small>
					<xsl:text> </xsl:text>
					<a href="{child::*/@ref}">
						<span class="glyphicon glyphicon-new-window"/>
					</a>
				</small>
			</xsl:if>
		</dd>
	</xsl:template>

	<xsl:template match="tei:idno[@type = 'donum']">
		<dt>Donum</dt>
		<dd>
			<a href="http://numismatics.org/library/{.}">
				<xsl:text>http://numismatics.org/library/</xsl:text>
				<xsl:value-of select="."/>
			</a>
		</dd>
	</xsl:template>

	<xsl:template match="tei:note">
		<h4>Note</h4>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tei:p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="tei:ref[matches(@target, 'https?://')]">
		<a href="{@target}" title="{.}">
			<xsl:value-of select="."/>
		</a>
	</xsl:template>

</xsl:stylesheet>
