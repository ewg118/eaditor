<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">

	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- path and document params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
	<xsl:variable name="pipeline">display</xsl:variable>
	<xsl:param name="uri" select="doc('input:request')/request/request-url"/>

	<xsl:variable name="recordId" select="//mods:recordIdentifier"/>

	<!-- config variables -->
	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="url" select="/content/config/url"/>

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

	<xsl:variable name="iiif-available" select="boolean(descendant::mods:url[@note = 'IIIFService'])" as="xs:boolean"/>
	<xsl:variable name="manifestURI" select="concat($url, 'manifest/', $recordId)"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/content//mods:mods"/>
	</xsl:template>

	<xsl:template match="mods:mods">
		<html>
			<head
				prefix="dcterms: http://purl.org/dc/terms/     foaf: http://xmlns.com/foaf/0.1/     owl:  http://www.w3.org/2002/07/owl#     rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
				skos: http://www.w3.org/2004/02/skos/core#     dcterms: http://purl.org/dc/terms/     arch: http://purl.org/archival/vocab/arch#     xsd: http://www.w3.org/2001/XMLSchema#">
				<title id="{$recordId}">
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="mods:titleInfo/mods:title"/>
				</title>
				<!-- alternates -->
				<link rel="alternate" type="text/xml" href="{$recordId}.xml"/>
				<link rel="alternate" type="application/rdf+xml" href="{$recordId}.rdf"/>

				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<!-- include fancybox -->
				<link rel="stylesheet" href="{$include_path}ui/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>
				<xsl:if test="$iiif-available = true()">
					<script type="text/javascript" src="https://unpkg.com/leaflet@0.7.7/dist/leaflet.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/leaflet.ajax.min.js"/>
					<link rel="stylesheet" href="https://unpkg.com/leaflet@0.7.7/dist/leaflet.css"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/leaflet-iiif.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/display_functions.js"/>
				</xsl:if>
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:choose>
					<xsl:when test="$iiif-available = true()">
						<xsl:call-template name="header">
							<xsl:with-param name="manifestURI" select="$manifestURI"/>
							<xsl:with-param name="recordId" select="$recordId"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="header">
							<xsl:with-param name="recordId" select="$recordId"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>

				<div class="container-fluid">
					<xsl:call-template name="mods-content"/>
				</div>
				<div class="hidden">
					<span id="path">
						<xsl:value-of select="$display_path"/>
					</span>
					<xsl:if test="$iiif-available">
						<span id="info-json">
							<xsl:value-of select="concat(descendant::mods:url[@note = 'IIIFService'], '/info.json')"/>
						</span>
					</xsl:if>
				</div>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="mods-content">
		<div class="row">
			<div class="col-md-12">
				<h2>
					<xsl:value-of select="mods:titleInfo/mods:title"/>
				</h2>
			</div>
			<div class="col-md-6">
				<xsl:apply-templates select="mods:name"/>
				<xsl:apply-templates select="mods:abstract"/>
				<xsl:apply-templates select="mods:relatedItem[@type = 'original']"/>

				<xsl:if test="count(mods:subject/mods:topic) &gt; 0">
					<h3>Subjects</h3>
					<dl class="dl-horizontal">
						<xsl:for-each select="mods:subject/*">
							<dt>
								<xsl:choose>
									<xsl:when test="local-name() = 'genre'">Genre</xsl:when>
									<xsl:when test="local-name() = 'geographic'">Geographic</xsl:when>
									<xsl:when test="local-name() = 'name'">
										<xsl:choose>
											<xsl:when test="@type = 'personal'">Person</xsl:when>
											<xsl:when test="@type = 'corporate'">Corporate</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="local-name() = 'occupation'">Occupation</xsl:when>
									<xsl:when test="local-name() = 'topic'">Subject</xsl:when>
								</xsl:choose>
							</dt>
							<dd>
								<xsl:variable name="facet">
									<xsl:choose>
										<xsl:when test="local-name() = 'genre'">genreform</xsl:when>
										<xsl:when test="local-name() = 'geographic'">geogname</xsl:when>
										<xsl:when test="local-name() = 'name'">
											<xsl:choose>
												<xsl:when test="@type = 'personal'">persname</xsl:when>
												<xsl:when test="@type = 'corporate'">corpname</xsl:when>
											</xsl:choose>
										</xsl:when>
										<xsl:when test="local-name() = 'occupation'">occupation</xsl:when>
										<xsl:when test="local-name() = 'topic'">subject</xsl:when>
									</xsl:choose>
								</xsl:variable>
								<a href="{$display_path}results/?q={$facet}_facet:&#x022;{.}&#x022;">
									<xsl:value-of select="
											if (mods:namePart) then
												mods:namePart
											else
												."/>
								</a>
								<xsl:if test="string(@valueURI)">
									<xsl:text> </xsl:text>
									<a href="{@valueURI}" rel="dcterms:subject">
										<span class="glyphicon glyphicon-new-window"/>
									</a>
								</xsl:if>
							</dd>
						</xsl:for-each>
					</dl>
				</xsl:if>
				<xsl:if test="mods:note[@type = 'preferred_citation']">
					<div>
						<h3>Preferred Citation</h3>
						<p>
							<xsl:value-of select="mods:note[@type = 'preferred_citation']"/>
						</p>
					</div>
				</xsl:if>
			</div>
			<div class="col-md-6">
				<xsl:choose>
					<xsl:when test="$iiif-available = true()">
						<div id="iiif-container" style="width:100%;height:600px"/>
						<div>
							<a href="{mods:location/mods:url[@note='IIIFService']}/full/full/0/default.jpg" title="Full resolution image" rel="nofollow"><span
								class="glyphicon glyphicon-download-alt"/> Download full resolution image</a>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="mods:location/mods:url[@access = 'preview']"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="mods:accessCondition">
					<div>
						<h3>Access Condition</h3>
						<xsl:apply-templates select="mods:accessCondition"/>
					</div>
				</xsl:if>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="mods:relatedItem[@type = 'original']">
		<h3>Description</h3>
		<dl class="dl-horizontal">
			<xsl:if test="parent::node()/mods:identifier">
				<dt>Image Number</dt>
				<dd>
					<xsl:value-of select="parent::node()/mods:identifier"/>
				</dd>
			</xsl:if>
			<xsl:if test="string(mods:originInfo/mods:dateCreated)">
				<dt>Date Created</dt>
				<dd>
					<xsl:value-of select="mods:originInfo/mods:dateCreated"/>
				</dd>
			</xsl:if>

			<xsl:if test="string(mods:location/mods:physicalLocation)">
				<dt>Physical Location</dt>
				<dd>
					<xsl:value-of select="mods:location/mods:physicalLocation"/>
				</dd>
			</xsl:if>

			<xsl:apply-templates select="mods:physicalDescription"/>
		</dl>
	</xsl:template>

	<xsl:template match="mods:physicalDescription">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="mods:form | mods:extent | mods:note">
		<dt>
			<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="self::mods:form">
					<a href="{$display_path}results/?q=genreform_facet:&#x022;{.}&#x022;">
						<xsl:value-of select="."/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="@valueURI">
				<xsl:if test="string(@valueURI)">
					<xsl:text> </xsl:text>
					<a href="{@valueURI}" rel="dcterms:type">
						<span class="glyphicon glyphicon-new-window"/>
					</a>
				</xsl:if>
			</xsl:if>
		</dd>
	</xsl:template>

	<xsl:template match="mods:abstract">
		<p property="dcterms:abstract">
			<xsl:value-of select="."/>
		</p>
	</xsl:template>

	<xsl:template match="mods:accessCondition">
		<p>
			<xsl:choose>
				<xsl:when test="mods:url">
					<strong>Rights Statement: </strong>
					<a href="{mods:url}" title="{mods:url}">
						<xsl:choose>
							<xsl:when test="mods:url = 'http://rightsstatements.org/vocab/InC/1.0/'">In Copyright</xsl:when>
							<xsl:when test="mods:url = 'http://rightsstatements.org/vocab/InC-NC/1.0/'">In Copyright - Non-Commercial Use Permitted</xsl:when>
							<xsl:when test="mods:url = 'http://rightsstatements.org/vocab/NoC-CR/1.0/'">No Copyright - Contractual Restrictions</xsl:when>
							<xsl:when test="mods:url = 'http://rightsstatements.org/vocab/NoC-US/1.0/'">No Copyright - United States</xsl:when>
							<xsl:when test="mods:url = 'http://rightsstatements.org/vocab/UND/1.0/'">Copyright Undetermined</xsl:when>
						</xsl:choose>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</p>
	</xsl:template>

	<xsl:template match="mods:name">
		<span>
			<b><xsl:value-of select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/> Name: </b>
			<xsl:value-of select="mods:namePart[1]"/>
			<xsl:if test="mods:namePart[@type = 'date']">
				<xsl:value-of select="mods:namePart[@type = 'date']"/>
			</xsl:if>
		</span>
	</xsl:template>

	<xsl:template match="mods:url">
		<img src="{.}" alt="Photograph" style="max-width:450px"/>
	</xsl:template>

</xsl:stylesheet>
