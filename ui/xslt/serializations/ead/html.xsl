<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xlink="http://www.w3.org/1999/xlink"
	version="2.0">

	<xsl:include href="html-toc.xsl"/>
	<xsl:include href="html-templates.xsl"/>
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	
	<!-- path and document params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
	<xsl:variable name="pipeline">display</xsl:variable>
	<xsl:param name="uri" select="doc('input:request')/request/request-url"/>
	<xsl:param name="path">
		<xsl:choose>
			<xsl:when test="contains($uri, 'ark:/')">
				<xsl:value-of select="substring-after(substring-after($uri, 'ark:/'), '/')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-after($uri, 'id/')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:variable name="doc">
		<xsl:choose>
			<xsl:when test="contains($path, '/')">
				<xsl:value-of select="tokenize($path, '/')[1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="contains($path, '.')">
						<xsl:variable name="pieces" select="tokenize($path, '\.')"/>
						
						<xsl:for-each select="$pieces[not(position()=last())]">
							<xsl:value-of select="."/>
							<xsl:if test="not(position()=last())">
								<xsl:text>.</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$path"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="id">
		<xsl:if test="contains($path, '/')">
			<xsl:variable name="last-piece" select="substring-after($path, '/')"/>
			<xsl:choose>
				<xsl:when test="contains($last-piece, '.')">
					<xsl:variable name="pieces" select="tokenize($last-piece, '\.')"/>
					<xsl:for-each select="$pieces[not(position()=last())]">
						<xsl:value-of select="."/>
						<xsl:if test="not(position()=last())">
							<xsl:text>.</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$last-piece"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:variable>
	
	<!-- config variables -->
	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="url" select="/content/config/url"/>
	
	<!-- display path -->
	<xsl:variable name="display_path">
		<xsl:variable name="default">
			<xsl:choose>
				<xsl:when test="$mode='private'">
					<xsl:choose>
						<xsl:when test="string($id)">
							<xsl:text>../../../</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>../../</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="contains($uri, 'ark:/')">
							<xsl:choose>
								<xsl:when test="string($id)">
									<xsl:text>../../../</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>../../</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string($id)">
									<xsl:text>../../</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>../</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- after default path is set, replace ../ when it is an aggregate collection -->		
		<xsl:choose>
			<xsl:when test="/content/config/aggregator='true'">
				<xsl:value-of select="concat($default, '../')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$default"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:variable>
	
	<xsl:variable name="include_path" select="/content/config/url"/>
	
	<!-- boolean variable as to whether there are mappable points -->
	<xsl:variable name="hasPoints" select="boolean(descendant::ead:geogname[string(@authfilenumber) and string(@source)])"/>
	<xsl:variable name="upload" select="boolean(descendant::ead:archdesc/ead:otherfindaid[@type='eaditor_upload']/ead:bibref/ead:extptr/@xlink:href)"/>
	
	<!-- url params -->
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="mode">
		<xsl:choose>
			<xsl:when test="contains($uri, 'admin/')">private</xsl:when>
			<xsl:otherwise>public</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	
	<xsl:template match="/">
		<xsl:apply-templates select="/content/ead:ead"/>
	</xsl:template>
	
	<xsl:template match="ead:ead">
		<html>
			<head prefix="dcterms: http://purl.org/dc/terms/     foaf: http://xmlns.com/foaf/0.1/     owl:  http://www.w3.org/2002/07/owl#     rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
				skos: http://www.w3.org/2004/02/skos/core#     dcterms: http://purl.org/dc/terms/     arch: http://purl.org/archival/vocab/arch#     xsd: http://www.w3.org/2001/XMLSchema#">
				<title id="{$path}">
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:choose>
						<xsl:when test="ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper">
							<xsl:choose>
								<xsl:when test="ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[@type='sort']">
									<xsl:value-of select="ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[@type='sort']"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper[1]"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:value-of select="ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper"/>
						</xsl:when>
						<xsl:when test="string(ead:did/ead:unittitle)">
							<xsl:value-of select="ead:did/ead:unittitle"/>
						</xsl:when>					
					</xsl:choose>
				</title>
				<!-- alternates -->
				<link rel="alternate" type="text/xml" href="{$path}.xml"/>
				<link rel="alternate" type="application/rdf+xml" href="{$path}.rdf"/>
				
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<!-- include fancybox -->
				<link rel="stylesheet" href="{$include_path}ui/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>
				<link rel="stylesheet" href="{$include_path}ui/css/esln.css"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/display_functions.js"/>
				<xsl:if test="$hasPoints = true()">
					<!-- mapping -->
					<!--<link type="text/css" href="{$include_path}ui/css/timeline-2.3.0.css" rel="stylesheet"/>-->
					<script src="{$include_path}ui/javascript/OpenLayers.js" type="text/javascript"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/mxn.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/timeline-2.3.0.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/timemap_full.pack.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/param.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/display_map_functions.js"/>
				</xsl:if>
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<div class="container-fluid">
					<xsl:call-template name="ead-content"/>
				</div>
				<div id="path" style="display:none">../</div>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="ead-content">
		<!-- display component if there's an $id, otherwise whole finding aid -->
		<xsl:choose>
			<xsl:when test="string($id)">
				<div class="row">
					<div class="col-md-12">
						<xsl:call-template name="component-template"/>
					</div>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="head"/>
				<xsl:call-template name="body"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="head">
		<div class="row">
			<div class="col-md-12">
				<h1>
					<span property="dcterms:title">
						<xsl:value-of select="ead:archdesc/ead:did/ead:unittitle"/>
					</span>
					<xsl:if test="ead:archdesc/ead:did/ead:unitdate">
						<xsl:text>, </xsl:text>
						<span>
							<xsl:value-of select="string-join(ead:archdesc/ead:did/ead:unitdate, ', ')"/>
						</span>
					</xsl:if>
				</h1>
			</div>
		</div>
		<div class="row">
			<xsl:choose>
				<!-- render some biographical information from EAC-CPF if the creator a xeac:entity -->
				<xsl:when test="ead:archdesc/ead:did/ead:origination/*[@role='xeac:entity']">
					<xsl:variable name="eac-cpf" as="element()*">
						<xsl:copy-of select="document(concat(ead:archdesc/ead:did/ead:origination/*[@role='xeac:entity']/@authfilenumber, '.xml'))/eac:eac-cpf"/>
					</xsl:variable>

					<xsl:call-template name="did"/>
					
					<div class="col-md-12">
						<h2>Creator</h2>
						<dl class="dl-horizontal">
							<dt>Name</dt>
							<dd>
								<xsl:apply-templates select="ead:archdesc/ead:did/ead:origination/*[@role='xeac:entity']"/>
							</dd>
							<xsl:if test="string($eac-cpf//eac:abstract)">
								<dt>Abstract</dt>
								<dd>
									<xsl:value-of select="$eac-cpf//eac:abstract"/>
								</dd>
							</xsl:if>
						</dl>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<!-- otherwise display everything from the did -->
					<xsl:call-template name="did"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template name="did">
		<xsl:choose>
			<xsl:when test="ead:archdesc/ead:did/ead:dao/@xlink:href">
				<div class="col-md-6">
					<xsl:apply-templates select="ead:archdesc/ead:did"/>
				</div>
				<div class="col-md-6">
					<xsl:apply-templates select="ead:archdesc/ead:did/ead:dao"/>
				</div>
			</xsl:when>
			<xsl:when test="contains(ead:archdesc/ead:did/ead:daogrp/ead:daoloc[@xlink:label='Small']/@xlink:href, 'flickr.com')">
				<div class="col-md-6">
					<xsl:apply-templates select="ead:archdesc/ead:did"/>
				</div>
				<div class="col-md-6">
					<xsl:apply-templates select="ead:archdesc/ead:did/ead:daogrp/ead:daoloc[@xlink:label='Small']" mode="collection-image"/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div class="col-md-12">
					<xsl:apply-templates select="ead:archdesc/ead:did"/>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="body">
		<div class="row">
			<div class="col-md-12">
				<ul class="nav nav-pills" id="tabs">
					<li class="active">
						<a href="#summary" data-toggle="pill">Summary</a>
					</li>
					<xsl:if test="$hasPoints = true()">
						<li>
							<a href="#mapTab" id="mapButton" data-toggle="pill">Map</a>
						</li>
					</xsl:if>
				</ul>
				<div class="tab-content">
					<div class="tab-pane active" id="summary">
						<div class="col-md-3">
							<xsl:call-template name="toc"/>
						</div>
						<div class="col-md-9">
							<div id="archdesc-info">
								<xsl:call-template name="archdesc-admininfo"/>
								
								<xsl:apply-templates select="ead:archdesc/ead:bioghist"/>
								<xsl:apply-templates select="ead:archdesc/ead:scopecontent"/>
								<xsl:if test="count(ead:archdesc/ead:daogrp[count(ead:daoloc) &gt; 0]) &gt; 0">
									<xsl:call-template name="archdesc-images"/>
								</xsl:if>
								<xsl:apply-templates select="ead:archdesc/ead:arrangement"/>
								<xsl:call-template name="archdesc-relatedmaterial"/>
								<xsl:apply-templates select="ead:archdesc/ead:note"/>
								<xsl:apply-templates select="ead:archdesc/ead:controlaccess"/>
								<xsl:apply-templates select="ead:archdesc/ead:odd"/>
								<xsl:apply-templates select="ead:archdesc/ead:originalsloc"/>
								<xsl:apply-templates select="ead:archdesc/ead:phystech"/>									
								<xsl:apply-templates select="ead:archdesc/ead:otherfindaid | ead:archdesc/*/ead:otherfindaid"/>
								<xsl:apply-templates select="ead:archdesc/ead:fileplan | ead:archdesc/*/ead:fileplan"/>
								<xsl:apply-templates select="ead:archdesc/ead:bibliography | ead:archdesc/*/ead:bibliography"/>
								<xsl:apply-templates select="ead:archdesc/ead:index | ead:archdesc/*/ead:index"/>
							</div>
							<div id="dsc">
								<xsl:apply-templates select="ead:archdesc/ead:dsc"/>
							</div>
						</div>
					</div>
					<xsl:if test="$hasPoints = true()">
						<div class="tab-pane" id="mapTab">
							<div id="timemap">
								<div id="display-mapcontainer">
									<div id="map"/>
								</div>
								<div id="timelinecontainer">
									<div id="timeline"/>
								</div>
							</div>
						</div>
					</xsl:if>
				</div>
			</div>
		</div>
	</xsl:template>

	<!--This template creates a table for the did, inserts the head and then
      each of the other did elements.  To change the order of appearance of these
      elements, change the sequence of the apply-templates statements.-->
	<xsl:template match="ead:archdesc/ead:did">
		<div id="archdesc-did">
			<a name="{generate-id(.)}"/>
			<h2>
				<xsl:choose>
					<xsl:when test="ead:head">
						<xsl:apply-templates select="ead:head"/>
					</xsl:when>
					<xsl:otherwise>Descriptive Identification</xsl:otherwise>
				</xsl:choose>
			</h2>
			
			<xsl:choose>
				<xsl:when test="$upload = true()">
					<xsl:variable name="content-type" select="parent::ead:archdesc/ead:otherfindaid[@type='eaditor_upload']/ead:bibref/ead:extptr/@xlink:role"/>
					
					<div class="col-md-8">
						<xsl:call-template name="did-dl"/>
					</div>
					<div class="col-md-4">
						<div class="highlight">
							<h3>Download Container List</h3>
							<h4>
								<a href="{$include_path}uploads/{$collection-name}/{parent::ead:archdesc/ead:otherfindaid[@type='eaditor_upload']/ead:bibref/ead:extptr/@xlink:href}" itemprop="url">
									<xsl:choose>
										<xsl:when test="$content-type='application/pdf'">
											<img src="{$include_path}ui/images/adobe.png" alt="PDF" class="doc-icon"/>
										</xsl:when>
										<xsl:when test="contains($content-type, 'oasis') or contains($content-type, 'sun')">
											<img src="{$include_path}ui/images/writer.png" alt="LibreOffice Writer" class="doc-icon"/>
										</xsl:when>
										<xsl:when test="contains($content-type, 'word') or contains($content-type, 'document')">
											<img src="{$include_path}ui/images/word.png" alt="Microsoft Word" class="doc-icon"/>
										</xsl:when>
										<xsl:when test="contains($content-type, 'excel') or contains($content-type, 'sheet')">
											<img src="{$include_path}ui/images/excel.png" alt="Microsoft Excel" class="doc-icon"/>
										</xsl:when>										
										<xsl:otherwise>
											<xsl:value-of select="$content-type"/>
										</xsl:otherwise>
									</xsl:choose>
								</a>
							</h4>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="did-dl"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template name="did-dl">
		<dl class="dl-horizontal">
			<xsl:apply-templates select="ead:unitid"/>
			<xsl:apply-templates select="ead:container"/>
			<xsl:apply-templates select="ead:repository"/>
			<xsl:apply-templates select="ead:physdesc/ead:extent"/>
			<xsl:apply-templates select="ead:physdesc/ead:dimensions"/>
			<xsl:apply-templates select="ead:physdesc/ead:genreform"/>
			<xsl:apply-templates select="ead:physdesc/ead:physfacet"/>
			<xsl:apply-templates select="ead:origination[not(child::*[@role='xeac:entity'])]"/>
			<xsl:apply-templates select="ead:physloc"/>
			<xsl:apply-templates select="ead:langmaterial"/>
			<xsl:apply-templates select="ead:materialspec"/>
			<xsl:apply-templates select="ead:abstract"/>
			<xsl:apply-templates select="ead:note"/>
		</dl>
	</xsl:template>
	
	<xsl:template name="archdesc-images">
		<div class="row">
			<div class="col-md-12">
				<h2>Images</h2>
				<xsl:apply-templates select="ead:archdesc/ead:daogrp | ead:archdesc/ead:dao"/>
			</div>
		</div>
	</xsl:template>
	
	<!-- suppress odd elements that are injected into the EAD XML model -->
	<xsl:template match="ead:odd[@type='eaditor:parent']"/>

	<!--This template formats the repostory, origination, physdesc, abstract,
      unitid, physloc and materialspec elements of ead:archdesc/did which share a common presentaiton.
      The sequence of their appearance is governed by the previous template.-->
	<xsl:template
		match="ead:repository | ead:origination | ead:physdesc/ead:extent | ead:physdesc/ead:dimensions | ead:physdesc/ead:genreform | ead:physdesc/ead:physfacet | ead:unitid | ead:physloc | ead:abstract | ead:langmaterial | ead:materialspec | ead:container">
		<dt>
			<xsl:choose>
				<xsl:when test="local-name()='container'">
					<xsl:choose>
						<xsl:when test="string(@type)">
							<xsl:value-of select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="string(normalize-space(@label))">
					<xsl:value-of select="normalize-space(@label)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
				</xsl:otherwise>
			</xsl:choose>
		</dt>
		<dd>
			<!-- insert applicable RDFa attributes -->
			<xsl:choose>
				<xsl:when test="local-name()='abstract'">
					<xsl:attribute name="property">dcterms:abstract</xsl:attribute>
				</xsl:when>
				<xsl:when test="local-name()='extent'">
					<xsl:attribute name="property">dcterms:extent</xsl:attribute>
				</xsl:when>
				<xsl:when test="local-name()='origination' and not(child::*)">
					<xsl:attribute name="property">dcterms:creator</xsl:attribute>
				</xsl:when>
				<xsl:when test="local-name()='unitid'">
					<xsl:attribute name="property">dcterms:identifier</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates/>
		</dd>
	</xsl:template>


	<!-- The following two templates test for and processes various permutations
      of unittitle and unitdate.-->
	<xsl:template match="ead:archdesc/ead:did/ead:unittitle">
		<dt>
			<b>
				<xsl:value-of select="if (string(@label)) then @label else 'Title'"/>
			</b>
		</dt>
		<dd>
			<!--Inserts the text of unittitle and any children other that unitdate.-->
			<xsl:apply-templates select="text() |* [not(name() = 'unitdate')]"/>
			<xsl:for-each select="ead:unitdate">
				<xsl:value-of select="."/>
				<xsl:if test="not(position()=last())">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="count(parent::node()/ead:unitdate) &gt; 0">
				<xsl:text>, </xsl:text>
				<xsl:for-each select="parent::node()/ead:unitdate">
					<xsl:value-of select="."/>
					<xsl:if test="not(position()=last())">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</dd>
	</xsl:template>

	<!--This template processes the note element.-->
	<xsl:template match="ead:archdesc/ead:did/ead:note">
		<dt>
			<xsl:choose>
				<xsl:when test="string(normalize-space(@label))">
					<xsl:value-of select="normalize-space(@label)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Note</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</dt>
		<dd>
			<xsl:apply-templates/>
		</dd>
	</xsl:template>

	<!--This template formats various head elements and makes them targets for
      links from the Table of Contents.-->
	<xsl:template
		match="ead:archdesc/ead:bioghist | ead:archdesc/ead:note | ead:archdesc/ead:scopecontent | ead:archdesc/ead:arrangement | ead:archdesc/ead:phystech | ead:archdesc/ead:odd | ead:archdesc/ead:bioghist/ead:note | ead:archdesc/ead:scopecontent/ead:note | ead:archdesc/ead:phystech/ead:note | ead:archdesc/ead:controlaccess/ead:note | ead:archdesc/ead:odd/ead:note">
		<div class="{name()}">
			<a id="{generate-id(.)}"/>
			<h2>
				<xsl:value-of select="if (ead:head) then ead:head else eaditor:normalize_fields(local-name(), $lang)"/>
			</h2>
			<xsl:apply-templates select="*[not(self::ead:head)]"/>
		</div>
	</xsl:template>

	<xsl:template match="ead:p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<!--This template rule formats the top-level related material
      elements by combining any related or separated materials
      elements. It begins by testing to see if there related or separated
      materials elements with content.-->
	<xsl:template name="archdesc-relatedmaterial">

		<xsl:if
			test="string(ead:archdesc/ead:relatedmaterial) or string(ead:archdesc/*/ead:relatedmaterial) or string(ead:archdesc/ead:separatedmaterial) or string(ead:archdesc/*/ead:separatedmaterial)">
			<div id="relatedmaterial">
				<a name="relatedmaterial"/>
				<h2>
					<xsl:text>Related Material</xsl:text>
				</h2>

				<xsl:apply-templates select="ead:archdesc/ead:relatedmaterial"/>
				<xsl:apply-templates select="ead:archdesc/ead:separatedmaterial"/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="archdesc-admininfo">		
		<xsl:if
			test="ead:archdesc/ead:accessrestrict | ead:archdesc/ead:userestrict | ead:archdesc/ead:prefercite | ead:archdesc/ead:altformavail | ead:archdesc/ead:accruals | ead:archdesc/ead:acqinfo | ead:archdesc/ead:appraisal | ead:archdesc/ead:custodhist | ead:archdesc/ead:processinfo">
			<h2>
				<a name="admininfo"/>
				<xsl:choose>
					<xsl:when test="ead:head">
						<xsl:value-of select="ead:head"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Administrative Information</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</h2>
			<div class="dd">
				<xsl:apply-templates
					select="ead:archdesc/ead:accessrestrict | ead:archdesc/ead:userestrict | ead:archdesc/ead:prefercite | ead:archdesc/ead:altformavail | ead:archdesc/ead:accruals | ead:archdesc/ead:acqinfo | ead:archdesc/ead:appraisal | ead:archdesc/ead:custodhist | ead:archdesc/ead:processinfo"
				/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ead:accessrestrict | ead:userestrict | ead:prefercite | ead:altformavail | ead:accruals | ead:acqinfo | ead:appraisal | ead:custodhist | ead:processinfo">
		<h3>
			<xsl:value-of select="if (ead:head) then ead:head else eaditor:normalize_fields(local-name(), $lang)"/>
		</h3>
		<xsl:apply-templates select="ead:p"/>
	</xsl:template>

	<xsl:template
		match="ead:archdesc/ead:otherfindaid | ead:archdesc/*/ead:otherfindaid | ead:archdesc/ead:bibliography | ead:archdesc/*/ead:bibliography | ead:archdesc/ead:phystech | ead:archdesc/ead:originalsloc">
		<xsl:apply-templates/>
	</xsl:template>

	<!--This template rule tests for and formats the top-level index element. It begins
      by testing to see if there is an index element with content.-->
	<xsl:template match="ead:index">
		<div class="dd">
			<xsl:choose>
				<xsl:when test="@head">
					<xsl:choose>
						<xsl:when test="parent::ead:archdesc">
							<h2>
								<xsl:apply-templates select="ead:head"/>
							</h2>
						</xsl:when>
						<xsl:otherwise>
							<li>
								<b>
									<xsl:apply-templates select="ead:head"/>
								</b>
							</li>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="parent::ead:archdesc">
							<h2>Index</h2>
						</xsl:when>
						<xsl:otherwise>
							<li>
								<b>Index</b>
							</li>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="ead:address | ead:blockquote | ead:chronlist | ead:index | ead:list | ead:listhead | ead:note | ead:p | ead:table"/>

			<xsl:if test="ead:indexentry">
				<ul>
					<xsl:for-each select="ead:indexentry">
						<xsl:apply-templates/>
					</xsl:for-each>
				</ul>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="ead:controlaccess">
		<a name="{generate-id(.)}"/>
		<xsl:variable name="class">
			<xsl:if test="ancestor::ead:c">
				<xsl:text>clevel</xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="controlaccess" as="node()*">
			<controlaccess xmlns="urn:isbn:1-931666-22-9">
				<xsl:copy-of select="*"/>
			</controlaccess>
		</xsl:variable>

		<div>

			<!-- add class for component level controlaccess only, not within archdesc -->
			<xsl:if test="string($class)">
				<xsl:attribute name="class" select="$class"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@head">
					<xsl:choose>
						<xsl:when test="parent::ead:archdesc">
							<h2>
								<xsl:apply-templates select="ead:head"/>
							</h2>
						</xsl:when>
						<xsl:otherwise>
							<b>
								<xsl:apply-templates select="ead:head"/>
							</b>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="parent::ead:archdesc">
							<h2>
								<xsl:value-of select="eaditor:normalize_fields('controlaccess', $lang)"/>
							</h2>
						</xsl:when>
						<xsl:otherwise>
							<b>
								<xsl:value-of select="eaditor:normalize_fields('controlaccess', $lang)"/>
							</b>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:apply-templates select="ead:address | ead:blockquote | ead:chronlist | ead:controlaccess | ead:list | ead:listhead | ead:note | ead:p | ead:table"/>

			<!-- created unnumbered list for the access terms: this XSLT is simplified from earlier versions -->
			<xsl:variable name="accessTerms">corpname,famname,function,genreform,geogname,name,occupation,persname,subject,title</xsl:variable>

			<xsl:for-each select="tokenize($accessTerms, ',')">
				<xsl:variable name="element" select="."/>
				<xsl:if test="count($controlaccess//*[local-name()=$element]) &gt; 0">
					<ul>
						<li>
							<xsl:choose>
								<xsl:when test="$class='clevel'">
									<b>
										<xsl:value-of select="eaditor:normalize_fields($element, $lang)"/>
									</b>
								</xsl:when>
								<xsl:otherwise>
									<h3>
										<xsl:value-of select="eaditor:normalize_fields($element, $lang)"/>
									</h3>
								</xsl:otherwise>
							</xsl:choose>
							<ul>
								<xsl:apply-templates select="$controlaccess//*[local-name()=$element]"/>
							</ul>
						</li>
					</ul>
				</xsl:if>
			</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template match="ead:title" mode="controlaccess">
		<li>
			<xsl:value-of select="normalize-space(.)"/>
			<xsl:if test="string(normalize-space(@role))">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="@role"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
		</li>
	</xsl:template>

	<xsl:template match="ead:corpname | ead:famname | ead:function | ead:genreform | ead:geogname | ead:name | ead:occupation | ead:persname | ead:subject">
		<xsl:choose>
			<xsl:when test="ancestor::ead:controlaccess or ancestor::ead:index">
				<li>
					<xsl:call-template name="access-term"/>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="access-term"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="access-term">
		<a
			href="{$display_path}results?q={name()}_facet:&#x022;{if (contains(normalize-space(.), '&amp;')) then encode-for-uri(normalize-space(.)) else normalize-space(.)}&#x022;">
			<xsl:value-of select="normalize-space(.)"/>
		</a>
		<xsl:if test="string(@source) and string(@authfilenumber)">
			<xsl:choose>
				<xsl:when test="@source='aat'">
					<a href="http://vocab.getty.edu/aat/{@authfilenumber}" title="Getty AAT" rel="dcterms:format">
						<span class="glyphicon glyphicon-new-window"/>
					</a>
				</xsl:when>
				<xsl:when test="@source='tgn'">
					<a href="http://vocab.getty.edu/tgn/{@authfilenumber}" title="Getty TGN" rel="dcterms:coverage">
						<span class="glyphicon glyphicon-new-window"/>
					</a>
				</xsl:when>
				<xsl:when test="@source='geonames'">
					<a href="http://www.geonames.org/{@authfilenumber}" title="Geonames" rel="dcterms:coverage">
						<span class="glyphicon glyphicon-new-window"/>
					</a>
				</xsl:when>
				<xsl:when test="@source='pleiades'">
					<a href="http://pleiades.stoa.org/places/{@authfilenumber}" title="Pleiades" rel="dcterms:coverage">
						<span class="glyphicon glyphicon-new-window"/>
					</a>
				</xsl:when>
				<xsl:when test="@source='lcsh'">
					<a href="http://id.loc.gov/authorities/{@authfilenumber}" title="LCSH" rel="dcterms:subject">
						<span class="glyphicon glyphicon-new-window"/>
					</a>
				</xsl:when>
				<xsl:when test="@source='lcgft'">
					<a href="http://id.loc.gov/authorities/{@authfilenumber}" title="LCGFT" rel="dcterms:format">
						<span class="glyphicon glyphicon-new-window"/>
					</a>
				</xsl:when>
				<xsl:when test="@source='lcnaf'">
					<a href="http://id.loc.gov/authorities/names/{@authfilenumber}" title="LCNAF">
						<span class="glyphicon glyphicon-new-window"/>
					</a>
				</xsl:when>
				<xsl:when test="@source='viaf'">
					<a href="http://viaf.org/viaf/{@authfilenumber}" title="VIAF" rel="arch:correspondedWith">
						<span class="glyphicon glyphicon-new-window"/>
					</a>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="contains(@authfilenumber, 'http://')">
			<a href="{@authfilenumber}" rel="{if (parent::ead:origination) then 'dcterms:creator' else 'arch:correspondedWith'}">
				<span class="glyphicon glyphicon-new-window"/>
			</a>
		</xsl:if>
		<xsl:if test="string(normalize-space(@role))">
			<xsl:text> (</xsl:text>
			<xsl:value-of select="@role"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:if test="not(position()=last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>



	<xsl:template match="ead:title">
		<xsl:choose>
			<xsl:when test="@render = 'italic'">
				<i>
					<xsl:apply-templates/>
				</i>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="ead:dao | ead:daoloc">
		<xsl:if test="@xlink:href">
			<xsl:variable name="title" select="normalize-space(@title)"/>
			<img src="{@xlink:href}" title="{$title}"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ead:daoloc" mode="flickr-image">
		<xsl:variable name="photo_id" select="substring-before(tokenize(@xlink:href, '/')[last()], '_')"/>
		<xsl:variable name="flickr_uri" select="eaditor:get_flickr_uri($photo_id)"/>

		<a href="{$flickr_uri}" target="_blank" class="flickrthumb">
			<img class="gi" src="{@xlink:href}"/>
		</a>
		<h3>
			<xsl:value-of select="parent::node()/ead:daodesc/ead:head"/>
		</h3>
		<p>
			<xsl:value-of select="parent::node()/ead:daodesc/ead:p"/>
		</p>
	</xsl:template>

	<xsl:template match="ead:lb">
		<br/>
	</xsl:template>


	<xsl:template match="extref[@xlink:href]">
		<xsl:element name="a">
			<xsl:attribute name="href">
				<xsl:value-of select="@xlink:href"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="ead:subtitle/num">
		<br/>
		<xsl:value-of select="@type"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates/>
		<br/>
	</xsl:template>

	<!-- The following general templates format the display of various RENDER
		attributes.-->
	<xsl:template match="emph[@render='bold']">
		<b>
			<xsl:apply-templates/>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='italic']">
		<i>
			<xsl:apply-templates/>
		</i>
	</xsl:template>
	<xsl:template match="emph[@render='underline']">
		<u>
			<xsl:apply-templates/>
		</u>
	</xsl:template>
	<xsl:template match="emph[@render='sub']">
		<sub>
			<xsl:apply-templates/>
		</sub>
	</xsl:template>
	<xsl:template match="emph[@render='super']">
		<super>
			<xsl:apply-templates/>
		</super>
	</xsl:template>

	<xsl:template match="emph[@render='quoted']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="emph[@render='doublequote']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>
	<xsl:template match="emph[@render='singlequote']">
		<xsl:text>'</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>'</xsl:text>
	</xsl:template>
	<xsl:template match="emph[@render='bolddoublequote']">
		<b>
			<xsl:text>"</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>"</xsl:text>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='boldsinglequote']">
		<b>
			<xsl:text>'</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>'</xsl:text>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='boldunderline']">
		<b>
			<u>
				<xsl:apply-templates/>
			</u>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='bolditalic']">
		<b>
			<i>
				<xsl:apply-templates/>
			</i>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='boldsmcaps']">
		<font style="font-variant: small-caps">
			<b>
				<xsl:apply-templates/>
			</b>
		</font>
	</xsl:template>
	<xsl:template match="emph[@render='smcaps']">
		<font style="font-variant: small-caps">
			<xsl:apply-templates/>
		</font>
	</xsl:template>
	<xsl:template match="title[@render='bold']">
		<b>
			<xsl:apply-templates/>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='italic']">
		<i>
			<xsl:apply-templates/>
		</i>
	</xsl:template>
	<xsl:template match="title[@render='underline']">
		<u>
			<xsl:apply-templates/>
		</u>
	</xsl:template>
	<xsl:template match="title[@render='sub']">
		<sub>
			<xsl:apply-templates/>
		</sub>
	</xsl:template>
	<xsl:template match="title[@render='super']">
		<super>
			<xsl:apply-templates/>
		</super>
	</xsl:template>

	<xsl:template match="title[@render='quoted']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="title[@render='doublequote']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="title[@render='singlequote']">
		<xsl:text>'</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>'</xsl:text>
	</xsl:template>
	<xsl:template match="title[@render='bolddoublequote']">
		<b>
			<xsl:text>"</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>"</xsl:text>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='boldsinglequote']">
		<b>
			<xsl:text>'</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>'</xsl:text>
		</b>
	</xsl:template>

	<xsl:template match="title[@render='boldunderline']">
		<b>
			<u>
				<xsl:apply-templates/>
			</u>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='bolditalic']">
		<b>
			<i>
				<xsl:apply-templates/>
			</i>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='boldsmcaps']">
		<font style="font-variant: small-caps">
			<b>
				<xsl:apply-templates/>
			</b>
		</font>
	</xsl:template>
	<xsl:template match="title[@render='smcaps']">
		<font style="font-variant: small-caps">
			<xsl:apply-templates/>
		</font>
	</xsl:template>
	<!-- This template converts a Ref element into an HTML anchor.-->
	<xsl:template match="ref">
		<a href="#{@target}">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="ead:list">
		<ul>
			<xsl:if test="ead:head">
				<li>
					<b>
						<xsl:apply-templates select="ead:head"/>
					</b>
				</li>
			</xsl:if>
			<xsl:apply-templates select="ead:item"/>
		</ul>
	</xsl:template>

	<xsl:template match="ead:item">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<!--Formats a simple table. The width of each column is defined by the colwidth attribute in a colspec element.-->
	<xsl:template match="ead:table">
		<table width="75%" style="margin-left: 25pt">
			<tr>
				<td colspan="3">
					<h3>
						<xsl:apply-templates select="ead:head"/>
					</h3>
				</td>
			</tr>
			<xsl:for-each select="ead:tgroup">
				<tr>
					<xsl:for-each select="ead:colspec">
						<td width="{@colwidth}"/>
					</xsl:for-each>
				</tr>
				<xsl:for-each select="ead:thead">
					<xsl:for-each select="ead:row">
						<tr>
							<xsl:for-each select="ead:entry">
								<td valign="top">
									<b>
										<xsl:apply-templates/>
									</b>
								</td>
							</xsl:for-each>
						</tr>
					</xsl:for-each>
				</xsl:for-each>

				<xsl:for-each select="ead:tbody">
					<xsl:for-each select="ead:row">
						<tr>
							<xsl:for-each select="ead:entry">
								<td valign="top">
									<xsl:apply-templates/>
								</td>
							</xsl:for-each>
						</tr>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</table>
	</xsl:template>
	<!--This template rule formats a chronlist element.-->
	<xsl:template match="ead:chronlist">
		<table width="100%" style="margin-left:25pt">
			<tr>
				<td width="5%"> </td>
				<td width="15%"> </td>
				<td width="80%"> </td>
			</tr>
			<xsl:apply-templates/>
		</table>
	</xsl:template>

	<xsl:template match="ead:chronlist/head">
		<tr>
			<td colspan="3">
				<h3>
					<xsl:apply-templates/>
				</h3>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="ead:chronlist/listhead">
		<tr>
			<td> </td>
			<td>
				<b>
					<xsl:apply-templates select="head01"/>
				</b>
			</td>
			<td>
				<b>
					<xsl:apply-templates select="head02"/>
				</b>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="ead:chronitem">
		<!--Determine if there are event groups.-->
		<xsl:choose>
			<xsl:when test="ead:eventgrp">
				<!--Put the date and first event on the first line.-->
				<tr>
					<td> </td>
					<td valign="top">
						<xsl:apply-templates select="date"/>
					</td>
					<td valign="top">
						<xsl:apply-templates select="ead:eventgrp/ead:event[position()=1]"/>
					</td>
				</tr>
				<!--Put each successive event on another line.-->
				<xsl:for-each select="ead:eventgrp/ead:event[not(position()=1)]">
					<tr>
						<td> </td>
						<td> </td>
						<td valign="top">
							<xsl:apply-templates select="."/>
						</td>
					</tr>
				</xsl:for-each>
			</xsl:when>
			<!--Put the date and event on a single line.-->
			<xsl:otherwise>
				<tr>
					<td> </td>
					<td valign="top">
						<xsl:apply-templates select="ead:date"/>
					</td>
					<td valign="top">
						<xsl:apply-templates select="ead:event"/>
					</td>
				</tr>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ead:address">
		<div>
			<xsl:for-each select="ead:addressline">
				<xsl:value-of select="."/>
				<xsl:if test="not(position() = last())">
					<br/>
				</xsl:if>
			</xsl:for-each>
		</div>
	</xsl:template>

	<!-- suppress eaditor-injected odd for the component parent (used in RDF) -->
	<xsl:template match="ead:odd[@type='eaditor:parent']" mode="#all"/>

</xsl:stylesheet>
