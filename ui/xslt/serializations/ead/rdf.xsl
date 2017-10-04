<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:schema="http://schema.org/" xmlns:edm="http://www.europeana.eu/schemas/edm/"
	xmlns:svcs="http://rdfs.org/sioc/services#" xmlns:doap="http://usefulinc.com/ns/doap#" xmlns:eaditor="https://github.com/ewg118/eaditor"
	exclude-result-prefixes="xs ead xlink eaditor" version="2.0">
	<!-- ***************** EAD-TO-RDF ******************-->
	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>

	<!-- url params -->
	<xsl:param name="uri" select="doc('input:request')/request/request-url"/>
	<xsl:variable name="path">
		<xsl:choose>
			<xsl:when test="contains($uri, 'ark:/')">
				<xsl:value-of select="substring-before(substring-after(substring-after($uri, 'ark:/'), '/'), '.rdf')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before(substring-after($uri, 'id/'), '.rdf')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="objectUri">
		<xsl:choose>
			<xsl:when test="//config/ark[@enabled = 'true']">
				<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', $path)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($url, 'id/', $path)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="/content/ead:ead"/>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="ead:ead">
		<xsl:variable name="pieces" select="tokenize($path, '/')"/>

		<xsl:choose>
			<xsl:when test="count($pieces) = 2">
				<xsl:call-template name="c-content"/>
			</xsl:when>
			<xsl:otherwise>
				<arch:Collection rdf:about="{$objectUri}">
					<arch:heldBy>
						<xsl:value-of select="//ead:publisher"/>
					</arch:heldBy>
					<!-- title, creator, abstract, etc. -->
					<xsl:apply-templates select="ead:archdesc/ead:did"/>
					<!-- controlled vocabulary -->

					<xsl:apply-templates select="ead:archdesc/ead:controlaccess"/>
				</arch:Collection>

				<xsl:apply-templates select="ead:archdesc/ead:dsc//ead:c"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ead:c">
		<xsl:choose>
			<xsl:when test="@level = 'item'">
				<schema:ArchiveItem rdf:about="{$objectUri}#{@id}">
					<xsl:call-template name="c-content"/>
				</schema:ArchiveItem>
				
				<!-- insert IIIF Service information -->
				<xsl:if test="descendant::ead:daoloc[@xlink:role='IIIFService']">
					<xsl:apply-templates select="descendant::ead:daoloc[@xlink:role='IIIFService']" mode="WebResource"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<schema:ArchiveCollection rdf:about="{$objectUri}#{@id}">
					<xsl:call-template name="c-content"/>
				</schema:ArchiveCollection>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="c-content">
		<xsl:variable name="parentId">
			<xsl:choose>
				<xsl:when test="parent::ead:dsc">
					<xsl:value-of select="ancestor::ead:ead/ead:eadheader/ead:eadid"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat(ancestor::ead:ead/ead:eadheader/ead:eadid, '#', parent::ead:c/@id)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- basic metadata -->
		<xsl:apply-templates select="ead:did"/>

		<!-- images, if applicable -->
		<xsl:apply-templates select="ead:daogrp"/>

		<!-- parent compontent -->
		<dcterms:isPartOf>
			<xsl:attribute name="rdf:resource">
				<xsl:choose>
					<xsl:when test="//config/ark[@enabled = 'true']">
						<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', $parentId)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($url, 'id/', $parentId)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</dcterms:isPartOf>
		<!-- controlled vocabulary -->
		<xsl:apply-templates select="ead:controlaccess"/>
	</xsl:template>

	<xsl:template match="ead:did">
		<xsl:apply-templates select="ead:unittitle | ead:unitid | ead:unitdate[@normal] | ead:origination | ead:abstract | ead:extent | ead:daogrp"/>
	</xsl:template>

	<xsl:template match="ead:controlaccess">
		<xsl:apply-templates
			select="descendant::ead:subject[@authfilenumber] | descendant::ead:genreform[@authfilenumber] | descendant::ead:geogname[@authfilenumber] | descendant::ead:corpname[@authfilenumber] | descendant::ead:persname[@authfilenumber]"
		/>
	</xsl:template>

	<xsl:template match="ead:subject | ead:genreform | ead:geogname | ead:persname | ead:corpname | ead:function | ead:occupation">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="local-name() = 'subject'">dcterms:subject</xsl:when>
				<xsl:when test="local-name() = 'genreform'">dcterms:type</xsl:when>
				<xsl:when test="local-name() = 'persname'">dcterms:subject</xsl:when>
				<xsl:when test="local-name() = 'geogname'">dcterms:coverage</xsl:when>
				<xsl:when test="local-name() = 'corpname'">dcterms:subject</xsl:when>
				<xsl:when test="local-name() = 'function'">dcterms:subject</xsl:when>
				<xsl:when test="local-name() = 'occupation'">dcterms:subject</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="resource">
			<xsl:choose>
				<xsl:when test="@source = 'geonames'">
					<xsl:value-of select="concat('http://www.geonames.org/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="@source = 'pleiades'">
					<xsl:value-of select="concat('https://pleiades.stoa.org/places/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="@source = 'lcsh' or @source = 'lcgft'">
					<xsl:value-of select="concat('http://id.loc.gov/authorities/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="@source = 'lcnaf'">
					<xsl:value-of select="concat('http://id.loc.gov/authorities/names/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="@source = 'viaf'">
					<xsl:value-of select="concat('http://viaf.org/viaf/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="@source = 'aat'">
					<xsl:value-of select="concat('http://vocab.getty.edu/aat/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="@source = 'tgn'">
					<xsl:value-of select="concat('http://vocab.getty.edu/tgn/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="@source = 'wikidata'">
					<xsl:value-of select="concat('https://www.wikidata.org/entity/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="contains(@authfilenumber, 'http://')">
					<xsl:value-of select="@authfilenumber"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string($resource)">
			<xsl:element name="{$element}">
				<xsl:attribute name="rdf:resource" select="$resource"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ead:abstract | ead:extent | ead:origination | ead:unitid | ead:unittitle">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="local-name() = 'origination'">dcterms:creator</xsl:when>
				<xsl:when test="local-name() = 'unitid'">dcterms:identifier</xsl:when>
				<xsl:when test="local-name() = 'unittitle'">dcterms:title</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('dcterms:', local-name())"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:element name="{$element}">
			<xsl:if test="@xml:lang">
				<xsl:attribute name="xml:lang" select="@xml:lang"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ead:origination">
		<xsl:choose>
			<xsl:when test="child::*">
				<xsl:for-each select="child::*">
					<dcterms:creator>
						<xsl:if test="@xml:lang">
							<xsl:attribute name="xml:lang" select="@xml:lang"/>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="matches(@authfilenumber, 'https?://')">
								<xsl:attribute name="rdf:resource" select="@authfilenumber"/>
							</xsl:when>
							<xsl:when test="@authfilenumber and @source">
								<xsl:attribute name="rdf:resource">
									<xsl:choose>
										<xsl:when test="@source = 'lcnaf'">
											<xsl:value-of select="concat('http://id.loc.gov/authorities/names/', @authfilenumber)"/>
										</xsl:when>
										<xsl:when test="@source = 'viaf'">
											<xsl:value-of select="concat('http://viaf.org/viaf/', @authfilenumber)"/>
										</xsl:when>
										<xsl:when test="contains(@authfilenumber, 'http://')">
											<xsl:value-of select="@authfilenumber"/>
										</xsl:when>
									</xsl:choose>
								</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</dcterms:creator>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<dcterms:creator>
					<xsl:if test="@xml:lang">
						<xsl:attribute name="xml:lang" select="@xml:lang"/>
					</xsl:if>
					<xsl:value-of select="."/>
				</dcterms:creator>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- images -->
	<xsl:template match="ead:daogrp">
		<xsl:apply-templates
			select="ead:daoloc[@xlink:label = 'Thumbnail'] | ead:daoloc[@xlink:role = 'thumbnail'] | ead:daoloc[@xlink:label = 'Medium'] | ead:daoloc[@xlink:role = 'reference'] | ead:daoloc[@xlink:label = 'Original'] | ead:daoloc[@xlink:role = 'IIIFService']"
		/>
	</xsl:template>

	<xsl:template match="ead:daoloc[@xlink:label = 'Thumbnail'] | ead:daoloc[@xlink:role = 'thumbnail']">
		<foaf:thumbnail rdf:resource="{@xlink:href}"/>
	</xsl:template>

	<xsl:template match="ead:daoloc[@xlink:label = 'Medium'] | ead:daoloc[@xlink:role = 'reference']">
		<foaf:depiction rdf:resource="{@xlink:href}"/>
	</xsl:template>

	<xsl:template match="ead:daoloc[@xlink:label = 'Original'] | ead:daoloc[@xlink:role = 'IIIFService']">
		<edm:isShownBy rdf:resource="{@xlink:href}{if (@xlink:role='IIIFService') then '/full/full/0/default.jpg' else ''}"/>
	</xsl:template>
	
	<!-- IIIF Services -->
	<xsl:template match="ead:daoloc[@xlink:role = 'IIIFService']" mode="WebResource">
		<edm:WebResource rdf:about="{concat(@xlink:href, '/full/full/0/default.jpg')}">
			<svcs:has_service rdf:resource="{@xlink:href}"/>
			<dcterms:isReferencedBy rdf:resource="{@xlink:href}/info.json"/>
		</edm:WebResource>
		<svcs:Service rdf:about="{@xlink:href}">
			<dcterms:conformsTo rdf:resource="http://iiif.io/api/image"/>
			<doap:implements rdf:resource="http://iiif.io/api/image/2/level1.json"/>
		</svcs:Service>
	</xsl:template>

	<!-- only process unitdates that have a @normal attribute -->
	<xsl:template match="ead:unitdate">
		<xsl:choose>
			<xsl:when test="@normal">
				<xsl:choose>
					<xsl:when test="contains(@normal, '/')">
						<xsl:variable name="type" select="
								if (@type = 'bulk') then
									'bulk'
								else
									'inclusive'"/>
						<xsl:variable name="datePieces" select="tokenize(@normal, '/')"/>

						<xsl:choose>
							<xsl:when test="count($datePieces) = 2">
								<xsl:element name="arch:{$type}Start">
									<xsl:attribute name="rdf:datatype" select="eaditor:date_dataType($datePieces[1])"/>
									<xsl:value-of select="$datePieces[1]"/>
								</xsl:element>
								<xsl:element name="arch:{$type}End">
									<xsl:attribute name="rdf:datatype" select="eaditor:date_dataType($datePieces[2])"/>
									<xsl:value-of select="$datePieces[2]"/>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="arch:{$type}Start">
									<xsl:attribute name="rdf:datatype" select="eaditor:date_dataType($datePieces[1])"/>
									<xsl:value-of select="$datePieces[1]"/>
								</xsl:element>
								<xsl:element name="arch:{$type}End">
									<xsl:attribute name="rdf:datatype" select="eaditor:date_dataType($datePieces[1])"/>
									<xsl:value-of select="$datePieces[1]"/>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<dcterms:date>
							<xsl:attribute name="rdf:datatype" select="eaditor:date_dataType(@normal)"/>
							<xsl:value-of select="@normal"/>
						</dcterms:date>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<dcterms:date>
					<xsl:value-of select="."/>
				</dcterms:date>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:function name="eaditor:date_dataType">
		<xsl:param name="val"/>

		<xsl:choose>
			<xsl:when test="$val castable as xs:date">http://www.w3.org/2001/XMLSchema#date</xsl:when>
			<xsl:when test="$val castable as xs:gYearMonth">http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:when>
			<xsl:when test="$val castable as xs:gYear">http://www.w3.org/2001/XMLSchema#gYear</xsl:when>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>
