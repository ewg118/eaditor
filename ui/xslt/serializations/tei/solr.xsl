<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:datetime="http://exslt.org/dates-and-times" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="#all" version="2.0">

	<xsl:include href="../../functions.xsl"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-url, 'eaditor/'), '/')"/>
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>	
	
	<!-- get nomisma RDF -->
	<xsl:variable name="nomisma-rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">
			<xsl:variable name="id-param">
				<xsl:for-each select="distinct-values(descendant::tei:ref[contains(@target, 'nomisma.org')]/@target)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
			<xsl:if test="string-length($id-param) &gt; 0">
				<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
			</xsl:if>
		</rdf:RDF>
	</xsl:variable>
	
	<xsl:variable name="viaf-rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">
			
			<xsl:for-each select="distinct-values(descendant::tei:ref[contains(@target, 'viaf.org')]/@target)">
				<xsl:variable name="pieces" select="tokenize(., '/')"/>
				<xsl:variable name="uri" select="concat('http://viaf.org/viaf/', $pieces[5])"/>
				<xsl:copy-of select="document(concat($uri, '/rdf'))/descendant::*[@rdf:about = $uri]"/>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/*[not(local-name() = 'config')]"/>
	</xsl:template>

	<xsl:template match="tei:TEI">
		<add>
			<doc>
				<field name="id">
					<xsl:value-of select="@xml:id"/>
				</field>
				<field name="recordId">
					<xsl:value-of select="@xml:id"/>
				</field>
				<field name="collection-name">
					<xsl:value-of select="$collection-name"/>
				</field>
				<field name="oai_set">tei</field>
				<field name="oai_id">
					<xsl:text>oai:</xsl:text>
					<xsl:value-of select="substring-before(substring-after($url, 'http://'), '/')"/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select="@xml:id"/>
				</field>
				<field name="timestamp">
					<xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"/>
				</field>

				<!-- fileDesc metadata -->
				<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
				<xsl:apply-templates select="tei:teiHeader/tei:profileDesc"/>

				<!-- depiction -->
				<xsl:apply-templates select="descendant::tei:facsimile[@style = 'depiction']"/>

				<!-- facet terms -->
				<xsl:apply-templates select="descendant::tei:ref[@target]"/>				

				<field name="text">
					<xsl:value-of select="@xml:id"/>
					<xsl:text> </xsl:text>
					<xsl:for-each select="descendant-or-self::node()">
						<xsl:value-of select="text()"/>
						<xsl:text> </xsl:text>
						<xsl:for-each select="@target | @ref">
							<xsl:value-of select="."/>
							<xsl:text> </xsl:text>
						</xsl:for-each>
					</xsl:for-each>
				</field>
			</doc>
		</add>
	</xsl:template>

	<xsl:template match="tei:fileDesc">
		<xsl:apply-templates select="tei:titleStmt//tei:title"/>
		<xsl:apply-templates select="tei:sourceDesc//tei:author"/>
		<xsl:apply-templates select="tei:publicationStmt/tei:publisher"/>
		<xsl:apply-templates select="tei:sourceDesc//tei:imprint/tei:date|tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:date"/>
	</xsl:template>

	<xsl:template match="tei:profileDesc">
		<xsl:apply-templates select="descendant::tei:classCode"/>
		<xsl:apply-templates select="tei:particDesc//*[@ref]|descendant::tei:term[@ref]"/>
	</xsl:template>

	<xsl:template match="tei:title">
		<field name="unittitle_display">
			<xsl:value-of select="."/>
		</field>
	</xsl:template>
	
	<xsl:template match="tei:persName[@ref] | tei:orgName[@ref] | tei:term[@ref]">
		<xsl:variable name="facet">
			<xsl:choose>
				<xsl:when test="self::tei:persName">persname</xsl:when>
				<xsl:when test="self::tei:orgName">corpname</xsl:when>
				<xsl:when test="self::tei:term">
					<xsl:choose>
						<xsl:when test="contains(@ref, 'numismatics.org/ocre') or contains(@ref, 'numismatics.org/crro') or contains(@ref, 'numismatics.org/pella') or contains(@ref, 'numismatics.org/pco')
							or contains(@ref, 'numismatics.org/sco')">coinType</xsl:when>
						<xsl:when test="contains(@ref, 'coinhoards.org')">hoard</xsl:when>
						<xsl:otherwise>subject</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<field name="{$facet}_facet">
			<xsl:value-of select="."/>
		</field>
		<field name="{$facet}_uri">
			<xsl:value-of select="@ref"/>
		</field>
	</xsl:template>

	<xsl:template match="tei:author">
		<xsl:if test="*/@ref">
			<field name="persname_facet">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
			<field name="persname_text">
				<xsl:value-of select="normalize-space(.)"/>
			</field>
			<field name="persname_uri">
				<xsl:value-of select="*/@ref"/>
			</field>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:date">
		<field name="unitdate_display">
			<xsl:value-of select="."/>
		</field>
		
		<xsl:variable name="dates" as="element()*">
			<dates>
				<xsl:choose>
					<xsl:when test="@when">
						<date>
							<xsl:choose>
								<xsl:when test="@when castable as xs:gYear">
									<xsl:value-of select="@when"/>
								</xsl:when>
								<xsl:when test="@when castable as xs:date or . castable as xs:gYearMonth">
									<xsl:value-of select="substring(@when, 1, 4)"/>
								</xsl:when>
							</xsl:choose>
						</date>
					</xsl:when>
					<xsl:when test="@from and @to">
						<xsl:choose>
							<xsl:when test="@from castable as xs:gYear">
								<xsl:value-of select="@from"/>
							</xsl:when>
							<xsl:when test="@from castable as xs:date or . castable as xs:gYearMonth">
								<xsl:value-of select="substring(@from, 1, 4)"/>
							</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="@to castable as xs:gYear">
								<xsl:value-of select="@to"/>
							</xsl:when>
							<xsl:when test="@to castable as xs:date or . castable as xs:gYearMonth">
								<xsl:value-of select="substring(@to, 1, 4)"/>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</dates>
		</xsl:variable>
		
		<xsl:for-each select="$dates//date">
			<xsl:call-template name="eaditor:get_date_hierarchy">
				<xsl:with-param name="date" select="."/>
				<xsl:with-param name="upload" select="false()"/>
			</xsl:call-template>
		</xsl:for-each>
		
		<!-- set minimum and maximum dates -->
		<xsl:if test="$dates//date">
			<field name="year_minint">
				<xsl:value-of select="min($dates//date)"/>				
			</field>
			<field name="year_maxint">
				<xsl:value-of select="max($dates//date)"/>				
			</field>
		</xsl:if>
		
	</xsl:template>

	<xsl:template match="tei:publisher">
		<field name="publisher_display">
			<xsl:value-of select="if (tei:name) then tei:name else ."/>			
		</field>
	</xsl:template>

	<xsl:template match="tei:facsimile[@style = 'depiction']">
		<xsl:apply-templates select="tei:graphic | tei:media[@type = 'IIIFService']"/>

	</xsl:template>

	<xsl:template match="tei:graphic">
		<field name="collection_thumb">
			<xsl:value-of select="concat($url, 'ui/media/thumbnail/', @url, '.jpg')"/>
		</field>
		<field name="collection_reference">
			<xsl:value-of select="concat($url, 'ui/media/reference/', @url, '.jpg')"/>
		</field>
	</xsl:template>

	<xsl:template match="tei:media[@type = 'IIIFService']">
		<field name="collection_thumb">
			<xsl:value-of select="concat(@url, '/full/120,/0/default.jpg')"/>
		</field>
		<field name="collection_reference">
			<xsl:value-of select="concat(@url, '/full/!600,600/0/default.jpg')"/>
		</field>
	</xsl:template>

	<xsl:template match="tei:ref">
		<xsl:variable name="uri" select="@target"/>
		
		<xsl:if test="not(preceding::node()/@target = $uri)">
			<xsl:variable name="facet">
				<xsl:choose>
					<xsl:when test="contains($uri, 'nomisma.org')">
						<xsl:variable name="type" select="$nomisma-rdf//*[@rdf:about = $uri]/name()"/>
						<xsl:choose>
							<xsl:when test="$type = 'nmo:Region' or $type = 'nmo:Mint'">geogname</xsl:when>
							<xsl:when test="$type = 'foaf:Person'">persname</xsl:when>
							<xsl:when test="$type = 'foaf:Organization' or $type = 'rdac:Family'">corpname</xsl:when>
							<xsl:otherwise>subject</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="contains($uri, 'geonames.org')">geogname</xsl:when>
					<xsl:when test="contains($uri, 'viaf.org')">
						<xsl:choose>
							<xsl:when test="$viaf-rdf//*[@rdf:about = $uri]/rdf:type/@rdf:resource = 'http://xmlns.com/foaf/0.1/Organization'"
								>corpname</xsl:when>
							<xsl:when test="$viaf-rdf//*[@rdf:about = $uri]/rdf:type/@rdf:resource = 'http://xmlns.com/foaf/0.1/Person'"
								>persname</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:when
						test="contains($uri, 'numismatics.org/ocre') or contains($uri, 'numismatics.org/crro') or contains($uri, 'numismatics.org/pella') or contains($uri, 'numismatics.org/pco')
						or contains($uri, 'numismatics.org/sco')">coinType</xsl:when>
					<xsl:when test="contains($uri, 'coinhoards.org')">hoard</xsl:when>
					<!-- ignore ANS coins; not useful as subject terms -->
					<xsl:when test="contains($uri, 'numismatics.org/collection')"/>
					<xsl:otherwise>subject</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:if test="string-length($facet) &gt; 0">
				<!-- ignore the indexing of facets that are not normalized terms -->
				<xsl:if test="not(matches(., 'https?://'))">
					<field name="{$facet}_facet">
						<xsl:value-of select="."/>
					</field>
					<field name="{$facet}_text">
						<xsl:value-of select="."/>
					</field>
				</xsl:if>
				<field name="{$facet}_uri">
					<xsl:value-of select="$uri"/>
				</field>
			</xsl:if>
		</xsl:if>
		
		
	</xsl:template>

	<xsl:template match="tei:classCode[matches(@scheme, 'https?://')]">
		<xsl:variable name="uri" select="concat(@scheme, .)"/>
		
		<field name="genreform_facet">
			<xsl:choose>
				<xsl:when test=". = '300264354'">notebooks</xsl:when>
				<xsl:when test=". = '300026877'">correspondence</xsl:when>
				<xsl:when test=". = '300265639'">research notes</xsl:when>
				<xsl:when test=". = '300046300'">hoard photographs</xsl:when>
				<xsl:when test=". = '300027568'">invoices</xsl:when>
				<xsl:when test=". = '300417667'">seals (marks)</xsl:when>
			</xsl:choose>
		</field>

		<field name="genreform_uri">
			<xsl:value-of select="$uri"/>
		</field>
	</xsl:template>
</xsl:stylesheet>
