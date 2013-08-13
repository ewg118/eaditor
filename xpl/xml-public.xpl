<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request/request-url</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../exist-url.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9">
				<xsl:include href="../ui/xslt/xml-public.xsl"/>
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="path" select="substring-after(doc('input:request')/request/request-url, 'id/')"/>
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

					<xsl:choose>
						<xsl:when test="string($id)">
							<ead xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="urn:isbn:1-931666-22-9">
								<xsl:apply-templates select="document(concat(/exist-url, 'eaditor/guides/', $doc, '.xml'))/descendant::ead:c[@id=$id]"/>
							</ead>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="document(concat(/exist-url, 'eaditor/guides/', $doc, '.xml'))/*"/>
						</xsl:otherwise>
					</xsl:choose>
					
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
	

</p:config>
