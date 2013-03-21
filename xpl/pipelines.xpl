<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param name="guide" type="input"/>
	<p:param name="component" type="input"/>
	<p:param name="data" type="output"/>

	<p:processor name="oxf:xslt">
		<p:input name="data" href="#indata"/>
		<p:input name="config" href="../xslt/navigation.xsl"/>
		<p:output name="out" ref="data"/>
	</p:processor>

</p:config>
