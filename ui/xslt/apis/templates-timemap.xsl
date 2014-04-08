<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:spatial="http://geovocab.org/spatial#"
	xmlns:kml="http://earth.google.com/kml/2.0" exclude-result-prefixes="#all" version="2.0">
	
	<xsl:template name="timemap">
		<xsl:variable name="response">
			<xsl:text>[</xsl:text>
			<xsl:for-each
				select="descendant::ead:geogname[string(@source) and string(@authfilenumber)]">
				<xsl:call-template name="getJson">
					<xsl:with-param name="href">
						<xsl:choose>
							<xsl:when test="@source='pleiades'">
								<xsl:value-of select="concat('http://pleiades.stoa.org/places/', @authfilenumber)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('http://www.geonames.org/', @authfilenumber)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>]</xsl:text>
		</xsl:variable>
		<xsl:value-of select="normalize-space($response)"/>
	</xsl:template>
	
	<xsl:template name="getJson">
		<xsl:param name="href"/>
		<xsl:variable name="name">
			<xsl:value-of select="."/>
		</xsl:variable>
		<xsl:variable name="description"/>
		<xsl:variable name="start">
			<xsl:choose>
				<xsl:when test="ancestor::ead:c">
					<!-- get the unitdate of the nearest component if the geogname is located in a component -->
					<xsl:if test="string(ancestor::ead:c[1]/ead:did/ead:unitdate/@normal)">
						<xsl:value-of select="tokenize(ancestor::ead:c[1]/ead:did/ead:unitdate/@normal, '/')[1]"/>
					</xsl:if>
					
				</xsl:when>
				<xsl:otherwise>
					<!-- otherwise, get the unitdate of the archdesc/did -->
					<xsl:if test="string(ancestor::ead:archdesc/ead:did/ead:unitdate/@normal)">
						<xsl:value-of select="tokenize(ancestor::ead:archdesc/ead:did/ead:unitdate/@normal, '/')[1]"/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="end">
			<xsl:choose>
				<xsl:when test="ancestor::ead:c">
					<!-- get the unitdate of the nearest component if the geogname is located in a component -->
					<xsl:if test="string(ancestor::ead:c[1]/ead:did/ead:unitdate/@normal)">
						<xsl:value-of select="tokenize(ancestor::ead:c[1]/ead:did/ead:unitdate/@normal, '/')[2]"/>
					</xsl:if>
					
				</xsl:when>
				<xsl:otherwise>
					<!-- otherwise, get the unitdate of the archdesc/did -->
					<xsl:if test="string(ancestor::ead:archdesc/ead:did/ead:unitdate/@normal)">
						<xsl:value-of select="tokenize(ancestor::ead:archdesc/ead:did/ead:unitdate/@normal, '/')[2]"/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="theme">red</xsl:variable>
		<xsl:variable name="coordinates">
			<xsl:call-template name="get-point">
				<xsl:with-param name="href" select="$href"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- output --> { <xsl:if test="string($coordinates) and not($coordinates='NULL')">"point": {"lon": <xsl:value-of
			select="tokenize($coordinates, '\|')[1]"/>, "lat": <xsl:value-of select="tokenize($coordinates, '\|')[2]"/>},</xsl:if> "title": "<xsl:value-of
				select="normalize-space(replace($name, '&#x022;', '\\&#x022;'))"/>", <xsl:if test="string($start)">"start": "<xsl:value-of select="$start"
				/>",</xsl:if>
		<xsl:if test="string($end)">"end": "<xsl:value-of select="$end"/>",</xsl:if> "options": { "theme": "<xsl:value-of select="$theme"/>"<xsl:if
			test="string($description)">, "description": "<xsl:value-of select="normalize-space(replace($description, '&#x022;', '\\&#x022;'))"
			/>"</xsl:if><xsl:if test="string($href)">, "href": "<xsl:value-of select="$href"/>"</xsl:if> } } </xsl:template>
	
	<xsl:template name="get-point">
		<xsl:param name="href"/>
		
		<xsl:choose>
			<xsl:when test="contains($href, 'geonames')">
				<xsl:variable name="geonameId" select="tokenize($href, '/')[4]"/>
				<xsl:variable name="geonames_data" as="item()*">
					<xsl:copy-of
						select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"/>
				</xsl:variable>
				<xsl:variable name="coordinates" select="concat($geonames_data//lng, '|', $geonames_data//lat)"/>
				<xsl:value-of select="$coordinates"/>
			</xsl:when>
			<xsl:when test="contains($href, 'pleiades')">
				<xsl:choose>
					<xsl:when
						test="number($rdf//spatial:Feature[@rdf:about=concat($href, '#this')]/descendant::geo:lat) and number($rdf//spatial:Feature[@rdf:about=concat($href, '#this')]/descendant::geo:long)">
						<xsl:value-of
							select="concat($rdf//spatial:Feature[@rdf:about=concat($href, '#this')]/descendant::geo:long, '|', $rdf//spatial:Feature[@rdf:about=concat($href, '#this')]/descendant::geo:lat)"
						/>
					</xsl:when>
					<xsl:when test="$rdf//*[@rdf:about=concat($href, '#this')]/following-sibling::osgeo:AbstractGeometry">
						<xsl:variable name="area"
							select="$rdf//*[@rdf:about=concat($href, '#this')]/following-sibling::osgeo:AbstractGeometry[1]/osgeo:asGeoJSON"/>
						<xsl:value-of select="translate(replace(replace(substring-after($area, '['), ',\s', ','), '\],', ' '), '[]}', '')"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>	
</xsl:stylesheet>
