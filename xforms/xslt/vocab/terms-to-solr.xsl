<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
	Transform the controlled access terms returned from eXist and display as a unnumbered list -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ead="urn:isbn:1-931666-22-9">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:param name="solr-url">
		<xsl:text>http://localhost:8080/solr/eaditor-vocabularies/</xsl:text>
	</xsl:param>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates
				select="descendant::ead:corpname | descendant::ead:famname | descendant::ead:genreform | descendant::ead:geogname | descendant::ead:persname | descendant::ead:subject"
			/>
		</add>
	</xsl:template>

	<xsl:template match="ead:corpname | ead:famname | ead:genreform | ead:geogname | ead:persname | ead:subject">

		<xsl:variable name="query"
			select="concat($solr-url, 'select?q=', name(), ':%22', encode-for-uri(normalize-space(.)), '%22%20AND%20source:LCSH')"/>
		<xsl:variable name="position" select="position()"/>
		<xsl:variable name="name" select="name()"/>

		<xsl:if
			test="document($query)//result[@name='response']/@numFound = '0' and normalize-space(preceding-sibling::node()[position() = $position - 1]) != normalize-space(text())">
			<doc>
				<field name="id">
					<xsl:choose>
						<xsl:when test="@id">
							<xsl:value-of select="concat(name(), '_', @id)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat(name(), '_', generate-id(.))"/>
						</xsl:otherwise>
					</xsl:choose>
				</field>
				<field name="{name()}">
					<xsl:value-of select="normalize-space(.)"/>
				</field>
				<field name="source">local</field>
			</doc>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
