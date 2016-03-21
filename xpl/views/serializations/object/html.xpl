<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:choose href="#data">
		<p:when test="/*[namespace-uri()='urn:isbn:1-931666-22-9']">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../ead/html.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="/*[namespace-uri()='http://www.loc.gov/mods/v3']">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../mods/html.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="/*[namespace-uri()='http://www.tei-c.org/ns/1.0']">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../tei/html.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>		
	</p:choose>
</p:config>