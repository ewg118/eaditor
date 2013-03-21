<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common"
	xmlns:datetime="http://exslt.org/dates-and-times" exclude-result-prefixes="xs datetime exsl" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>
	<!-- load config.xml from eXist into a variable which is later processed with exsl:node-set -->
	<xsl:variable name="config" select="document(concat($exist-url, 'eaditor/config.xml'))"/>
	<xsl:variable name="solr-url" select="concat(exsl:node-set($config)/config/solr_published, 'select/')"/>
	<xsl:param name="site-url" select="exsl:node-set($config)/config/url"/>
	<!-- request URL -->
	<xsl:param name="base-url" select="substring-before(doc('input:url')/request/request-url, 'feed/')"/>

	<xsl:param name="verb">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='verb']/value"/>
	</xsl:param>
	<xsl:param name="metadataPrefix">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='metadataPrefix']/value"/>
	</xsl:param>
	<xsl:param name="set">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='set']/value"/>
	</xsl:param>
	<xsl:param name="identifier" as="xs:anyURI">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='identifier']/value"/>
	</xsl:param>
	<xsl:param name="from">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='from']/value"/>
	</xsl:param>
	<xsl:param name="until">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='until']/value"/>
	</xsl:param>
	<xsl:param name="resumptionToken">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='resumptionToken']/value"/>
	</xsl:param>

	<!-- validate from, until, resumptionToken -->
	<xsl:variable name="from-validate" as="xs:boolean" select="$from castable as xs:date"/>
	<xsl:variable name="until-validate" as="xs:boolean" select="$until castable as xs:date"/>


	<xsl:variable name="q">
		<xsl:choose>
			<xsl:when test="string($identifier)">
				<xsl:text>oai_id:%22</xsl:text>
				<xsl:value-of select="normalize-space($identifier)"/>
				<xsl:text>%22</xsl:text>
			</xsl:when>
			<xsl:when test="string($from) or string($until)">
				<xsl:if test="$from-validate=true() or $until-validate=true()">
					<xsl:text>timestamp:[</xsl:text>
					<xsl:value-of select="if($from-validate=true()) then concat($from, 'T00:00:00.000Z') else '*'"/>
					<xsl:text>+TO+</xsl:text>
					<xsl:value-of select="if($until-validate=true()) then concat($until, 'T23:59:59.999Z') else '*'"/>
					<xsl:text>]</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>*:*</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="service">
		<xsl:value-of select="concat($solr-url, '?q=', $q, '&amp;sort=timestamp%20desc&amp;rows=500')"/>
	</xsl:variable>

	<xsl:variable name="resumptionToken-validate" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="string($resumptionToken)">
				<xsl:choose>
					<xsl:when test="document(concat($solr-url, '?q=', encode-for-uri(concat('oai_id:&#x022;', $resumptionToken, '&#x022;'))))/response/result/@numFound = 1">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/
			http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">			
			<responseDate>
				<xsl:variable name="timestamp" select="concat(substring-before(datetime:dateTime(), '.'), 'Z')"/>
				<xsl:value-of select="$timestamp"/>
			</responseDate>
			<request verb="{$verb}">
				<xsl:if test="string($metadataPrefix)">
					<xsl:attribute name="metadataPrefix" select="$metadataPrefix"/>
				</xsl:if>
				<xsl:if test="string($set)">
					<xsl:attribute name="set" select="$set"/>
				</xsl:if>
				<xsl:if test="string($identifier)">
					<xsl:attribute name="identifier" select="$identifier"/>
				</xsl:if>
				<xsl:value-of select="concat($site-url, 'oai/')"/>
			</request>
			<xsl:choose>
				<xsl:when test="$verb='Identify'">
					<Identify>
						<repositoryName>
							<xsl:value-of select="exsl:node-set($config)//repositoryName"/>
						</repositoryName>
						<baseURL>
							<xsl:value-of select="concat($site-url, 'oai/')"/>
						</baseURL>
						<protocolVersion>2.0</protocolVersion>
						<adminEmail><xsl:value-of select="exsl:node-set($config)//adminEmail"/></adminEmail>
						<earliestDatestamp>
							<xsl:value-of select="substring-before(document(concat($solr-url, '?q=*:*&amp;rows=1&amp;sort=timestamp+asc'))/descendant::doc/date[@name='timestamp'], 'T')"/>
						</earliestDatestamp>
						<deletedRecord>no</deletedRecord>
						<granularity>YYYY-MM-DD</granularity>
						<description>
							<oai-identifier xmlns="http://www.openarchives.org/OAI/2.0/oai-identifier" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai-identifier
								http://www.openarchives.org/OAI/2.0/oai-identifier.xsd">
								<scheme>oai</scheme>
								<repositoryIdentifier>
									<xsl:value-of select="substring-before(substring-after(exsl:node-set($config)//url, 'http://'), '/')"/>
								</repositoryIdentifier>
								<delimiter>:</delimiter>
								<sampleIdentifier>
									<xsl:value-of select="document(concat($solr-url, '?q=*:*&amp;rows=1'))/descendant::doc/str[@name='oai_id']"/>
								</sampleIdentifier>
							</oai-identifier>
						</description>
					</Identify>
				</xsl:when>
				<xsl:when test="$verb='ListSets'">
					<ListSets>
						<set>
							<setSpec>ead</setSpec>
							<setName>Encoded Archival Description (EAD) collection of <xsl:value-of select="exsl:node-set($config)//repositoryName"/></setName>
							<setDescription>
								<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
									xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ 
									http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
									<dc:title xml:lang="en">Encoded Archival Description (EAD) collection of <xsl:value-of select="exsl:node-set($config)//repositoryName"/></dc:title>
									<dc:creator>
										<xsl:value-of select="exsl:node-set($config)//repositoryName"/>
									</dc:creator>
								</oai_dc:dc>
							</setDescription>
						</set>
					</ListSets>
				</xsl:when>
				<xsl:when test="$verb='ListMetadataFormats'">
					<ListMetadataFormats>
						<metadataFormat>
							<metadataPrefix>oai_dc</metadataPrefix>
							<schema>http://www.openarchives.org/OAI/2.0/oai_dc.xsd</schema>
							<metadataNamespace>http://www.openarchives.org/OAI/2.0/oai_dc/</metadataNamespace>
						</metadataFormat>
					</ListMetadataFormats>
				</xsl:when>
				<xsl:when test="$verb='ListRecords'">
					<xsl:choose>
						<xsl:when test="string($resumptionToken)">
							<xsl:choose>
								<xsl:when test="$resumptionToken-validate=false()">
									<error code="badResumptionToken">Invalid resumptionToken</error>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="string($metadataPrefix)">
											<xsl:choose>
												<xsl:when test="$metadataPrefix='oai_dc'">
													<!-- test resumptionToken -->
													<xsl:call-template name="validate-lists"/>
												</xsl:when>
												<xsl:otherwise>
													<error code="cannotDisseminateFormat">Cannot disseminate format.</error>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<error code="badArgument">No metadata prefix</error>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string($metadataPrefix)">
									<xsl:choose>
										<xsl:when test="$metadataPrefix='oai_dc'">
											<!-- test resumptionToken -->
											<xsl:call-template name="validate-lists"/>
										</xsl:when>
										<xsl:otherwise>
											<error code="cannotDisseminateFormat">Cannot disseminate format.</error>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<error code="badArgument">No metadata prefix</error>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$verb='ListIdentifiers'">
					<xsl:choose>
						<xsl:when test="string($resumptionToken)">
							<xsl:choose>
								<xsl:when test="$resumptionToken-validate=false()">
									<error code="badResumptionToken">Invalid resumptionToken</error>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="string($metadataPrefix)">
											<xsl:choose>
												<xsl:when test="$metadataPrefix='oai_dc'">
													<!-- test resumptionToken -->
													<xsl:call-template name="validate-lists"/>
												</xsl:when>
												<xsl:otherwise>
													<error code="cannotDisseminateFormat">Cannot disseminate format.</error>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<error code="badArgument">No metadata prefix</error>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string($metadataPrefix)">
									<xsl:choose>
										<xsl:when test="$metadataPrefix='oai_dc'">
											<!-- test resumptionToken -->
											<xsl:call-template name="validate-lists"/>
										</xsl:when>
										<xsl:otherwise>
											<error code="cannotDisseminateFormat">Cannot disseminate format.</error>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<error code="badArgument">No metadata prefix</error>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$verb='GetRecord'">
					<xsl:choose>
						<xsl:when test="$identifier">
							<xsl:variable name="identifier-validate" select="iri-to-uri($identifier) castable as xs:anyURI" as="xs:boolean"/>
							<xsl:variable name="character-pass" as="xs:boolean">
								<xsl:choose>
									<xsl:when test="$identifier-validate=true()">
										<xsl:choose>
											<xsl:when test="contains($identifier, '!') or contains($identifier, '&#x022;') or contains($identifier, '#') or contains($identifier, '[') or contains($identifier, ']') or contains($identifier, '(') or contains($identifier, ')') or contains($identifier, '{') or contains($identifier, '}')">false</xsl:when>
											<xsl:otherwise>true</xsl:otherwise>
										</xsl:choose>								
									</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>					
							<xsl:choose>
								<xsl:when test="string($metadataPrefix) and $character-pass=true()">
									<xsl:choose>
										<xsl:when test="$metadataPrefix='oai_dc'">
											<GetRecord>
												<xsl:apply-templates select="document($service)/descendant::doc" mode="ListRecords"/>
											</GetRecord>
										</xsl:when>
										<xsl:otherwise>
											<error code="cannotDisseminateFormat">Cannot disseminate format.</error>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<error code="badArgument">Bad OAI Argument</error>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<error code="badArgument">Bad OAI Argument: No identifier</error>
						</xsl:otherwise>
					</xsl:choose>
					
				</xsl:when>
				<xsl:otherwise>
					<error code="badVerb">Illegal OAI verb</error>
				</xsl:otherwise>
			</xsl:choose>
		</OAI-PMH>
	</xsl:template>

	<xsl:template match="doc" mode="ListIdentifiers">
		<header>
			<identifier>
				<xsl:value-of select="str[@name='oai_id']"/>
			</identifier>
			<datestamp>
				<xsl:value-of select="date[@name='timestamp']"/>
			</datestamp>
			<setSpec>ead</setSpec>
		</header>
	</xsl:template>

	<xsl:template match="doc" mode="ListRecords">
		<record>
			<header>
				<identifier>
					<xsl:value-of select="str[@name='oai_id']"/>
				</identifier>
				<datestamp>
					<xsl:value-of select="substring-before(date[@name='timestamp'], 'T')"/>
				</datestamp>
				<setSpec>ead</setSpec>
			</header>
			<metadata>
				<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
					xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/
					http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
					<dc:title>
						<xsl:value-of select="str[@name='unittitle_display']"/>
					</dc:title>
					<dc:publisher>
						<xsl:value-of select="exsl:node-set($config)//repositoryName"/>
					</dc:publisher>
					<dc:identifier>
						<xsl:value-of select="concat($site-url, 'show/', str[@name='id'])"/>
					</dc:identifier>
					<xsl:if test="string(str[@name='unitdate_display'])">
						<dc:date>
							<xsl:value-of select="str[@name='unitdate_display']"/>
						</dc:date>
					</xsl:if>
					<xsl:if test="string(str[@name='physdesc_display'])">
						<dc:format>
							<xsl:value-of select="str[@name='physdesc_display']"/>
						</dc:format>
					</xsl:if>
					<xsl:for-each select="arr[@name='language_facet']/str">
						<dc:language>
							<xsl:value-of select="."/>
						</dc:language>
					</xsl:for-each>
					<xsl:for-each select="arr[@name='subject_facet']/str">
						<dc:subject>
							<xsl:value-of select="."/>
						</dc:subject>
					</xsl:for-each>
					<xsl:for-each select="arr[@name='geogname_facet']/str">
						<dc:coverage>
							<xsl:value-of select="."/>
						</dc:coverage>
					</xsl:for-each>
					<dc:rights>Open for public research.</dc:rights>
					<dc:format>ead</dc:format>
				</oai_dc:dc>
			</metadata>
		</record>
	</xsl:template>

	<xsl:template name="validate-lists">
		<xsl:choose>
			<!-- if there is a string for $from or $until both both of them are invalid dates, output badArgument -->
			<xsl:when test="string(normalize-space($from)) or string(normalize-space($until))">
				<xsl:choose>
					<xsl:when test="string($from) and string($until)">
						<xsl:choose>
							<xsl:when test="$from-validate=false() or $until-validate=false()">
								<error code="badArgument">From or Until arguments invalid</error>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$verb='ListRecords'">
										<xsl:call-template name="list-records"/>
									</xsl:when>
									<xsl:when test="$verb='ListIdentifiers'">
										<xsl:call-template name="list-identifiers"/>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="string($from) and not(string($until))">
						<xsl:choose>
							<xsl:when test="$from-validate=false()">
								<error code="badArgument">From argument invalid</error>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$verb='ListRecords'">
										<xsl:call-template name="list-records"/>
									</xsl:when>
									<xsl:when test="$verb='ListIdentifiers'">
										<xsl:call-template name="list-identifiers"/>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="not(string($from)) and string($until)">
						<xsl:choose>
							<xsl:when test="$until-validate=false()">
								<error code="badArgument">Until argument invalid</error>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$verb='ListRecords'">
										<xsl:call-template name="list-records"/>
									</xsl:when>
									<xsl:when test="$verb='ListIdentifiers'">
										<xsl:call-template name="list-identifiers"/>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$verb='ListRecords'">
						<xsl:call-template name="list-records"/>
					</xsl:when>
					<xsl:when test="$verb='ListIdentifiers'">
						<xsl:call-template name="list-identifiers"/>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="list-records">
		<xsl:choose>
			<xsl:when test="count(document($service)/descendant::doc)=0">
				<error code="noRecordsMatch">No matching records in date range</error>
			</xsl:when>
			<xsl:otherwise>
				<ListRecords>
					<xsl:apply-templates select="document($service)/descendant::doc" mode="ListRecords"/>
				</ListRecords>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="list-identifiers">
		<xsl:choose>
			<xsl:when test="count(document($service)/descendant::doc)=0">
				<error code="noRecordsMatch">No matching records in date range</error>
			</xsl:when>
			<xsl:otherwise>
				<ListIdentifiers>
					<xsl:apply-templates select="document($service)/descendant::doc" mode="ListIdentifiers"/>
				</ListIdentifiers>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
