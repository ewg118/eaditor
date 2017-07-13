<?xml version="1.0" encoding="UTF-8"?>
<!--
	Function: This XPL calls an XSLT stylesheet to process RDF following the archival model dumped by a DESCRIBE query from the archival triplestore into Pelagios-compliant RDF
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="aggregate('content', #data, #config)"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/rdf/rdf-pelagios.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>

	<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/rdf+xml</content-type>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>

</p:config>
