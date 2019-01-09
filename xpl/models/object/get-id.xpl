<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					
					<!-- TOC and Navigation in admin panel -->
					<xsl:choose>						
						<xsl:when test="contains(doc('input:request')/request/request-url, 'navigation/') or contains(doc('input:request')/request/request-url, 'toc/')">							
							<xsl:variable name="collection-name" select="doc('input:request')/request/parameters/parameter[name='collection']/value"/>
							<xsl:variable name="recordId" select="doc('input:request')/request/parameters/parameter[name='guide']/value"/>
							
							<config>
								<url>
									<xsl:value-of select="concat(/exist-config/url, 'eaditor/', $collection-name, '/guides/', $recordId, '.xml')"/>
								</url>
								<content-type>application/xml</content-type>
								<encoding>utf-8</encoding>
							</config>
						</xsl:when>
						<xsl:otherwise>
							
							<xsl:variable name="collection-name">
								<xsl:choose>
									<xsl:when test="contains(doc('input:request')/request/request-url, 'eaditor/admin/')">
										<xsl:value-of select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/admin/'), '/')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:variable name="recordId">
								<xsl:choose>
									<!-- favor the doc request parameter first, before id, since the get_annotations API uses it -->
									<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='doc']/value)">
										<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='doc']/value"/>
									</xsl:when>
									<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='id']/value)">
										<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
									</xsl:when>
									<!-- IIIF manifest generation -->
									<xsl:when test="contains(doc('input:request')/request/request-url, 'manifest/')">
										<xsl:variable name="pieces" select="tokenize(substring-after(doc('input:request')/request/request-url, 'manifest/'), '/')"/>
										<xsl:value-of select="$pieces[1]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="doc" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
										
										<xsl:choose>
											<xsl:when test="contains($doc, '.rdf')">
												<xsl:value-of select="substring-before($doc, '.rdf')"/>
											</xsl:when>
											<xsl:when test="contains($doc, '.kml')">
												<xsl:value-of select="substring-before($doc, '.kml')"/>
											</xsl:when>							
											<xsl:when test="contains($doc, '.solr')">
												<xsl:value-of select="substring-before($doc, '.solr')"/>
											</xsl:when>
											<xsl:when test="contains($doc, '.ttl')">
												<xsl:value-of select="substring-before($doc, '.ttl')"/>
											</xsl:when>
											<xsl:when test="contains($doc, '.jsonld')">
												<xsl:value-of select="substring-before($doc, '.jsonld')"/>
											</xsl:when>
											<xsl:when test="contains($doc, '.geojson')">
												<xsl:value-of select="substring-before($doc, '.geojson')"/>
											</xsl:when>
											<xsl:when test="contains($doc, '.xml')">
												<xsl:value-of select="substring-before($doc, '.xml')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$doc"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<config>
								<url>
									<xsl:value-of select="concat(/exist-config/url, 'eaditor/', $collection-name, '/guides/', $recordId, '.xml')"/>
								</url>
								<content-type>application/xml</content-type>
								<encoding>utf-8</encoding>
							</config>
						</xsl:otherwise>
					</xsl:choose>					
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="generator-config"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
