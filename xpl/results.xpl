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
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>				
		<p:input name="data" href="aggregate('content', #data, #config)"/>		
		<p:input name="config" href="../ui/xslt/results.xsl"/>
		<p:output name="data" ref="data"/>
		<!--<p:output name="data" id="model"/>-->
	</p:processor>
	
	<!--<p:processor name="oxf:html-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<public-doctype>-//W3C//DTD HTML 4.01//EN</public-doctype>
				<system-doctype>http://www.w3.org/TR/html4/strict.dtd</system-doctype>
				<omit-xml-declaration>false</omit-xml-declaration>
				<content-type>application/xhtml+xml</content-type>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>-->
</p:config>
