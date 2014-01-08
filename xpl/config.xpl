<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
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
		<p:input name="data" href="../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<xsl:variable name="collection-name">
						<xsl:choose>
							<xsl:when test="contains(doc('input:request')/request/servlet-path, 'admin/')">
								<xsl:value-of select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'eaditor/admin/'), '/')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'eaditor/'), '/')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>					
					<xsl:copy-of select="document(concat(/exist-config/url, 'eaditor/', $collection-name, '/config.xml'))"/>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>


</p:config>
