<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: https://github.com/ewg118/eaditor
	Apache License 2.0: https://github.com/ewg118/eaditor
	
	Transform the controlled access terms returned from eXist and display as a unnumbered list -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9">


	<xsl:template match="/">
		<xsl:choose>
			<xsl:when
				test="descendant::ead:corpname or descendant::ead:famname or descendant::ead:genreform or descendant::ead:geogname or descendant::ead:persname or descendant::ead:subject">
				<ol>
					<!-- corpname -->
					<xsl:for-each select="distinct-values(descendant::*[local-name() = $name])">
						<xsl:sort/>
						<xsl:variable name="solr-url">
							<xsl:text>http://localhost:8080/solr/eaditor-vocabularies/</xsl:text>
						</xsl:variable>
						<xsl:variable name="query"
							select="concat($solr-url, 'select?q=', $name, ':%22', encode-for-uri(normalize-space(.)), '%22%20AND%20source:LCSH')"/>
						<xsl:if test="position() = 1">
							<div>
								<xsl:choose>
									<xsl:when test="$name = 'corpname'">
										<h3>Corporate Names</h3>
										<br/>
									</xsl:when>
									<xsl:when test="$name = 'famname'">
										<h3>Family Names</h3>
										<br/>
									</xsl:when>
									<xsl:when test="$name = 'genreform'">
										<h3>Genres/Formats</h3>
										<br/>
									</xsl:when>
									<xsl:when test="$name = 'geogname'">
										<h3>Geographical Names</h3>
										<br/>
									</xsl:when>
									<xsl:when test="$name = 'persname'">
										<h3>Personal Names</h3>
										<br/>
									</xsl:when>
									<xsl:when test="$name = 'subject'">
										<h3>Subjects</h3>
										<br/>
									</xsl:when>
								</xsl:choose>
							</div>

						</xsl:if>
						<xsl:if test="document($query)//result[@name='response']/@numFound = '0'">
							<li>
								<xsl:value-of select="normalize-space(.)"/>
							</li>
						</xsl:if>
					</xsl:for-each>
				</ol>
			</xsl:when>
			<xsl:otherwise>
				<h3>No terms of this type found in EAD collection</h3>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

</xsl:stylesheet>
