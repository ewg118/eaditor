<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<!--<p:param type="input" name="data"/>-->
	<p:param type="output" name="data"/>

	<!--<p:processor name="oxf:xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config" href="xslt/import/dtd2schema.xsl"/>
		<p:output name="data" id="step2"/>
	</p:processor>-->
	

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request/parameters</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	<p:processor name="oxf:xslt">
		<p:input name="data" href="http://localhost:8080/orbeon/exist/rest/db/eaditor/guides/"/>
		<p:input name="request" href="#request"/>
		<p:input name="config" href="../xslt/file_list.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>
	

</p:config>
