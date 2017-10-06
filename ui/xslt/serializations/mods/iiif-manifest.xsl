<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eaditor="https://github.com/ewg118/eaditor"
	xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../../json_metamodel.xsl"/>

	<!-- variables -->
	<xsl:variable name="recordId" select="//mods:recordIdentifier"/>
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
	<!-- read other manifest URI patterns -->
	<xsl:variable name="pieces" select="tokenize(substring-after(doc('input:request')/request/request-url, $recordId), '/')"/>

	<xsl:variable name="manifestUri">
		<xsl:variable name="before" select="tokenize(substring-before(doc('input:request')/request/request-url, concat('/', $recordId)), '/')"/>

		<xsl:choose>
			<xsl:when test="$before[last()] = 'manifest'">
				<xsl:value-of select="concat($url, 'manifest/', $recordId)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($url, 'manifest/', $before[last()], '/', $recordId)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$pieces[2] = 'sequence'">
				<xsl:variable name="model" as="element()*">
					<_object>
						<xsl:call-template name="sequences"/>
					</_object>
				</xsl:variable>
				<xsl:apply-templates select="$model"/>
			</xsl:when>
			<!--<xsl:when test="$pieces[2] = 'list'">
				<xsl:variable name="model" as="element()*">
					<xsl:apply-templates select="descendant::tei:facsimile[@xml:id = $pieces[3]]" mode="AnnotationList"/>
				</xsl:variable>
				<xsl:apply-templates select="$model"/>
			</xsl:when>-->
			<xsl:otherwise>
				<xsl:apply-templates select="//mods:mods"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:mods">
		<!-- construct XML-JSON metamodel inspired by the XForms JSON-XML serialization -->
		<xsl:variable name="model" as="element()*">
			<_object>
				<__context>http://iiif.io/api/presentation/2/context.json</__context>
				<__id>
					<xsl:value-of select="$manifestUri"/>
				</__id>
				<__type>sc:Manifest</__type>
				<attribution>
					<xsl:value-of select="/content/config/publisher"/>
				</attribution>

				<!-- metadata from TEI Header -->
				<label>
					<xsl:value-of select="mods:titleInfo/mods:title"/>
				</label>

				
				<metadata>
					<_array>
						<xsl:apply-templates select="mods:relatedItem"/>
						<xsl:apply-templates select="mods:identifier | mods:subject/*" mode="metadata"/>						
					</_array>
				</metadata>

				<rendering>
					<_object>
						<__id>
							<xsl:value-of select="$objectUri"/>
						</__id>
						<format>text/html</format>
						<label>Full record</label>
					</_object>
				</rendering>

				<seeAlso>
					<_array>
						<_object>
							<__id>
								<xsl:value-of select="concat($objectUri, '.rdf')"/>
							</__id>
							<format>application/rdf+xml</format>
						</_object>
						<!--<_object>
							<__id>
								<xsl:value-of select="concat($objectUri, '.ttl')"/>
							</__id>
							<format>text/turtle</format>
						</_object>
						<_object>
							<__id>
								<xsl:value-of select="concat($objectUri, '.jsonld')"/>
							</__id>
							<format>application/ld+json</format>
						</_object>-->
						<_object>
							<__id>
								<xsl:value-of select="concat($objectUri, '.xml')"/>
							</__id>
							<format>application/xml</format>
							<profile>http://www.loc.gov/mods/v3</profile>
							<label>MODS</label>
						</_object>
					</_array>
				</seeAlso>
				<xsl:call-template name="sequences"/>
				<within>
					<xsl:value-of select="$url"/>
				</within>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>
	
	<xsl:template match="mods:relatedItem">
		<xsl:apply-templates select="mods:originInfo/mods:dateCreated | mods:physicalDescription/*" mode="metadata"/>
	</xsl:template>

	<!-- metadata elements -->
	<xsl:template match="*" mode="metadata">
		<_object>
			<label>
				<xsl:value-of select="eaditor:normalize_fields(local-name(), 'en')"/>
			</label>
			<value>
				<xsl:value-of select="normalize-space(.)"/>
			</value>
		</_object>
	</xsl:template>

	<!-- generate sequence -->
	<xsl:template name="sequences">
		<sequences>
			<_array>
				<_object>
					<__id>
						<xsl:value-of select="concat($manifestUri, '/sequence/default')"/>
					</__id>
					<__type>sc:Sequence</__type>
					<label>Default sequence</label>
					<canvases>
						<_array>
							<xsl:apply-templates select="mods:location[mods:url[@note='IIIFService']]"/>
						</_array>
					</canvases>
					<viewingHint>individuals</viewingHint>
				</_object>
			</_array>
		</sequences>
	</xsl:template>

	<!-- convert facsimiles into canvases -->
	<xsl:template match="mods:location">
		<xsl:variable name="service" select="mods:url[@note='IIIFService']"/>

		<_object>
			<__id>
				<xsl:value-of select="concat($manifestUri, '/canvas/0')"/>
			</__id>
			<__type>sc:Canvas</__type>
			<xsl:if test="mods:url[@access='preview']">
				<thumbnail>
					<_object>
						<__id>
							<xsl:value-of select="mods:url[@access='preview']"/>
						</__id>
						<__type>dctypes:Image</__type>
						<format>image/jpeg</format>
					</_object>
				</thumbnail>
			</xsl:if>

			<height>
				<xsl:value-of select="doc('input:images')//image[@uri = $service]/json/height"/>
			</height>
			<width>
				<xsl:value-of select="doc('input:images')//image[@uri = $service]/json/width"/>
			</width>
			
			<images>
				<_array>
					<xsl:apply-templates select="mods:url[@note = 'IIIFService']"/>
				</_array>
			</images>
		</_object>
	</xsl:template>

	<xsl:template match="mods:url[@note = 'IIIFService']">
		<xsl:variable name="service" select="."/>

		<_object>
			<__id>
				<xsl:value-of select="concat($manifestUri, '/annotation/0')"/>
			</__id>
			<__type>oa:Annotation</__type>
			<motivation>sc:painting</motivation>
			<on>
				<xsl:value-of select="concat($manifestUri, '/canvas/0')"/>
			</on>
			<resource>
				<_object>
					<__id>
						<xsl:value-of select="concat($service, '/full/full/0/default.jpg')"/>
					</__id>
					<__type>dctypes:Image</__type>
					<format>image/jpeg</format>
					<height>
						<xsl:value-of select="doc('input:images')//image[@uri = $service]/json/height"/>
					</height>
					<width>
						<xsl:value-of select="doc('input:images')//image[@uri = $service]/json/width"/>
					</width>
					<service>
						<_object>
							<__context>http://iiif.io/api/image/2/context.json</__context>
							<__id>
								<xsl:value-of select="$service"/>
							</__id>
							<profile>http://iiif.io/api/image/2/level2.json</profile>
						</_object>
					</service>
				</_object>
			</resource>
		</_object>
	</xsl:template>
</xsl:stylesheet>
