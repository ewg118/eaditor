<?xml version="1.0" encoding="UTF-8"?>

<!-- this XPL is simply an interface to the PHP call through cgi-bin in Apache -->

<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:xxforms="http://orbeon.org/oxf/xml/xforms">

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
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:param name="url" select="/request/parameters/parameter[name='url']/value"/>
				<xsl:param name="from" select="/request/parameters/parameter[name='from']/value"/>
				
				<xsl:template match="/">
					<config>
						<url>
							<xsl:text>http://localhost/cgi-bin/parse-html.php?url=</xsl:text>
							<xsl:value-of select="encode-for-uri($url)"/>
							<xsl:if test="$from castable as xs:date">
								<xsl:text>&amp;from=</xsl:text>
								<xsl:value-of select="$from"/>
							</xsl:if>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="url-generator"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>
