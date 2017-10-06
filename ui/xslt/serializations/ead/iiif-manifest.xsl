<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eaditor="https://github.com/ewg118/eaditor"
	xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../../json_metamodel.xsl"/>

	<!-- variables -->
	<xsl:variable name="eadid" select="/content/ead:ead/ead:eadheader/ead:eadid"/>
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
	<!-- read other manifest URI patterns -->
	<xsl:variable name="pieces" select="tokenize(substring-after(doc('input:request')/request/request-url, $eadid), '/')"/>

	<xsl:variable name="manifestUri">
		<xsl:variable name="before" select="tokenize(substring-before(doc('input:request')/request/request-url, concat('/', $eadid)), '/')"/>

		<xsl:choose>
			<xsl:when test="$before[last()] = 'manifest'">
				<xsl:value-of select="concat($url, 'manifest/', $eadid)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($url, 'manifest/', $before[last()], '/', $eadid)"/>
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
				<xsl:apply-templates select="//ead:ead"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ead:ead">
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
				<xsl:apply-templates select="ead:archdesc"/>

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
							<profile>urn:isbn:1-931666-22-9</profile>
							<label>EAD</label>
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

	<xsl:template match="ead:archdesc">
		<xsl:apply-templates select="ead:did"/>
	</xsl:template>

	<xsl:template match="ead:did">
		<!-- title and description -->
		<xsl:apply-templates select="ead:unittitle"/>

		<xsl:choose>
			<xsl:when test="parent::ead:archdesc">
				<xsl:choose>
					<xsl:when test="ead:abstract">
						<xsl:apply-templates select="ead:abstract"/>
					</xsl:when>
					<xsl:when test="parent::node()/ead:scopecontent">
						<xsl:apply-templates select="parent::node()/ead:scopecontent"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="ead:abstract">
						<xsl:apply-templates select="ead:abstract"/>
					</xsl:when>
					<xsl:when test="parent::node()/ead:daogrp/ead:daodesc">
						<xsl:apply-templates select="parent::node()/ead:daogrp/ead:daodesc"/>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

		<!-- metadata -->
		<metadata>
			<_array>
				<xsl:apply-templates select="ead:unitdate | ead:unitid | ead:repository | ead:physdesc/ead:extent | ead:origination" mode="metadata"/>
				<xsl:if test="parent::ead:c">
					<xsl:apply-templates select="parent::node()/ead:controlaccess/*" mode="metadata"/>
				</xsl:if>
			</_array>
		</metadata>
	</xsl:template>

	<xsl:template match="ead:unittitle">
		<label>
			<xsl:value-of select="normalize-space(.)"/>
		</label>
	</xsl:template>

	<xsl:template match="ead:abstract | ead:scopecontent | ead:daodesc">
		<description>
			<xsl:choose>
				<xsl:when test="ead:p">
					<xsl:apply-templates select="ead:p"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</description>
	</xsl:template>

	<xsl:template match="ead:p">
		<xsl:value-of select="normalize-space(.)"/>
		<xsl:if test="not(position() = last())">
			<xsl:text>\n</xsl:text>
		</xsl:if>
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
							<xsl:apply-templates select="descendant::ead:c[@level = 'item'][descendant::ead:daoloc[@xlink:role = 'IIIFService']]"/>
						</_array>
					</canvases>
					<viewingHint>individuals</viewingHint>
				</_object>
			</_array>
		</sequences>
	</xsl:template>

	<!-- convert facsimiles into canvases -->
	<xsl:template match="ead:c[@level = 'item']">
		<xsl:variable name="service" select="ead:daogrp/ead:daoloc[@xlink:role = 'IIIFService']/@xlink:href"/>

		<_object>
			<__id>
				<xsl:value-of select="concat($manifestUri, '/canvas/', @id)"/>
			</__id>
			<__type>sc:Canvas</__type>

			<!-- metadata -->
			<xsl:apply-templates select="ead:did"/>

			<xsl:if test="ead:daogrp/ead:daoloc[@xlink:role = 'thumbnail']">
				<thumbnail>
					<_object>
						<__id>
							<xsl:value-of select="ead:daogrp/ead:daoloc[@xlink:role = 'thumbnail']/@xlink:href"/>
						</__id>
						<__type>dctypes:Image</__type>
						<format>image/jpeg</format>
						<height>120</height>
						<width>120</width>
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
					<xsl:apply-templates select="ead:daogrp/ead:daoloc[@xlink:role = 'IIIFService']">
						<xsl:with-param name="id" select="@id"/>
					</xsl:apply-templates>
				</_array>
			</images>
		</_object>
	</xsl:template>

	<xsl:template match="ead:daoloc[@xlink:role = 'IIIFService']">
		<xsl:param name="id"/>
		<xsl:variable name="service" select="@xlink:href"/>

		<_object>
			<__id>
				<xsl:value-of select="concat($manifestUri, '/annotation/', $id)"/>
			</__id>
			<__type>oa:Annotation</__type>
			<motivation>sc:painting</motivation>
			<on>
				<xsl:value-of select="concat($manifestUri, '/canvas/', $id)"/>
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
