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
	
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#data"/>		
		<p:input name="config" href="../../../xforms/xslt/import/files-to-csv.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>text/csv</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>