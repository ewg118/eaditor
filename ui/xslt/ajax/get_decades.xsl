<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs eaditor xs xi" version="2.0"
	xmlns:xi="http://www.w3.org/2001/XInclude" xmlns="http://www.w3.org/1999/xhtml" xmlns:eaditor="https://github.com/ewg118/eaditor">
	<xsl:output method="xml" encoding="UTF-8"/>
	<!-- URL parameters -->
	<xsl:param name="q" select="doc('input:params')/request/parameters/parameter[name='q']/value"/>	
	<xsl:param name="century" select="doc('input:params')/request/parameters/parameter[name='century']/value"/>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>test</title>
			</head>
			<body>
				<ul>
					<xsl:apply-templates select="/response//lst[@name='decade_num']"/>
				</ul>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="lst[@name='decade_num']">
		<xsl:for-each select="int[$century = substring(@name, 1, 2)]">
			<li>
				<xsl:choose>
					<xsl:when test="contains($q, concat('decade_num:', @name))">
						<input type="checkbox" value="{@name}" checked="checked" class="decade_checkbox"/>
					</xsl:when>
					<xsl:otherwise>
						<input type="checkbox" value="{@name}" class="decade_checkbox"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="concat(if(@name = '0') then '00' else @name, 's')"/>
			</li>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
