<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9">

	<p:param name="data" type="input"/>
	<p:param name="data" type="output"/>

	<p:processor name="oxf:xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0">
				<xsl:import href="../xforms/xslt/vocab/formatting.xsl"/>
				<xsl:param name="name" select="name(//report/*[1])"/>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>

</p:config>
