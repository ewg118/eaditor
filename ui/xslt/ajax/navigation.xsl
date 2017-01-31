<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs ead" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xi="http://www.w3.org/2001/XInclude">
	
	<xsl:variable name="component" select="doc('input:request')/request/parameters/parameter[name='component']/value"/>
	<xsl:param name="mode" select="doc('input:request')/request/parameters/parameter[name='mode']/value"/>
	<xsl:variable name="guide" select="doc('input:request')/request/parameters/parameter[name='guide']/value"/>
	
	<xsl:template match="/">		
		<xsl:apply-templates select="/ead:ead"/>
	</xsl:template>
	
	<xsl:template match="ead:ead">		
		<ul class="{if ($mode='form') then 'list-hidden' else 'list'}" id="{if ($mode='form') then 'component_list' else ''}">
			<xsl:if test="$mode='form'">
				<li style="text-align:center">
					<xsl:choose>
						<xsl:when test="not(string($component))">
							<b>
								<xsl:value-of select="//ead:archdesc/ead:did/ead:unittitle"/>
							</b>
						</xsl:when>
						<xsl:otherwise>
							<a href="../../edit/core/?guide={$guide}">
								<xsl:value-of select="//ead:archdesc/ead:did/ead:unittitle"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</li>
				<li/>
			</xsl:if>
			<xsl:apply-templates select="descendant::ead:dsc/ead:c"/>					
		</ul>
	</xsl:template>
	
	<xsl:template match="ead:c">		
		<li>
			<xsl:choose>
				<xsl:when test="@id = $component">
					<b>
						<xsl:value-of select="ead:did/ead:unittitle"/>
					</b>
				</xsl:when>
				<xsl:otherwise>
					<a href="{if ($mode = 'form') then '../../' else ''}edit/component/?guide={$guide}&amp;component={@id}">
						<xsl:value-of select="ead:did/ead:unittitle"/>
					</a>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="ead:c">
				<ul>
					<xsl:apply-templates select="ead:c"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
</xsl:stylesheet>