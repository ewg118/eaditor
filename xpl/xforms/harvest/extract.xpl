<?xml version="1.0" encoding="UTF-8"?>
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
		<p:input name="data" href="../../../exist-config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="concat(/exist-config/url, 'eaditor/harvesters.xml')"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="harvesters-generator"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#harvesters-generator"/>
		<p:output name="data" id="harvesters"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#harvesters"/>
		<p:input name="request" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:variable name="agencycode" select="doc('input:request')/request/parameters/parameter[name='agencycode']/value"/>

				<xsl:template match="/">
					<xsl:copy-of select="descendant::harvester[@collection=$agencycode]"/>					
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="harvester"/>
	</p:processor>
	
	<p:choose href="#harvester">
		<p:when test="/harvester/@type='directory'">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#harvester"/>
				
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						
						<xsl:template match="/harvester">
							<xforms:submission method="get" action="/eaditor/admin/parse-html?url={@url}">
								<xforms:header>
									<xforms:name>User-Agent</xforms:name>
									<xforms:value>XForms/EADitor</xforms:value>
								</xforms:header>
							</xforms:submission>				
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<!--<p:output name="data" id="xforms-config"/>-->
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="/harvester/@type='oai'">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#harvester"/>
				
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						
						<xsl:template match="/harvester">
							<xforms:submission method="get" action="{@url}">
								<xforms:header>
									<xforms:name>User-Agent</xforms:name>
									<xforms:value>XForms/EADitor</xforms:value>
								</xforms:header>
							</xforms:submission>				
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<!--<p:output name="data" id="xforms-config"/>-->
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
	</p:choose>

</p:pipeline>
