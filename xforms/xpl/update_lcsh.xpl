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

	<p:processor name="oxf:xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<!-- This is the stylesheet to pass parameters to -->
				<xsl:import href="../xforms/xslt/vocab/update-lcsh.xsl"/>
				<!-- Here we assign a value to the "start" parameter -->
				<xsl:param name="date">
					<xsl:choose>
						<xsl:when test="contains(document('http://localhost:8080/orbeon/exist/rest/db/eaditor/config.xml')//lcsh-date, 'T')">
							<xsl:value-of select="substring-before(document('http://localhost:8080/orbeon/exist/rest/db/eaditor/config.xml')//lcsh-date, 'T')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="document('http://localhost:8080/orbeon/exist/rest/db/eaditor/config.xml')//lcsh-date"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:param>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>

</p:config>
