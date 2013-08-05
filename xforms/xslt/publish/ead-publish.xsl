<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:datetime="http://exslt.org/dates-and-times" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:exsl="http://exslt.org/common" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="xs datetime" version="2.0">
	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>
	<xsl:variable name="url" select="/content/config/url"/>
	
	<!-- load ead finding aid into variable -->
	<!--<xsl:variable name="guide" select="document(concat($exist-url, 'eaditor/guides.xml'))"/>-->

	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>

	<xsl:template match="/">		
		<xsl:apply-templates select="//ead:ead"/>		
	</xsl:template>
	
	<xsl:template match="ead:ead">
		<add>
			<doc>
				<field name="id">
					<xsl:value-of select="@id"/>
				</field>
				<field name="eadid">
					<xsl:value-of select="@id"/>
				</field>
				<field name="oai_id">
					<xsl:text>oai:</xsl:text>
					<xsl:value-of select="substring-before(substring-after($url, 'http://'), '/')"/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select="@id"/>
				</field>
				<xsl:if test="string(normalize-space(//ead:publicationstmt/ead:publisher))">
					<field name="publisher_display">
						<xsl:value-of select="normalize-space(//ead:publicationstmt/ead:publisher)"/>
					</field>
				</xsl:if>
				
				<!-- get info from archdesc/did, mostly for display -->
				<xsl:apply-templates select="//ead:archdesc/ead:did"/>
				
				<!-- facets -->
				<xsl:if test="string(normalize-space(//ead:eadid/@mainagencycode))">
					<field name="agencycode_facet">
						<xsl:value-of select="normalize-space(//ead:eadid/@mainagencycode)"/>
					</field>
				</xsl:if>
				
				<xsl:for-each
					select="descendant::ead:corpname | descendant::ead:famname | descendant::ead:genreform | descendant::ead:geogname | descendant::ead:langmaterial/ead:language | descendant::ead:persname | descendant::ead:subject">
					<xsl:choose>
						<xsl:when test="local-name() = 'geogname' and string(@authfilenumber)">
							<xsl:variable name="coordinates"
								select="concat(document(concat($geonames-url, '/get?geonameId=', @authfilenumber, '&amp;username=anscoins&amp;style=full'))//lng, ',', document(concat($geonames-url, '/get?geonameId=', @authfilenumber, '&amp;username=anscoins&amp;style=full'))//lat)"/>
							
							<field name="{local-name()}_facet">
								<xsl:value-of select="normalize-space(.)"/>
							</field>
							<field name="georef">
								<xsl:value-of select="@authfilenumber"/>
								<xsl:text>|</xsl:text>
								<xsl:value-of select="normalize-space(.)"/>
								<xsl:text>|</xsl:text>
								<xsl:value-of select="$coordinates"/>
							</field>
						</xsl:when>
						<xsl:otherwise>
							<field name="{local-name()}_facet">
								<xsl:value-of select="normalize-space(.)"/>
							</field>
						</xsl:otherwise>
					</xsl:choose>
					<field name="{local-name()}_text">
						<xsl:value-of select="normalize-space(.)"/>
					</field>
				</xsl:for-each>
				
				<!-- collection images -->
				<xsl:for-each select="descendant::ead:archdesc/ead:did/ead:daogrp">
					<field name="collection_thumb">
						<xsl:value-of select="ead:daoloc[@xlink:label='Thumbnail']/@xlink:href"/>
					</field>
					<field name="collection_reference">
						<xsl:choose>
							<!-- display Medium primarily, Small secondarily -->
							<xsl:when test="string(ead:daoloc[@xlink:label='Medium']/@xlink:href)">
								<xsl:value-of select="ead:daoloc[@xlink:label='Medium']/@xlink:href"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="ead:daoloc[@xlink:label='Small']/@xlink:href"/>
							</xsl:otherwise>
						</xsl:choose>
					</field>
				</xsl:for-each>
				
				<!-- subordinate images -->
				<xsl:for-each select="descendant::ead:daogrp">
					<xsl:if test="not(parent::ead:did[parent::ead:archdesc])">
						<field name="thumb_image">
							<xsl:value-of select="ead:daoloc[@xlink:label='Thumbnail']/@xlink:href"/>
						</field>
						<field name="reference_image">
							<xsl:choose>
								<!-- display Medium primarily, Small secondarily -->
								<xsl:when test="string(ead:daoloc[@xlink:label='Medium']/@xlink:href)">
									<xsl:value-of select="ead:daoloc[@xlink:label='Medium']/@xlink:href"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="ead:daoloc[@xlink:label='Small']/@xlink:href"/>
								</xsl:otherwise>
							</xsl:choose>
						</field>
					</xsl:if>
				</xsl:for-each>
				
				<!-- timestamp -->
				<field name="timestamp">
					<xsl:variable name="timestamp" select="datetime:dateTime()"/>
					<xsl:choose>
						<xsl:when test="contains($timestamp, 'Z')">
							<xsl:value-of select="$timestamp"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($timestamp, 'Z')"/>
						</xsl:otherwise>
					</xsl:choose>
				</field>
				
				<!-- fulltext -->
				<field name="fulltext">
					<xsl:value-of select="ead:ead/@id"/>
					<xsl:text> </xsl:text>
					<xsl:for-each select="descendant-or-self::node()">
						<xsl:value-of select="text()"/>
						<xsl:text> </xsl:text>
						<xsl:if test="@normal">
							<xsl:value-of select="@normal"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</field>
			</doc>
		</add>
	</xsl:template>

	<xsl:template match="ead:archdesc/ead:did">
		<field name="unittitle_display">
			<xsl:value-of select="normalize-space(ead:unittitle)"/>
		</field>
		<field name="unittitle_text">
			<xsl:value-of select="normalize-space(ead:unittitle)"/>
		</field>

		<xsl:if test="ead:unitdate">
			<field name="unitdate_display">
				<xsl:for-each select="ead:unitdate">
					<xsl:value-of select="."/>
					<xsl:if test="not(position()=last())">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</field>

			<xsl:for-each select="ead:unitdate">
				<xsl:if test="string(@normal)">
					<xsl:call-template name="get_date_hierarchy"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="string(ead:unitid)">
			<field name="unitid_display">
				<xsl:value-of select="ead:unitid"/>
			</field>
		</xsl:if>
		<xsl:if test="ead:physdesc">
			<field name="physdesc_display">
				<xsl:value-of select="ead:physdesc"/>
			</field>
		</xsl:if>
	</xsl:template>

	<xsl:template name="get_date_hierarchy">
		<xsl:variable name="years" select="tokenize(@normal, '/')"/>

		<xsl:for-each select="$years">
			<xsl:variable name="year_string" select="."/>
			<xsl:variable name="year" select="number($year_string)"/>
			<xsl:variable name="century" select="floor($year div 100)"/>
			<xsl:variable name="decade_digit" select="floor(number(substring($year_string, string-length($year_string) - 1, string-length($year_string))) div 10) * 10"/>
			<xsl:variable name="decade" select="concat($century, if($decade_digit = 0) then '00' else $decade_digit)"/>

			<field name="century_sint">
				<xsl:value-of select="$century"/>
			</field>
			<field name="decade_sint">
				<xsl:value-of select="$decade"/>
			</field>
			<field name="year_sint">
				<xsl:value-of select="$year"/>
			</field>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
