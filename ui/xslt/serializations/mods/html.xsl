<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9"
	xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xlink="http://www.w3.org/1999/xlink"
	version="2.0">
	
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
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="mode">
		<xsl:choose>
			<xsl:when test="contains($uri, 'admin/')">private</xsl:when>
			<xsl:otherwise>public</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	
	<xsl:template match="/">
		<xsl:apply-templates select="/content//mods:mods"/>
	</xsl:template>
	
	<xsl:template match="mods:mods">
		<html>
			<head prefix="dcterms: http://purl.org/dc/terms/     foaf: http://xmlns.com/foaf/0.1/     owl:  http://www.w3.org/2002/07/owl#     rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
				skos: http://www.w3.org/2004/02/skos/core#     dcterms: http://purl.org/dc/terms/     arch: http://purl.org/archival/vocab/arch#     xsd: http://www.w3.org/2001/XMLSchema#">
				<title id="{$path}">
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="mods:titleInfo/mods:title"/>
				</title>
				<!-- alternates -->
				<link rel="alternate" type="text/xml" href="{$path}.xml"/>
				<link rel="alternate" type="application/rdf+xml" href="{$path}.rdf"/>
				
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<!-- include fancybox -->
				<link rel="stylesheet" href="{$include_path}ui/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}ui/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<link rel="stylesheet" href="{$include_path}ui/css/style.css"/>
				
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<div class="container-fluid">
					<xsl:call-template name="mods-content"/>
				</div>
				<div id="path" style="display:none">../</div>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="mods-content">
		<div class="row">
			<div class="col-md-12">
				<h1>
					<xsl:value-of select="mods:titleInfo/mods:title"/>
				</h1>
			</div>
			<div class="col-md-6">
				<xsl:apply-templates select="mods:name"/>
				<xsl:if test="string(mods:abstract)">
					<p>
						<xsl:value-of select="mods:abstract"/>
					</p>
				</xsl:if>
				<h2>Description of Digital Image</h2>
				<dl class="dl-horizontal">
					<dt>Image Number</dt>
					<dd>
						<xsl:value-of select="mods:identifier"/>
					</dd>
					<xsl:apply-templates select="mods:physicalDescription/mods:form"/>					
				</dl>

				<h2>Description of Original Item</h2>
				<dl class="dl-horizontal">
					<xsl:if test="string(mods:relatedItem/mods:originInfo/mods:dateCreated)">
						<dt>Date Created</dt>
						<dd>
							<xsl:value-of select="mods:relatedItem/mods:originInfo/mods:dateCreated"
							/>
						</dd>
					</xsl:if>
					<xsl:apply-templates select="mods:relatedItem/mods:physicalDescription/mods:form"/>					
					<xsl:if test="string(mods:relatedItem/mods:physicalDescription/mods:extent)">
						<dt>Extent</dt>
						<dd>
							<xsl:value-of
								select="mods:relatedItem/mods:physicalDescription/mods:extent"/>
						</dd>
					</xsl:if>
					<xsl:if test="string(mods:relatedItem/mods:location/mods:physicalLocation)">
						<dt>Physical Location</dt>
						<dd>
							<xsl:value-of
								select="mods:relatedItem/mods:location/mods:physicalLocation"/>
						</dd>
					</xsl:if>
					<xsl:if test="string(mods:relatedItem/mods:physicalDescription/mods:note)">
						<dt>Note</dt>
						<dd>
							<xsl:value-of
								select="mods:relatedItem/mods:physicalDescription/mods:note"/>
						</dd>
					</xsl:if>
				</dl>
				<xsl:if test="count(mods:subject/mods:topic) &gt; 0">
					<h2>Subjects</h2>
					<dl class="dl-horizontal">
						<xsl:for-each select="mods:subject/*">
							<dt>
								<xsl:choose>
									<xsl:when test="local-name()='genre'">Genre</xsl:when>	
									<xsl:when test="local-name()='geographic'">Geographic</xsl:when>									
									<xsl:when test="local-name()='name'">
										<xsl:choose>
											<xsl:when test="@type='personal'">Person</xsl:when>
											<xsl:when test="@type='corporate'">Corporate</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="local-name()='occupation'">Occupation</xsl:when>
									<xsl:when test="local-name()='topic'">Subject</xsl:when>									
								</xsl:choose>
							</dt>
							<dd>
								<xsl:variable name="facet">
									<xsl:choose>
										<xsl:when test="local-name()='genre'">genreform</xsl:when>	
										<xsl:when test="local-name()='geographic'">geogname</xsl:when>									
										<xsl:when test="local-name()='name'">
											<xsl:choose>
												<xsl:when test="@type='personal'">persname</xsl:when>
												<xsl:when test="@type='corporate'">corpname</xsl:when>
											</xsl:choose>
										</xsl:when>
										<xsl:when test="local-name()='occupation'">occupation</xsl:when>
										<xsl:when test="local-name()='topic'">subject</xsl:when>									
									</xsl:choose>
								</xsl:variable>
								<a href="{$display_path}results/?q={$facet}_facet:&#x022;{.}&#x022;">
									<xsl:value-of select="if (mods:namePart) then mods:namePart else ."/>
								</a>
								<xsl:if test="string(@valueURI)">
									<a href="{@valueURI}" rel="dcterms:subject">
										<img src="{$include_path}ui/images/external.png" alt="external link" class="external_link"/>
									</a>
								</xsl:if>
							</dd>
						</xsl:for-each>
					</dl>
				</xsl:if>
				<xsl:if test="mods:accessCondition">
					<p>
						<b>Access Condition: </b>
						<xsl:value-of select="mods:accessCondition"/>
					</p>
				</xsl:if>
				<xsl:if test="mods:note[@type='preferred_citation']">
					<p>
						<b>Preferred Citation: </b>
						<xsl:value-of select="mods:note[@type='preferred_citation']"/>
					</p>
				</xsl:if>
				<p><b>Photo Access: </b>ANS staff can log in to Staff View to see the image. Outside
					researchers please contact the ANS Archivist.</p>
			</div>
			<div class="col-md-6">
				<xsl:apply-templates select="mods:location/mods:url[@usage='primary display']"/>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="mods:form">
		<dt>Form</dt>
		<dd>
			<a
				href="{$display_path}results/?q=genreform_facet:&#x022;{.}&#x022;">
				<xsl:value-of
					select="."/>
			</a>
			<xsl:if test="string(@valueURI)">
				<a href="{@valueURI}" rel="dcterms:format">
					<img src="{$include_path}ui/images/external.png" alt="external link" class="external_link"/>
				</a>
			</xsl:if>
		</dd>
	</xsl:template>

	<xsl:template match="mods:name">
		<span>
			<b><xsl:value-of
					select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/> Name: </b>
			<xsl:value-of select="mods:namePart[1]"/>
			<xsl:if test="mods:namePart[@type='date']">
				<xsl:value-of select="mods:namePart[@type='date']"/>
			</xsl:if>
		</span>
	</xsl:template>

	<xsl:template match="mods:url">
		<img src="{.}" alt="Photograph" style="max-width:450px"/>
	</xsl:template>

</xsl:stylesheet>
