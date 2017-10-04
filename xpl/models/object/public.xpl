<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="get-id.xpl"/>
		<p:output name="data" id="xml"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#xml"/>
		<p:input name="config" href="../../../ui/xslt/controllers/xml-public.xsl"/>					
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
