<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config" href="../xforms/xslt/vocab/agencycodes.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>

</p:config>
