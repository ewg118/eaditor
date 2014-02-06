<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<p:param type="input" name="file"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#file"/>
		<p:output name="data" id="url-data"/>
	</p:processor>

	<!-- The exception catcher behaves like the identity processor if there is no exception -->
	<!-- However if there is an exception, it catches it, and you get a serialized form of the exception -->
	<p:processor name="oxf:exception-catcher">
		<p:input name="data" href="#url-data"/>
		<p:output name="data" id="url-data-checked"/>
	</p:processor>

	<!-- Check whether we had an exception -->
	<p:choose href="#url-data-checked">
		<p:when test="/exceptions">
			<!-- Extract the message -->
			<p:processor name="oxf:xslt">
				<p:input name="data" href="#url-data-checked"/>
				<p:input name="config">
					<message xsl:version="2.0">error</message>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<!-- Just return the document -->
			<p:processor name="oxf:identity">
				<p:input name="data" href="#url-data-checked"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:pipeline>
