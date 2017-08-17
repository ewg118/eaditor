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
		<p:input name="data" href="../../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="concat(/exist-config/url, 'eaditor/config.xml')"/>							
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="master-generator"/>
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#master-generator"/>
		<p:output name="data" id="master-config"/>
	</p:processor>
	
	<p:choose href="#master-config">
		<p:when test="/config/aggregator='true'">
			<p:processor name="oxf:identity">
				<p:input name="data" href="#master-config"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>		
				<p:input name="data" href="../../exist-config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:template match="/">
							<xsl:variable name="collection-name">
								<xsl:choose>
									<xsl:when test="contains(doc('input:request')/request/request-url, 'admin/')">
										<xsl:value-of select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/admin/'), '/')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>	
							
							<config>
								<url>
									<xsl:value-of select="concat(/exist-config/url, 'eaditor/', $collection-name, '/config.xml')"/>									
								</url>
								<content-type>application/xml</content-type>
								<encoding>utf-8</encoding>
							</config>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="generator-config"/>
			</p:processor>
			
			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#generator-config"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
