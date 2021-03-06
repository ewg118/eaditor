<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: December 2019
	Function: Parse the URI inputted into TEI/IIIF Web Annotations in order to extract preferred labels
	from various sources.
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:param name="uri" select="/request/parameters/parameter[name='uri']/value"/>

				<xsl:template match="/">
					<parser>
						<xsl:choose>
							<xsl:when test="contains($uri, 'http://nomisma.org/')">true</xsl:when>
							<xsl:when test="contains($uri, 'http://coinhoards.org/')">true</xsl:when>							
							<xsl:when test="contains($uri, 'http://numismatics.org/library/')">true</xsl:when>
							<xsl:when test="matches($uri, 'http://numismatics.org/(pella|sco|pco|ocre|crro|aod|chrr|digitallibrary|archives|authority|collection)')">true</xsl:when>
							<xsl:when test="contains($uri, 'geonames.org')">true</xsl:when>
							<xsl:when test="contains($uri, 'viaf.org')">true</xsl:when>
							<xsl:when test="contains($uri, 'wikipedia.org') or contains($uri, 'dbpedia.org')">true</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</parser>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="parser-config"/>
	</p:processor>

	<p:choose href="#parser-config">
		<p:when test="parser='true'">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#config"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:param name="uri" select="doc('input:request')/request/parameters/parameter[name='uri']/value"/>
						<xsl:variable name="geonames-url">http://api.geonames.org</xsl:variable>
						<xsl:variable name="geonames_api_key" select="/config/geonames_api_key"/>

						<xsl:template match="/">
							<xsl:variable name="service">
								<xsl:choose>
									<xsl:when test="contains($uri, 'http://nomisma.org/')">
										<xsl:value-of select="concat($uri, '.rdf')"/>
									</xsl:when>
									<xsl:when test="contains($uri, 'http://coinhoards.org/')">
										<xsl:value-of select="concat($uri, '.rdf')"/>
									</xsl:when>
									<xsl:when test="matches($uri, 'http://numismatics.org/(pella|sco|pco|ocre|crro|aod|chrr|digitallibrary|archives|authority|collection)')">
										<xsl:value-of select="concat($uri, '.rdf')"/>
									</xsl:when>									
									<xsl:when test="contains($uri, 'http://numismatics.org/library/')">
										<xsl:value-of select="concat('http://donum.numismatics.org/cgi-bin/koha/opac-export.pl?format=dc&amp;op=export&amp;bib=', substring-after($uri, 'library/'))"/>
									</xsl:when>
									<xsl:when test="contains($uri, 'geonames.org')">
										<xsl:variable name="pieces" select="tokenize($uri, '/')"/>
										<xsl:value-of select="concat($geonames-url, '/get?geonameId=', $pieces[4], '&amp;username=', $geonames_api_key, '&amp;style=full')"/>
									</xsl:when>
									<xsl:when test="contains($uri, 'viaf.org')">
										<xsl:variable name="pieces" select="tokenize($uri, '/')"/>
										<xsl:value-of select="concat('http://viaf.org/viaf/', $pieces[5], '/rdf')"/>
									</xsl:when>
									<xsl:when test="contains($uri, 'wikipedia.org')">
										<xsl:variable name="pieces" select="tokenize($uri, '/')"/>
										<xsl:variable name="title" select="$pieces[last()]"/>
										<xsl:variable name="lang" select="tokenize($pieces[3], '\.')[1]"/>
										
										<!-- parse the wikipedia URL and convert it into a Wikidata API call -->
										<xsl:value-of select="concat('https://www.wikidata.org/w/api.php?action=wbgetentities&amp;titles=', $title, '&amp;sites=', $lang, 'wiki&amp;format=xml')"/>	
									</xsl:when>
								</xsl:choose>
							</xsl:variable>
							<config>
								<url>
									<xsl:value-of select="$service"/>
								</url>
								<mode>xml</mode>
								<content-type>application/xml</content-type>
								<encoding>utf-8</encoding>
							</config>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="generator-config"/>
			</p:processor>

			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#generator-config"/>
				<p:output name="data" id="url-data"/>
			</p:processor>

			<p:processor name="oxf:exception-catcher">
				<p:input name="data" href="#url-data"/>
				<p:output name="data" id="url-data-checked"/>
			</p:processor>

			<!-- Check whether we had an exception -->
			<p:choose href="#url-data-checked">
				<p:when test="/exceptions">
					<!-- Extract the message -->
					<p:processor name="oxf:xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="#url-data-checked"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
								<xsl:param name="uri" select="doc('input:request')/request/parameters/parameter[name='uri']/value"/>
								
								<xsl:template match="/">
									<response>
										<xsl:value-of select="$uri"/>
									</response>
								</xsl:template>
							</xsl:stylesheet>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<!-- Just return the document -->
					<p:processor name="oxf:identity">
						<p:input name="data" href="#url-data-checked"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="../../exist-config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:param name="uri" select="doc('input:request')/request/parameters/parameter[name='uri']/value"/>						
						<xsl:template match="/">
							<response>
								<xsl:value-of select="$uri"/>
							</response>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
