<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ead="urn:isbn:1-931666-22-9"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:datetime="http://exslt.org/dates-and-times" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:template match="ead:ead">
		<xsl:variable name="title" select="ead:archdesc/ead:did/ead:unittitle"/>
		<xsl:variable name="recordId" select="ead:eadheader/ead:eadid"/>
		<xsl:variable name="archdesc-level" select="ead:archdesc/@level"/>

		<add>
			<xsl:if test="/content/config/levels/archdesc/@enabled = true()">
				<xsl:call-template name="ead-doc">
					<xsl:with-param name="title" select="$title"/>
					<xsl:with-param name="recordId" select="$recordId"/>
					<xsl:with-param name="archdesc-level" select="$archdesc-level"/>
				</xsl:call-template>
			</xsl:if>

			<!-- apply templates only to those components when the level has been enabled in the config -->
			<xsl:apply-templates select="descendant::ead:c[boolean(index-of(/content/config/levels/level[@enabled=true()], @level)) = true()]">
				<xsl:with-param name="title" select="$title"/>
				<xsl:with-param name="recordId" select="$recordId"/>
				<xsl:with-param name="archdesc-level" select="$archdesc-level"/>
			</xsl:apply-templates>
		</add>
	</xsl:template>

	<!-- component template -->
	<xsl:template match="ead:c">
		<xsl:param name="title"/>
		<xsl:param name="recordId"/>
		<xsl:param name="archdesc-level"/>

		<xsl:call-template name="ead-doc">
			<xsl:with-param name="title" select="$title"/>
			<xsl:with-param name="recordId" select="$recordId"/>
			<xsl:with-param name="archdesc-level" select="$archdesc-level"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="ead-doc">
		<xsl:param name="title"/>
		<xsl:param name="recordId"/>
		<xsl:param name="archdesc-level"/>
		<xsl:variable name="id" select="if (string(ead:eadheader/ead:eadid)) then ead:eadheader/ead:eadid else @id"/>

		<doc>
			<field name="id">
				<xsl:value-of select="$id"/>
			</field>
			<field name="recordId">
				<xsl:value-of select="$recordId"/>
			</field>
			<field name="collection-name">
				<xsl:value-of select="$collection-name"/>
			</field>
			<xsl:if test="local-name()='c'">
				<field name="cid">
					<xsl:value-of select="$id"/>
				</field>
			</xsl:if>
			<field name="level_facet">
				<xsl:value-of select="if (local-name()='c') then @level else ead:archdesc/@level"/>
			</field>
			<field name="oai_id">
				<xsl:text>oai:</xsl:text>
				<xsl:value-of select="substring-before(substring-after($url, 'http://'), '/olr')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="$id"/>
			</field>

			<!-- establish archival hierarchy -->
			<xsl:for-each select="ancestor::ead:c">
				<xsl:sort select="position()" data-type="number" order="descending"/>
				<field name="dsc_hier">
					<xsl:value-of select="position()"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="concat($recordId, '/', @id)"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="@level"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="ead:did/ead:unittitle"/>
				</field>
			</xsl:for-each>
			<!-- if the doc is a component, added dsc_hier field for the archdesc -->
			<xsl:if test="local-name()='c'">
				<field name="dsc_hier">
					<xsl:value-of select="count(ancestor::ead:c) + 1"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$recordId"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$archdesc-level"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$title"/>
				</field>
			</xsl:if>

			<xsl:if test="string(normalize-space(//ead:publicationstmt/ead:publisher))">
				<field name="publisher_display">
					<xsl:value-of select="normalize-space(//ead:publicationstmt/ead:publisher)"/>
				</field>
			</xsl:if>

			<!-- gather display terms from did -->
			<xsl:choose>
				<xsl:when test="ead:archdesc/ead:did">
					<xsl:apply-templates select="ead:archdesc/ead:did"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="ead:did"/>
				</xsl:otherwise>
			</xsl:choose>

			<!-- facets -->
			<xsl:if test="string(normalize-space(//ead:eadid/@mainagencycode))">
				<field name="agencycode_facet">
					<xsl:value-of select="normalize-space(//ead:eadid/@mainagencycode)"/>
				</field>
			</xsl:if>

			<xsl:apply-templates
				select="descendant::ead:corpname | descendant::ead:famname | descendant::ead:genreform | descendant::ead:geogname | descendant::ead:langmaterial/ead:language | descendant::ead:persname | descendant::ead:subject"/>


			<!-- images -->
			<xsl:apply-templates select="descendant::ead:daogrp"/>

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

			<field name="text">
				<xsl:value-of select="@id"/>
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
	</xsl:template>

	<xsl:template match="ead:daogrp">
		<field>
			<xsl:attribute name="name" select="if (parent::ead:did/parent::ead:archdesc) then 'collection_thumb' else 'thumb_image'"/>
			<xsl:value-of select="ead:daoloc[@xlink:label='Thumbnail']/@xlink:href"/>
		</field>
		<field>
			<xsl:attribute name="name" select="if (parent::ead:did/parent::ead:archdesc) then 'collection_reference' else 'reference_image'"/>
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
	</xsl:template>

	<xsl:template match="ead:corpname | ead:famname | ead:genreform | ead:geogname | ead:language | ead:persname | ead:subject">
		<field name="{local-name()}_facet">
			<xsl:value-of select="normalize-space(.)"/>
		</field>
		<field name="{local-name()}_text">
			<xsl:value-of select="normalize-space(.)"/>
		</field>

		<!-- get coordinates -->
		<xsl:if test="local-name() = 'geogname' and string(@authfilenumber)">
			<xsl:variable name="authfilenumber" select="@authfilenumber"/>
			<xsl:choose>
				<xsl:when test="@source='geonames'">
					<field name="georef">
						<xsl:value-of select="$authfilenumber"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="$places//place[@authfilenumber=$authfilenumber]"/>
					</field>
				</xsl:when>
				<xsl:when test="@source='pleiades'">
					<xsl:variable name="rdf" as="node()*">
						<xsl:copy-of select="document(concat('http://pleiades.stoa.org/places/', $authfilenumber, '/rdf'))"/>
					</xsl:variable>

					<xsl:if test="number($rdf//geo:long) and number($rdf//geo:lat)">
						<field name="georef">
							<xsl:value-of select="$authfilenumber"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="normalize-space(.)"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="concat($rdf//geo:long, ',', $rdf//geo:lat)"/>
						</field>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:if>

		<!-- uri -->
		<xsl:if test="string(@source) and string(@authfilenumber)">
			<xsl:variable name="resource">
				<xsl:choose>
					<xsl:when test="@source='aat'">
						<xsl:value-of select="concat('http://vocab.getty.edu/aat/', @authfilenumber)"/>
					</xsl:when>
					<xsl:when test="@source='geonames'">
						<xsl:value-of select="concat('http://www.geonames.org/', @authfilenumber)"/>
					</xsl:when>
					<xsl:when test="@source='pleiades'">
						<xsl:value-of select="concat('http://pleiades.stoa.org/places/', @authfilenumber)"/>
					</xsl:when>
					<xsl:when test="@source='lcsh' or @source='lcgft'">
						<xsl:value-of select="concat('http://id.loc.gov/authorities/', @authfilenumber)"/>
					</xsl:when>
					<xsl:when test="@source='viaf'">
						<xsl:value-of select="concat('http://viaf.org/viaf/', @authfilenumber)"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="string($resource)">
				<field name="{local-name()}_uri">
					<xsl:value-of select="$resource"/>
				</field>
				<xsl:if test="@source='pleiades'">
					<field name="pleiades_uri">
						<xsl:value-of select="$resource"/>
					</field>
				</xsl:if>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template match="ead:did">
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
		<xsl:if test="ead:physdesc/ead:extent">
			<field name="extent_display">
				<xsl:value-of select="ead:physdesc/ead:extent"/>
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

			<field name="century_num">
				<xsl:value-of select="$century"/>
			</field>
			<field name="decade_num">
				<xsl:value-of select="$decade"/>
			</field>
			<field name="year_num">
				<xsl:value-of select="$year"/>
			</field>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
