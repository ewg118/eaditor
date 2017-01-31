<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:ead="urn:isbn:1-931666-22-9" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:datetime="http://exslt.org/dates-and-times" xmlns:eaditor="https://github.com/ewg118/eaditor" exclude-result-prefixes="#all" version="2.0">

	<xsl:variable name="upload" select="boolean(descendant::ead:archdesc/ead:otherfindaid[@type = 'eaditor_upload']/ead:bibref/ead:extptr/@xlink:href)"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>

	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>

	<xsl:variable name="places" as="node()*">
		<places>
			<xsl:for-each select="descendant::ead:geogname[@source = 'geonames' and string(@authfilenumber)]">
				<xsl:variable name="geonames_data" as="node()*">
					<xsl:copy-of
						select="document(concat($geonames-url, '/get?geonameId=', @authfilenumber, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
				</xsl:variable>

				<place authfilenumber="{@authfilenumber}">
					<xsl:value-of select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
				</place>
			</xsl:for-each>
		</places>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/ead:ead"/>
	</xsl:template>

	<xsl:template match="ead:ead">
		<xsl:variable name="title" select="ead:archdesc/ead:did/ead:unittitle"/>
		<xsl:variable name="recordId" select="ead:eadheader/ead:eadid"/>
		<xsl:variable name="archdesc-level" select="ead:archdesc/@level"/>

		<add>
			<!--<xsl:copy-of select="/content/pleiades"/>-->

			<xsl:if test="/content/config/levels/archdesc/@enabled = true()">
				<xsl:call-template name="ead-doc">
					<xsl:with-param name="title" select="$title"/>
					<xsl:with-param name="recordId" select="$recordId"/>
					<xsl:with-param name="archdesc-level" select="$archdesc-level"/>
				</xsl:call-template>
			</xsl:if>

			<!-- apply templates only to those components when the level has been enabled in the config -->
			<!--<xsl:apply-templates select="descendant::ead:c[boolean(index-of(/content/config/levels/level[@enabled=true()], @level)) = true()]">
				<xsl:with-param name="title" select="$title"/>
				<xsl:with-param name="recordId" select="$recordId"/>
				<xsl:with-param name="archdesc-level" select="$archdesc-level"/>
			</xsl:apply-templates>-->
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
		<xsl:variable name="id" select="
				if (string(ead:eadheader/ead:eadid)) then
					ead:eadheader/ead:eadid
				else
					@id"/>

		<doc>
			<field name="id">
				<xsl:value-of select="$id"/>
			</field>
			<field name="recordId">
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">set</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="$recordId"/>
			</field>
			<field name="collection-name">
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">set</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="$collection-name"/>
			</field>
			<xsl:if test="local-name() = 'c'">
				<field name="cid">
					<xsl:if test="$upload = true()">
						<xsl:attribute name="update">set</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$id"/>
				</field>
			</xsl:if>
			
			<field name="level_facet">
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">set</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="
						if (local-name() = 'c') then
							@level
						else
							ead:archdesc/@level"/>
			</field>
			
			<field name="oai_set">
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">set</xsl:attribute>
				</xsl:if>
				<xsl:text>ead</xsl:text>
			</field>
			
			<field name="oai_id">
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">set</xsl:attribute>
				</xsl:if>
				<xsl:text>oai:</xsl:text>
				<xsl:value-of select="substring-before(substring-after($url, 'http://'), '/olr')"/>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="$id"/>
			</field>

			<!-- establish archival hierarchy -->
			<xsl:for-each select="ancestor::ead:c">
				<xsl:sort select="position()" data-type="number" order="descending"/>
				<field name="dsc_hier">
					<xsl:if test="$upload = true()">
						<xsl:attribute name="update">set</xsl:attribute>
					</xsl:if>
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
			<xsl:if test="local-name() = 'c'">
				<field name="dsc_hier">
					<xsl:if test="$upload = true()">
						<xsl:attribute name="update">set</xsl:attribute>
					</xsl:if>
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
					<xsl:if test="$upload = true()">
						<xsl:attribute name="update">set</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="normalize-space(//ead:publicationstmt/ead:publisher)"/>
				</field>
				<field name="agency_facet">
					<xsl:if test="$upload = true()">
						<xsl:attribute name="update">set</xsl:attribute>
					</xsl:if>
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
					<xsl:if test="$upload = true()">
						<xsl:attribute name="update">set</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="normalize-space(//ead:eadid/@mainagencycode)"/>
				</field>
			</xsl:if>

			<xsl:apply-templates
				select="descendant::ead:corpname | descendant::ead:famname | descendant::ead:genreform | descendant::ead:geogname | descendant::ead:langmaterial/ead:language | descendant::ead:persname | descendant::ead:subject"/>


			<!-- images -->
			<xsl:apply-templates select="descendant::ead:archdesc/ead:did/ead:daogrp"/>

			<field name="timestamp">
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">set</xsl:attribute>
				</xsl:if>
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
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">add</xsl:attribute>
				</xsl:if>
				<xsl:text> </xsl:text>
				<xsl:for-each select="//ead:archdesc/descendant-or-self::node()">
					<xsl:value-of select="text()"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</field>
		</doc>
	</xsl:template>

	<xsl:template match="ead:daogrp">
		<field name="collection_thumb">
			<xsl:if test="$upload = true()">
				<xsl:attribute name="update">set</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="ead:daoloc[@xlink:label = 'Thumbnail']/@xlink:href"/>
		</field>
		<field name="collection_reference">
			<xsl:if test="$upload = true()">
				<xsl:attribute name="update">set</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<!-- display Medium primarily, Small secondarily -->
				<xsl:when test="string(ead:daoloc[@xlink:label = 'Medium']/@xlink:href)">
					<xsl:value-of select="ead:daoloc[@xlink:label = 'Medium']/@xlink:href"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ead:daoloc[@xlink:label = 'Small']/@xlink:href"/>
				</xsl:otherwise>
			</xsl:choose>
		</field>
		<!--<xsl:if test="contains(ead:daoloc[@xlink:label='Thumbnail']/@xlink:href, 'flickr.com')">
			<field name="flickr_uri">
				<xsl:variable name="photo_id" select="substring-before(tokenize(ead:daoloc[@xlink:label='Thumbnail']/@xlink:href, '/')[last()], '_')"/>
				<xsl:value-of select="eaditor:get_flickr_uri($photo_id)"/>
			</field>
		</xsl:if>-->
	</xsl:template>

	<xsl:template match="ead:corpname | ead:famname | ead:genreform | ead:geogname | ead:language | ead:persname | ead:subject">
		<field name="{local-name()}_facet">
			<xsl:if test="$upload = true()">
				<xsl:attribute name="update">set</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="normalize-space(.)"/>
		</field>
		<field name="{local-name()}_text">
			<xsl:if test="$upload = true()">
				<xsl:attribute name="update">set</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="normalize-space(.)"/>
		</field>

		<!-- get coordinates -->
		<xsl:if test="local-name() = 'geogname' and string(@authfilenumber)">
			<xsl:variable name="authfilenumber" select="@authfilenumber"/>
			<xsl:choose>
				<xsl:when test="@source = 'geonames'">
					<field name="georef">
						<xsl:if test="$upload = true()">
							<xsl:attribute name="update">set</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$authfilenumber"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="$places//place[@authfilenumber = $authfilenumber]"/>
					</field>
				</xsl:when>
				<xsl:when test="@source = 'pleiades'">
					<field name="georef">
						<xsl:if test="$upload = true()">
							<xsl:attribute name="update">set</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$authfilenumber"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:text>|</xsl:text>
						<xsl:value-of
							select="concat(/content/pleiades/place[@id = $authfilenumber]/long, ',', /content/pleiades/place[@id = $authfilenumber]/lat)"/>
					</field>
				</xsl:when>
			</xsl:choose>
		</xsl:if>

		<!-- uri -->
		<xsl:if test="string(@authfilenumber)">
			<xsl:variable name="resource">
				<xsl:choose>
					<xsl:when test="@source = 'aat'">
						<xsl:value-of select="concat('http://vocab.getty.edu/aat/', @authfilenumber)"/>
					</xsl:when>
					<xsl:when test="@source = 'tgn'">
						<xsl:value-of select="concat('http://vocab.getty.edu/tgn/', @authfilenumber)"/>
					</xsl:when>
					<xsl:when test="@source = 'geonames'">
						<xsl:value-of select="concat('http://www.geonames.org/', @authfilenumber)"/>
					</xsl:when>
					<xsl:when test="@source = 'pleiades'">
						<xsl:value-of select="concat('http://pleiades.stoa.org/places/', @authfilenumber)"/>
					</xsl:when>
					<xsl:when test="@source = 'lcsh' or @source = 'lcgft'">
						<xsl:value-of select="concat('http://id.loc.gov/authorities/', @authfilenumber)"/>
					</xsl:when>
					<xsl:when test="@source = 'viaf'">
						<xsl:value-of select="concat('http://viaf.org/viaf/', @authfilenumber)"/>
					</xsl:when>
					<xsl:when test="contains(@authfilenumber, 'http://')">
						<xsl:value-of select="@authfilenumber"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="string($resource)">
				<field name="{local-name()}_uri">
					<xsl:if test="$upload = true()">
						<xsl:attribute name="update">set</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$resource"/>
				</field>
				<xsl:if test="@source = 'pleiades'">
					<field name="pleiades_uri">
						<xsl:if test="$upload = true()">
							<xsl:attribute name="update">set</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$resource"/>
					</field>
				</xsl:if>
			</xsl:if>
		</xsl:if>

	</xsl:template>

	<xsl:template match="ead:did">
		<field name="unittitle_display">
			<xsl:if test="$upload = true()">
				<xsl:attribute name="update">set</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="normalize-space(ead:unittitle)"/>
		</field>
		<field name="title">
			<xsl:if test="$upload = true()">
				<xsl:attribute name="update">set</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="normalize-space(ead:unittitle)"/>
		</field>
		<field name="unittitle_text">
			<xsl:if test="$upload = true()">
				<xsl:attribute name="update">set</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="normalize-space(ead:unittitle)"/>
		</field>

		<xsl:if test="ead:unitdate">
			<field name="unitdate_display">
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">set</xsl:attribute>
				</xsl:if>
				<xsl:for-each select="ead:unitdate">
					<xsl:value-of select="."/>
					<xsl:if test="not(position() = last())">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</field>

			<xsl:for-each select="ead:unitdate">
				<xsl:for-each select="tokenize(@normal, '/')">
					<xsl:call-template name="eaditor:get_date_hierarchy">
						<xsl:with-param name="date" select="."/>
					</xsl:call-template>

				</xsl:for-each>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="string(ead:unitid)">
			<field name="unitid_display">
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">set</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="ead:unitid"/>
			</field>
		</xsl:if>
		<xsl:if test="ead:physdesc/ead:extent">
			<field name="extent_display">
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">set</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="ead:physdesc/ead:extent"/>
			</field>
		</xsl:if>
	</xsl:template>

	<!-- functions -->
	<xsl:template name="eaditor:get_date_hierarchy">
		<xsl:param name="date"/>

		<xsl:if test="$date castable as xs:gYear">
			<xsl:variable name="year_string" select="string(abs(number($date)))"/>
			<xsl:variable name="century"
				select="
					if (number($date) &gt; 0) then
						ceiling(number($date) div 100)
					else
						floor(number($date) div 100)"/>
			<xsl:variable name="decade" select="floor(abs(number($date)) div 10) * 10"/>

			<xsl:if test="number($century)">
				<field name="century_num">
					<xsl:if test="$upload = true()">
						<xsl:attribute name="update">set</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$century"/>
				</field>
			</xsl:if>
			<field name="decade_num">
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">set</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="$decade"/>
			</field>
			<xsl:if test="number($date)">
				<field name="year_num">
					<xsl:if test="$upload = true()">
						<xsl:attribute name="update">set</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="number($date)"/>
				</field>
			</xsl:if>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
