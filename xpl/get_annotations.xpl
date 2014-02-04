<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

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

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:include href="../ui/xslt/ajax/get_annotations.xsl"/>
				<xsl:template match="/">					
					<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'eaditor/'), '/')"/>
					<xsl:variable name="doc" select="doc('input:request')/request/parameters/parameter[name='doc']/value"/>
					<xsl:variable name="facsimile" select="doc('input:request')/request/parameters/parameter[name='facsimile']/value"/>
					
					<xsl:apply-templates select="document(concat(/exist-config/url, 'eaditor/', $collection-name, '/guides/', $doc, '.xml'))/*">
						<xsl:with-param name="doc" select="$doc"/>
						<xsl:with-param name="facsimile" select="$facsimile"/>
					</xsl:apply-templates>				
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:text-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>