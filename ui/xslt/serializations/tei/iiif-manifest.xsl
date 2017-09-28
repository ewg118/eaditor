<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eaditor="https://github.com/ewg118/eaditor"
	xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../../json_metamodel.xsl"/>

	<!-- variables -->
	<xsl:variable name="id" select="/content/tei:TEI/@xml:id"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="objectUri">
		<xsl:choose>
			<xsl:when test="//config/ark[@enabled = 'true']">
				<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', $id)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($url, 'id/', $id)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- read other manifest URI patterns -->
	<xsl:variable name="pieces" select="tokenize(substring-after(doc('input:request')/request/request-url, $id), '/')"/>

	<xsl:variable name="manifestUri">
		<xsl:variable name="before" select="tokenize(substring-before(doc('input:request')/request/request-url, concat('/', $id)), '/')"/>

		<xsl:choose>
			<xsl:when test="$before[last()] = 'manifest'">
				<xsl:value-of select="concat($url, 'manifest/', $id)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($url, 'manifest/', $before[last()], '/', $id)"/>
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
			<xsl:when test="$pieces[2] = 'list'">
				<xsl:variable name="model" as="element()*">
					<xsl:apply-templates select="descendant::tei:facsimile[@xml:id = $pieces[3]]" mode="AnnotationList"/>
				</xsl:variable>
				<xsl:apply-templates select="$model"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="//tei:TEI"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:TEI">
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
				<xsl:apply-templates select="tei:teiHeader"/>

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
						<_object>
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

	<xsl:template match="tei:teiHeader">
		<label>
			<xsl:value-of select="tei:fileDesc/tei:titleStmt/tei:title"/>
		</label>
		<!-- generate description from obverse and reverse -->
		<xsl:if test="tei:fileDesc/tei:noteStmt/tei:note[@type = 'abstract']">
			<description>
				<xsl:apply-templates select="tei:fileDesc/tei:noteStmt/tei:note[@type = 'abstract']/tei:p"/>
			</description>
		</xsl:if>

		<!-- extract metadata from descMeta -->
		<!--<metadata>
			<_array>
				<xsl:apply-templates select="$nudsGroup//nuds:typeDesc | nuds:descMeta/nuds:physDesc | nuds:descMeta/nuds:adminDesc"/>
			</_array>
		</metadata>-->
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
							<xsl:apply-templates select="descendant::tei:facsimile"/>
						</_array>
					</canvases>
					<viewingHint>individuals</viewingHint>
				</_object>
			</_array>
		</sequences>
	</xsl:template>

	<!-- convert facsimiles into canvases -->
	<xsl:template match="tei:facsimile">
		<xsl:variable name="service" select="tei:media/@url"/>

		<_object>
			<__id>
				<xsl:value-of select="concat($manifestUri, '/canvas/', @xml:id)"/>
			</__id>
			<__type>sc:Canvas</__type>
			<label>
				<xsl:value-of select="
						if (tei:media/@n) then
						tei:media/@n
						else
							@xml:id"/>
			</label>
			<thumbnail>
				<_object>
					<__id>
						<xsl:value-of select="concat($service, '/full/!120,120/0/default.jpg')"/>
					</__id>
					<__type>dctypes:Image</__type>
					<format>image/jpeg</format>
					<height>120</height>
					<width>120</width>
				</_object>
			</thumbnail>
			<height>
				<xsl:value-of select="substring-before(tei:media/@height, 'px')"/>
			</height>
			<width>
				<xsl:value-of select="substring-before(tei:media/@width, 'px')"/>
			</width>
			<images>
				<_array>
					<xsl:apply-templates select="tei:media"/>
				</_array>
			</images>
			<xsl:if test="tei:surface">
				<otherContent>
					<_array>
						<_object>
							<__id>
								<xsl:value-of select="concat($manifestUri, '/list/', @xml:id)"/>
							</__id>
							<__type>sc:AnnotationList</__type>
						</_object>
					</_array>
				</otherContent>
			</xsl:if>
		</_object>
	</xsl:template>

	<xsl:template match="tei:media">
		<xsl:variable name="service" select="@url"/>

		<_object>
			<__id>
				<xsl:value-of select="concat($manifestUri, '/annotation/', parent::node()/@xml:id)"/>
			</__id>
			<__type>oa:Annotation</__type>
			<motivation>sc:painting</motivation>
			<on>
				<xsl:value-of select="concat($manifestUri, '/canvas/', parent::node()/@xml:id)"/>
			</on>
			<resource>
				<_object>
					<__id>
						<xsl:value-of select="concat($service, '/full/full/0/default.jpg')"/>
					</__id>
					<__type>dctypes:Image</__type>
					<format>image/jpeg</format>
					<height>
						<xsl:value-of select="substring-before(@height, 'px')"/>
					</height>
					<width>
						<xsl:value-of select="substring-before(@width, 'px')"/>
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

	<!-- generate an AnnotationList from tei:facsimile -->
	<xsl:template match="tei:facsimile" mode="AnnotationList">
		<xsl:variable name="service" select="tei:media/@url"/>

		<_object>
			<__id>
				<xsl:value-of select="concat($manifestUri, '/list/', @xml:id)"/>
			</__id>
			<__type>sc:AnnotationList</__type>
			<resources>
				<_array>
					<xsl:apply-templates select="tei:surface" mode="AnnotationList"/>
				</_array>
			</resources>
		</_object>
	</xsl:template>

	<xsl:template match="tei:surface" mode="AnnotationList">
		<_object>
			<__id>
				<xsl:value-of select="concat('_:', @xml:id)"/>
			</__id>
			<__type>oa:Annotation</__type>
			<motiviation>sc:painting</motiviation>
			<resource>
				<_object>
					<__id>
						<xsl:value-of select="concat('_:', @xml:id, '#', position())"/>
					</__id>
					<__type>cnt:ContentAsText</__type>
					<chars>
						<xsl:apply-templates select="tei:desc"/>
					</chars>
					<format>text/html</format>
					<language>en</language>
				</_object>
			</resource>
			<on>
				<xsl:value-of select="concat($manifestUri, '/list/', parent::node()/@xml:id, '#xywh=', @ulx, ',', @uly, ',', @lrx - @ulx, ',', @lry - @uly)"/>
			</on>
		</_object>
	</xsl:template>

	<xsl:template match="tei:desc">
		<xsl:apply-templates mode="anno"/>
	</xsl:template>

	<xsl:template match="tei:ref" mode="anno">
		<xsl:variable name="link">
			<![CDATA[<a href=']]><xsl:value-of select="@target"/><![CDATA[' target='_blank'>]]><xsl:value-of select="."/><![CDATA[</a>]]>
		</xsl:variable>

		<xsl:value-of select="normalize-space($link)"/>
	</xsl:template>

</xsl:stylesheet>
