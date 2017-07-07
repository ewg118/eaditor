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

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:choose href="#request">
		<p:when test="contains(//request-url, 'ark:/')">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', ../../../exist-config.xml, #config)"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9">
						<xsl:include href="../../../ui/xslt/controllers/xml-public.xsl"/>
						<xsl:output indent="yes"/>
						<xsl:template match="/">
							<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
							<xsl:variable name="path">
								<xsl:value-of select="substring-after(substring-after(doc('input:request')/request/request-url, 'ark:/'), '/')"/>
							</xsl:variable>
							<xsl:variable name="naan">
								<xsl:if test="contains(doc('input:request')/request/request-url, 'ark:/')">
									<xsl:value-of select="substring-before(substring-after(doc('input:request')/request/request-url, 'ark:/'), '/')"/>
								</xsl:if>
							</xsl:variable>
							<!-- test to be sure naan in the URI matches that in the config -->
							<xsl:choose>
								<xsl:when test="/content/config/ark/naan = $naan">
									
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
											<xsl:when test="contains($doc, '.xml')">
												<xsl:value-of select="substring-before($doc, '.xml')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$doc"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>

									<xsl:apply-templates select="document(concat(/content/exist-config/url, 'eaditor2/', $collection-name, '/guides/', $doc, '.xml'))/*"/>
								</xsl:when>
								<xsl:otherwise>
									<html>
										<head>
											<title>ARK URI Error</title>
										</head>
										<body>
											<h1>ARK URI Error</h1>
											<p>Mismatch between NAAN in the URI and in the EADitor config. Return <a href="{/content/config/url}">home</a>.</p>
										</body>
									</html>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="../../../exist-config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9">
						<xsl:include href="../../../ui/xslt/controllers/xml-public.xsl"/>
						<xsl:output indent="yes"/>
						<xsl:template match="/">
							<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
							<xsl:variable name="path" select="substring-after(doc('input:request')/request/request-url, 'id/')"/>
							<xsl:variable name="id">
								<xsl:choose>
									<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='id']/value)">
										<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
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

							<xsl:apply-templates select="document(concat(/exist-config/url, 'eaditor2/', $collection-name, '/guides/', $id, '.xml'))/*"/>

						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
