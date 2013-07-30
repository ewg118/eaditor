<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="xmlns='http://www.w3.org/2005/Atom'" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:at="http://purl.org/atompub/tombstones/1.0" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" exclude-result-prefixes="xs dcterms at atom" version="2.0">

	<xsl:output method="xml" encoding="UTF-8"/>


	<xsl:param name="year" select="number(substring-before($date, '-'))"/>
	<xsl:param name="month" select="replace(substring-before(substring-after($date, '-'), '-'), '0(\d)', '$1')"/>
	<xsl:param name="day" select="replace(substring-after(substring-after($date, '-'), '-'), '0(\d)', '$1')"/>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="//node()[local-name() = 'entry']"/>
		</add>
	</xsl:template>

	<xsl:template match="*[local-name() = 'entry']">
		<xsl:variable name="local-date" select="substring-before(node()[local-name() = 'updated'], 'T')"/>
		<xsl:variable name="local-year" select="number(substring-before($local-date, '-'))"/>
		<xsl:variable name="local-month" select="replace(substring-before(substring-after($local-date, '-'), '-'), '0(\d)', '$1')"/>
		<xsl:variable name="local-day" select="replace(substring-after(substring-after($local-date, '-'), '-'), '0(\d)', '$1')"/>

		<!-- rdf representation -->
		<xsl:variable name="rdf_url" select="link[@type='application/rdf+xml']/@href"/>
		<xsl:choose>
			<xsl:when test="$local-year &gt; $year">
				<doc>
					<field name="id">
						<xsl:value-of select="substring-after(node()[local-name() = 'id'], 'authorities/')"/>
					</field>
					<field name="created">
						<xsl:value-of select="dcterms:created"/>
					</field>
					<field name="modified">
						<xsl:value-of select="node()[local-name() = 'updated']"/>
					</field>
					<xsl:choose>
						<xsl:when test="document($rdf_url)//skos:inScheme[contains(@rdf:resource, 'genreForm')]">
							<field name="genreform">
								<xsl:value-of select="node()[local-name() = 'title']"/>
							</field>
							<field name="source">
								<xsl:text>lcgft</xsl:text>
							</field>
						</xsl:when>
						<xsl:otherwise>
							<field name="subject">
								<xsl:value-of select="node()[local-name() = 'title']"/>
							</field>
							<field name="source">
								<xsl:text>lcsh</xsl:text>
							</field>
						</xsl:otherwise>
					</xsl:choose>
				</doc>
				<xsl:if test="position() = last()">
					<xsl:variable name="next" select="//node()[local-name() = 'link'][@rel='next']/@href"/>
					<xsl:apply-templates select="document($next)//node()[local-name() = 'entry']"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$local-year = $year">
				<xsl:choose>
					<xsl:when test="$local-month &gt; $month">
						<doc>
							<field name="id">
								<xsl:value-of select="substring-after(node()[local-name() = 'id'], 'authorities/')"/>
							</field>							
							<field name="created">
								<xsl:value-of select="dcterms:created"/>
							</field>
							<field name="modified">
								<xsl:value-of select="node()[local-name() = 'updated']"/>
							</field>
							<xsl:choose>
								<xsl:when test="document($rdf_url)//skos:inScheme[contains(@rdf:resource, 'genreForm')]">
									<field name="genreform">
										<xsl:value-of select="node()[local-name() = 'title']"/>
									</field>
									<field name="source">
										<xsl:text>lcgft</xsl:text>
									</field>
								</xsl:when>
								<xsl:otherwise>
									<field name="subject">
										<xsl:value-of select="node()[local-name() = 'title']"/>
									</field>
									<field name="source">
										<xsl:text>lcsh</xsl:text>
									</field>
								</xsl:otherwise>
							</xsl:choose>
						</doc>
						<xsl:if test="position() = last()">
							<xsl:variable name="next" select="//node()[local-name() = 'link'][@rel='next']/@href"/>
							<xsl:apply-templates select="document($next)//node()[local-name() = 'entry']"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$local-month = $month">
						<xsl:if test="$local-day &gt;= $day">
							<doc>
								<field name="id">
									<xsl:value-of select="substring-after(node()[local-name() = 'id'], 'authorities/')"/>
								</field>								
								<field name="created">
									<xsl:value-of select="dcterms:created"/>
								</field>
								<field name="modified">
									<xsl:value-of select="node()[local-name() = 'updated']"/>
								</field>
								<xsl:choose>
									<xsl:when test="document($rdf_url)//skos:inScheme[contains(@rdf:resource, 'genreForm')]">
										<field name="genreform">
											<xsl:value-of select="node()[local-name() = 'title']"/>
										</field>
										<field name="source">
											<xsl:text>lcgft</xsl:text>
										</field>
									</xsl:when>
									<xsl:otherwise>
										<field name="subject">
											<xsl:value-of select="node()[local-name() = 'title']"/>
										</field>
										<field name="source">
											<xsl:text>lcsh</xsl:text>
										</field>
									</xsl:otherwise>
								</xsl:choose>
							</doc>
							<xsl:if test="position() = last()">
								<xsl:variable name="next" select="//node()[local-name() = 'link'][@rel='next']/@href"/>
								<xsl:apply-templates select="document($next)//node()[local-name() = 'entry']"/>
							</xsl:if>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
