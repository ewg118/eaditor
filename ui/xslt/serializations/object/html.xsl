<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../ead/html.xsl"/>
	<xsl:include href="../ead/html-templates.xsl"/>
	<xsl:include href="../mods/html.xsl"/>
	<xsl:include href="../tei/html.xsl"/>
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- path and document params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'eaditor/'), '/')"/>
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
	<xsl:variable name="ui-theme" select="/content/config/theme/jquery_ui_theme"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<!-- display path -->
	<xsl:variable name="display_path">
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
	<xsl:variable name="include_path">
		<xsl:choose>
			<xsl:when test="$mode='private'">
				<xsl:choose>
					<xsl:when test="string($id)">
						<xsl:text>../../../../</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>../../../</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="contains($uri, 'ark:/')">
						<xsl:choose>
							<xsl:when test="string($id)">
								<xsl:text>../../../../</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>../../../</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="string($id)">
								<xsl:text>../../../</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>../../</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- boolean variable as to whether there are mappable points -->
	<xsl:variable name="hasPoints" select="boolean(descendant::ead:geogname[string(@authfilenumber) and string(@source)])"/>

	<!-- url params -->
	<xsl:param name="lang" select="doc('input:params')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="mode">
		<xsl:choose>
			<xsl:when test="contains($uri, 'admin/')">private</xsl:when>
			<xsl:otherwise>public</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/*[not(local-name()='config')]" mode="root"/>
	</xsl:template>

	<xsl:template match="*" mode="root">
		<html>
			<head prefix="dcterms: http://purl.org/dc/terms/
				foaf: http://xmlns.com/foaf/0.1/
				owl:  http://www.w3.org/2002/07/owl#
				rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
				skos: http://www.w3.org/2004/02/skos/core#
				dcterms: http://purl.org/dc/terms/
				arch: http://purl.org/archival/vocab/arch#
				xsd: http://www.w3.org/2001/XMLSchema#">
				<title id="{$path}">
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:choose>
						<xsl:when test="string(ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper)">
							<xsl:value-of select="ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper"/>
						</xsl:when>
						<xsl:when test="string(ead:did/ead:unittitle)">
							<xsl:value-of select="ead:did/ead:unittitle"/>
						</xsl:when>
						<xsl:when test="string(mods:titleInfo/mods:title)">
							<xsl:value-of select="mods:titleInfo/mods:title"/>
						</xsl:when>
						<xsl:when test="string(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)">
							<xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
						</xsl:when>
					</xsl:choose>
				</title>
				<!-- alternates -->
				<link rel="alternate" type="text/xml" href="{$path}.xml"/>
				<link rel="alternate" type="application/rdf+xml" href="{$path}.rdf"/>
				
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet"
					href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>
				
				<!-- add annotorious for TEI files: must be added before jquery to resolve conflicts -->
				<xsl:if test="namespace-uri()='http://www.tei-c.org/ns/1.0'">
					<link type="text/css" rel="stylesheet" href="http://annotorious.github.com/latest/annotorious.css"/>
					<script src="http://www.openlayers.org/api/OpenLayers.js" type="text/javascript"/>
					<script type="text/javascript" src="http://annotorious.github.com/latest/annotorious.min.js"/> 
				</xsl:if>
				<script type="text/javascript" src="{$include_path}ui/javascript/display_functions.js"/>
				<!-- include annotation functions for TEI files -->
				<xsl:if test="namespace-uri()='http://www.tei-c.org/ns/1.0'">
					<!--<script type="text/javascript" src="{$include_path}ui/javascript/jquery.livequery.js"/>-->
					<script type="text/javascript" src="{$include_path}ui/javascript/display_annotation_functions.js"/> 
				</xsl:if>
				<xsl:if test="$hasPoints = true()">
					<!-- mapping -->
					<!--<link type="text/css" href="{$include_path}ui/css/timeline-2.3.0.css" rel="stylesheet"/>-->
					<script src="http://www.openlayers.org/api/OpenLayers.js" type="text/javascript"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/mxn.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/timeline-2.3.0.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/timemap_full.pack.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/param.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/loaders/xml.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/loaders/kml.js"/>
					<script type="text/javascript" src="{$include_path}ui/javascript/display_map_functions.js"/>
				</xsl:if>			
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:choose>
					<xsl:when test="namespace-uri()='http://www.loc.gov/mods/v3'">
						<xsl:call-template name="mods-content"/>
					</xsl:when>
					<xsl:when test="namespace-uri()='urn:isbn:1-931666-22-9'">
						<xsl:call-template name="ead-content"/>
					</xsl:when>
					<xsl:when test="namespace-uri()='http://www.tei-c.org/ns/1.0'">
						<xsl:call-template name="tei-content"/>
					</xsl:when>
				</xsl:choose>
				<div id="path" style="display:none">
					<xsl:value-of select="$display_path"/>
				</div>				
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
