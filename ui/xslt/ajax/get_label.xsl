<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	author: Ethan Gruber, gruber@numismatics.org 
	date modified: June 2019
	function: read the data model extracted from from a web resource and return the URI and label in JSON. see xpl/models/get_model.xpl
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all" version="2.0">

	<xsl:param name="uri" select="doc('input:request')/request/parameters/parameter[name='uri']/value"/>

	<xsl:template match="/">
		<xsl:text>{"uri": "</xsl:text>
		<xsl:choose>
			<xsl:when test="contains($uri, 'geonames.org')">
				<xsl:variable name="pieces" select="tokenize($uri, '/')"/>
				<xsl:value-of select="concat('http://sws.geonames.org/', $pieces[4], '/')"/>
			</xsl:when>
			<xsl:when test="contains($uri, 'viaf.org')">
				<xsl:variable name="pieces" select="tokenize($uri, '/')"/>
				<xsl:value-of select="concat('http://viaf.org/viaf/', $pieces[5])"/>
			</xsl:when>		
			<xsl:when test="contains($uri, 'wikipedia.org')">
				<xsl:value-of select="concat('http://www.wikidata.org/entity/', //entity[1]/@title)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$uri"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>","label":"</xsl:text>
		<xsl:call-template name="get_label"/>
		<xsl:text>"}</xsl:text>
	</xsl:template>

	<xsl:template name="get_label">
		<xsl:choose>
			<!-- geonames handler -->
			<xsl:when test="/geoname/geonameId">
				<xsl:variable name="abbreviations" as="element()*">
					<abbreviations>
						<country code="US">
							<place abbr="Ala.">Alabama</place>
							<place abbr="Alaska">Alaska</place>
							<place abbr="Ariz.">Arizona</place>
							<place abbr="Ark.">Arkansas</place>
							<place abbr="Calif.">California</place>
							<place abbr="Colo.">Colorado</place>
							<place abbr="Conn.">Connecticut</place>
							<place abbr="Del.">Delaware</place>
							<place abbr="D.C.">Washington, D.C.</place>
							<place abbr="Fla.">Florida</place>
							<place abbr="Ga.">Georgia</place>
							<place abbr="Hawaii">Hawaii</place>
							<place abbr="Idaho">Idaho</place>
							<place abbr="Ill.">Illinois</place>
							<place abbr="Ind.">Indiana</place>
							<place abbr="Iowa">Iowa</place>
							<place abbr="Kans.">Kansas</place>
							<place abbr="Ky.">Kentucky</place>
							<place abbr="La.">Louisiana</place>
							<place abbr="Maine">Maine</place>
							<place abbr="Md.">Maryland</place>
							<place abbr="Mass.">Massachusetts</place>
							<place abbr="Mich.">Michigan</place>
							<place abbr="Minn.">Minnesota</place>
							<place abbr="Miss.">Mississippi</place>
							<place abbr="Mo.">Missouri</place>
							<place abbr="Mont.">Montana</place>
							<place abbr="Nebr.">Nebraska</place>
							<place abbr="Nev.">Nevada</place>
							<place abbr="N.H.">New Hampshire</place>
							<place abbr="N.J.">New Jersey</place>
							<place abbr="N.M.">New Mexico</place>
							<place abbr="N.Y.">New York</place>
							<place abbr="N.C.">North Carolina</place>
							<place abbr="N.D.">North Dakota</place>
							<place abbr="Ohio">Ohio</place>
							<place abbr="Okla.">Oklahoma</place>
							<place abbr="Oreg.">Oregon</place>
							<place abbr="Pa.">Pennsylvania</place>
							<place abbr="R.I.">Rhode Island</place>
							<place abbr="S.C.">South Carolina</place>
							<place abbr="S.D">South Dakota</place>
							<place abbr="Tenn.">Tennessee</place>
							<place abbr="Tex.">Texas</place>
							<place abbr="Utah">Utah</place>
							<place abbr="Vt.">Vermont</place>
							<place abbr="Va.">Virginia</place>
							<place abbr="Wash.">Washington</place>
							<place abbr="W.Va.">West Virginia</place>
							<place abbr="Wis.">Wisconsin</place>
							<place abbr="Wyo.">Wyoming</place>
							<place abbr="A.S.">American Samoa</place>
							<place abbr="Guam">Guam</place>
							<place abbr="M.P.">Northern Mariana Islands</place>
							<place abbr="P.R.">Puerto Rico</place>
							<place abbr="V.I.">U.S. Virgin Islands</place>
						</country>
						<country code="CA">
							<place abbr="Alta.">Alberta</place>
							<place abbr="B.C.">British Columbia</place>
							<place abbr="Alta.">Manitoba</place>
							<place abbr="Man.">Alberta</place>
							<place abbr="N.B.">New Brunswick</place>
							<place abbr="Nfld.">Newfoundland and Labrador</place>
							<place abbr="N.W.T.">Northwest Territories</place>
							<place abbr="N.S.">Nova Scotia</place>
							<place abbr="NU">Nunavut</place>
							<place abbr="Ont.">Ontario</place>
							<place abbr="P.E.I.">Prince Edward Island</place>
							<place abbr="Que.">Quebec</place>
							<place abbr="Sask.">Saskatchewan</place>
							<place abbr="Y.T.">Yukon</place>
						</country>
						<country code="AU">
							<place abbr="A.C.T.">Australian Capital Territory</place>
							<place abbr="J.B.T.">Jervis Bay Territory</place>
							<place abbr="N.S.W.">New South Wales</place>
							<place abbr="N.T.">Northern Territory</place>
							<place abbr="Qld.">Queensland</place>
							<place abbr="S.A.">South Australia</place>
							<place abbr="Tas.">Tasmania</place>
							<place abbr="Vic.">Victoria</place>
							<place abbr="W.A.">Western Australia</place>
						</country>
					</abbreviations>
				</xsl:variable>
				
				<!-- generate AACR2 label -->
				<xsl:variable name="label">
					<xsl:variable name="countryCode" select="//countryCode"/>
					<xsl:variable name="countryName" select="//countryName"/>
					<xsl:variable name="name" select="//name"/>
					<xsl:variable name="adminName1" select="//adminName1"/>
					<xsl:variable name="fcode" select="//fcode"/>
					<!-- set a value equivalent to AACR2 standard for US, AU, CA, and GB.  This equation deviates from AACR2 for Malaysia since standard abbreviations for territories cannot be found -->
					<xsl:value-of
						select="if ($countryCode = 'US' or $countryCode = 'AU' or $countryCode = 'CA') then if ($fcode = 'ADM1') then $name else concat($name, ' (', $abbreviations//country[@code=$countryCode]/place[. = $adminName1]/@abbr, ')') else if ($countryCode= 'GB') then  if ($fcode = 'ADM1') then $name else concat($name, ' (', $adminName1, ')') else if ($fcode = 'PCLI') then $name else concat($name, ' (', $countryName, ')')"
					/>
				</xsl:variable>				
				
				<xsl:value-of select="$label"/>			
			</xsl:when>
			<!-- VIAF RDF handler -->
			<xsl:when test="/rdf:RDF/rdf:Description[contains(@rdf:about, 'viaf.org')]">
				<!-- look for Library of Congress heading by default -->
				<xsl:choose>
					<xsl:when test="descendant::skos:Concept[skos:inScheme[@rdf:resource='http://viaf.org/authorityScheme/LC']]">
						<xsl:value-of select="descendant::skos:Concept[skos:inScheme[@rdf:resource='http://viaf.org/authorityScheme/LC']]/skos:prefLabel"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="descendant::skos:prefLabel[1]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- generic skos:prefLabel handler, works on nomisma.org, ANS authorities, Coin types and hoard projects -->
			<xsl:when test="count(descendant::skos:prefLabel) &gt; 0">
				<xsl:choose>
					<xsl:when test="string(descendant::skos:prefLabel[@xml:lang='en'])">
						<xsl:value-of select="descendant::skos:prefLabel[@xml:lang='en']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="descendant::skos:prefLabel[1]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- generic dcterms:title handler, works on ANS collection, archives, digital library -->
			<xsl:when test="count(descendant::dcterms:title) &gt; 0">
				<xsl:choose>
					<xsl:when test="string(descendant::dcterms:title[@xml:lang='en'])">
						<xsl:value-of select="descendant::dcterms:title[@xml:lang='en'][1]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="descendant::dcterms:title[1]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- Wikidata handler -->
			<xsl:when test="count(//entity) &gt; 0">
				<xsl:value-of select="descendant::entity[1]/labels/label[@language='en']/@value"/>
			</xsl:when>
			<!-- donum -->
			<xsl:when test="count(descendant::dc:Title) &gt; 0">
				<xsl:value-of select="replace(descendant::dc:Title[1], '&#x022;', '\\&#x022;')"/>
			</xsl:when>
			<xsl:otherwise>				
				<xsl:value-of select="response"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
