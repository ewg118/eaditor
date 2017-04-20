<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:my="http://example.org/my"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xsl my" version="2.0">
	<xsl:output encoding="UTF-8" method="xml" indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:param name="mainagencycode"/>
	<xsl:param name="publisher"/>

	<xsl:variable name="agencyCode">
		<xsl:choose>
			<xsl:when test="doc-available('input:template')">
				<xsl:value-of select="doc('input:template')//ead:eadid/@mainagencycode"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('US-', $mainagencycode)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="eadid" select="replace(replace(descendant::*[local-name() = 'eadid'], ' ', '_'), '.xml', '')"/>

	

	<!-- suppress processing instructions, comments -->
	<xsl:template match="processing-instruction() | comment()"/>

	<!-- result document for matching eadid with filename -->

	<xsl:template match="*[local-name() = 'ead']">
		<xsl:element name="ead" namespace="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink">
			<xsl:namespace name="xlink">http://www.w3.org/1999/xlink</xsl:namespace>
			<xsl:choose>
				<xsl:when test="not(@xsi:noNamespaceSchemaLocation)">
					<xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
					<xsl:attribute name="xsi:schemaLocation">urn:isbn:1-931666-22-9 http://www.loc.gov/ead/ead.xsd</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@*"/>
				</xsl:otherwise>
			</xsl:choose>

			<!-- apply remaining templates -->
			<xsl:apply-templates select="*"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'eadheader']">
		<xsl:element name="eadheader" namespace="urn:isbn:1-931666-22-9">
			<xsl:apply-templates select="@* | node()"/>

			<xsl:if test="not(*:revisiondesc)">
				<xsl:element name="revisiondesc" namespace="urn:isbn:1-931666-22-9">
					<xsl:element name="change" namespace="urn:isbn:1-931666-22-9">
						<xsl:element name="date" namespace="urn:isbn:1-931666-22-9">
							<xsl:attribute name="normal" select="substring(string(current-date()), 1, 10)"/>
							<xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y0001]')"/>
						</xsl:element>
						<xsl:element name="item" namespace="urn:isbn:1-931666-22-9">Imported into EADitor. Some normalization has occurred to apply EAD 2002
							schema validation and conform to EADitor basic requirements.</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'revisiondesc']">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
			<xsl:element name="change" namespace="urn:isbn:1-931666-22-9">
				<xsl:element name="date" namespace="urn:isbn:1-931666-22-9">
					<xsl:attribute name="normal" select="substring(string(current-date()), 1, 10)"/>
					<xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y0001]')"/>
				</xsl:element>
				<xsl:element name="item" namespace="urn:isbn:1-931666-22-9">Imported into EADitor. Some normalization has occurred to apply EAD 2002 schema
					validation and conform to EADitor basic requirements.</xsl:element>
			</xsl:element>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'eadid']">
		<xsl:element name="eadid" namespace="urn:isbn:1-931666-22-9">
			<xsl:attribute name="mainagencycode" select="$agencyCode"/>
			<xsl:attribute name="countrycode">US</xsl:attribute>
			<xsl:attribute name="url" select="base-uri()"/>
			<xsl:value-of select="$eadid"/>
		</xsl:element>
	</xsl:template>

	<!-- remove unitdate from unittitle, move up a level -->
	<xsl:template match="*[local-name() = 'unittitle']">
		<xsl:element name="unittitle" namespace="urn:isbn:1-931666-22-9">
			<xsl:apply-templates select="@* | text() | node()[not(local-name() = 'unitdate')]"/>
		</xsl:element>


		<!-- unitdate is separated out as a sibling of unittitle and child of the did -->
		<xsl:if test="string(*[local-name() = 'unitdate'][1])">
			<xsl:apply-templates select="*[local-name() = 'unitdate']"/>
		</xsl:if>
	</xsl:template>

	<!-- use unnumbered components -->
	<xsl:template match="*[matches(local-name(), 'c[0-1]')]">
		<xsl:element name="c" namespace="urn:isbn:1-931666-22-9">
			<xsl:attribute name="id" select="
					if (string(@id)) then
						@id
					else
						generate-id()"/>
			<xsl:apply-templates select="@*[not(name() = 'id')] | node()"/>
		</xsl:element>
	</xsl:template>

	<!-- flatten controlaccess -->
	<xsl:template match="*[local-name() = 'controlaccess']">
		<xsl:element name="controlaccess" namespace="urn:isbn:1-931666-22-9">
			<xsl:apply-templates select="@*"/>
			<xsl:for-each
				select="
					descendant::*[local-name() = 'corpname'] | descendant::*[local-name() = 'famname'] | descendant::*[local-name() = 'function'] | descendant::*[local-name() = 'genreform'] |
					descendant::*[local-name() = 'geogname'] | descendant::*[local-name() = 'name'] | descendant::*[local-name() = 'occupation'] | descendant::*[local-name() = 'persname'] |
					descendant::*[local-name() = 'subject'] | descendant::*[local-name() = 'title']">
				<xsl:apply-templates select="self::node()"/>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*[local-name() = 'publisher']">
		<xsl:choose>
			<xsl:when test="doc-available('input:template')">
				<xsl:copy-of select="doc('input:template')//ead:publisher"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="publisher" namespace="urn:isbn:1-931666-22-9">
					<xsl:value-of select="$publisher"/>
				</xsl:element>				
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template
		match="
			*[local-name() = 'corpname'] | *[local-name() = 'famname'] | *[local-name() = 'function'] | *[local-name() = 'genreform'] | *[local-name() = 'geogname'] | *[local-name() = 'name'] |
			*[local-name() = 'occupation'] | *[local-name() = 'persname'] | *[local-name() = 'subject'] | *[local-name() = 'title']">
		<xsl:choose>
			<xsl:when test="ancestor::*:controlaccess">
				<xsl:element name="{local-name()}" namespace="urn:isbn:1-931666-22-9">
					<xsl:apply-templates select="@*"/>
					<xsl:variable name="val" select="normalize-space(.)"/>

					<!-- strip trailing periods from controlled access terms -->
					<xsl:choose>
						<xsl:when test="substring($val, string-length($val), 1) = '.'">
							<xsl:value-of select="substring($val, 1, string-length($val) - 1)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$val"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{local-name()}" namespace="urn:isbn:1-931666-22-9">
					<xsl:apply-templates select="@* | node()"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- suppress invalid dates -->
	<xsl:template match="@normal">
		<xsl:choose>
			<xsl:when test="tokenize(., '/')[2]">
				<xsl:variable name="dates" select="tokenize(., '/')"/>
				<xsl:if test="my:validateDate($dates[1]) = true() and my:validateDate($dates[2]) = true()">
					<xsl:attribute name="normal" select="."/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="my:validateDate(.) = true()">
					<xsl:attribute name="normal" select="."/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- from the dtd2schema.xsl -->
	<xsl:template match="@*">
		<xsl:choose>
			<xsl:when test="normalize-space(.) = ''"/>

			<!-- UNCOMMENT the following line if mainagencycode can be verified to validate.  If it does not validate to the schema, it cannot be posted to eXist! -->
			<!--<xsl:when test="name(.) = 'mainagencycode'">
				<xsl:attribute name="{name(.)}">
					<xsl:value-of select="concat('US-', $agencyCode)"/>
				</xsl:attribute>
			</xsl:when>-->
			<!--<xsl:when test="name(.) = 'repositorycode'">
				<xsl:attribute name="{name(.)}">
					<xsl:value-of select="concat('US-', $agencyCode)"/>
				</xsl:attribute>
			</xsl:when>-->
			<!--<xsl:when test="name() = 'countrycode'">
				<xsl:attribute name="{name()}">US</xsl:attribute>
			</xsl:when>-->
			<xsl:when test="name(.) = 'type' and parent::*/local-name() = 'container'">
				<xsl:attribute name="{name(.)}">
					<xsl:value-of select="lower-case(.)"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="{name(.)}">
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*">
		<xsl:element name="{name()}" namespace="urn:isbn:1-931666-22-9">
			<xsl:apply-templates select="* | @* | text()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="text()">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

	<!-- strip frontmatter -->
	<xsl:template match="*[local-name() = 'frontmatter']"/>

	<!--========== XLINK ==========-->

	<!-- arc-type elements-->
	<xsl:template match="arc">
		<xsl:element name="{name()}" namespace="urn:isbn:1-931666-22-9">
			<xsl:attribute name="xlink:type">arc</xsl:attribute>
			<xsl:call-template name="xlink_attrs"/>
		</xsl:element>
	</xsl:template>

	<!-- extended-type elements-->
	<xsl:template match="daogrp | linkgrp">
		<xsl:element name="{name()}" namespace="urn:isbn:1-931666-22-9">
			<xsl:attribute name="xlink:type">extended</xsl:attribute>
			<xsl:call-template name="xlink_attrs"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<!-- locator-type elements-->
	<xsl:template match="daoloc | extptrloc | extrefloc | ptrloc | refloc">
		<xsl:element name="{name()}" namespace="urn:isbn:1-931666-22-9">
			<xsl:attribute name="xlink:type">locator</xsl:attribute>
			<xsl:call-template name="xlink_attrs"/>
			<xsl:call-template name="hrefHandler"/>
		</xsl:element>
	</xsl:template>

	<!-- resource-type elements-->
	<xsl:template match="resource">
		<xsl:element name="{name()}" namespace="urn:isbn:1-931666-22-9">
			<xsl:attribute name="xlink:type">resource</xsl:attribute>
			<xsl:call-template name="xlink_attrs"/>
		</xsl:element>
	</xsl:template>

	<!-- simple-type elements-->
	<xsl:template match="archref | bibref | dao | extptr | extref | ptr | ref | title">
		<xsl:element name="{name()}" namespace="urn:isbn:1-931666-22-9">
			<xsl:attribute name="xlink:type">simple</xsl:attribute>
			<xsl:call-template name="xlink_attrs"/>
			<xsl:call-template name="hrefHandler"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<!-- attribute handling -->
	<xsl:template name="xlink_attrs">
		<xsl:for-each select="@*">
			<xsl:choose>
				<xsl:when test="name() = 'actuate'">
					<xsl:attribute name="xlink:actuate">
						<xsl:choose>
							<!--EAD's actuateother and actuatenone do not exist in xlink-->
							<xsl:when test=". = 'onload'">onLoad</xsl:when>
							<xsl:when test=". = 'onrequest'">onRequest</xsl:when>
							<xsl:when test=". = 'actuateother'">other</xsl:when>
							<xsl:when test=". = 'actuatenone'">none</xsl:when>
						</xsl:choose>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="name() = 'show'">
					<xsl:attribute name="xlink:show">
						<xsl:choose>
							<!--EAD's showother and shownone do not exist in xlink-->
							<xsl:when test=". = 'new'">new</xsl:when>
							<xsl:when test=". = 'replace'">replace</xsl:when>
							<xsl:when test=". = 'embed'">embed</xsl:when>
							<xsl:when test=". = 'showother'">other</xsl:when>
							<xsl:when test=". = 'shownone'">none</xsl:when>
						</xsl:choose>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="name() = 'arcrole' or name() = 'from' or name() = 'label' or name() = 'role' or name() = 'title' or name() = 'to'">
					<xsl:attribute name="xlink:{name()}">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="name() = 'linktype' or name() = 'href' or name() = 'xpointer' or name() = 'entityref'"/>
				<xsl:otherwise>
					<xsl:apply-templates select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="hrefHandler">
		<xsl:attribute name="xlink:href">
			<xsl:choose>
				<xsl:when test="@entityref and not(@href)">
					<!-- This will resolve the entity sysid as an absolute path. 
						If the desired result is a relative path, then use XSLT
						string functions to "reduce" the absolute path to a
						relative path.
					-->
					<xsl:value-of select="unparsed-entity-uri(@entityref)"/>
				</xsl:when>
				<xsl:when test="@href and @entityref">
					<xsl:value-of select="@href"/>
				</xsl:when>
				<xsl:when test="@href and not(@entityref)">
					<xsl:value-of select="@href"/>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			<xsl:value-of select="@xpointer"/>
		</xsl:attribute>
	</xsl:template>


	<!--========== END XLINK ==========-->

	<!-- function for date validation -->
	<xsl:function name="my:validateDate" as="xs:boolean">
		<xsl:param name="date"/>

		<xsl:choose>
			<xsl:when test="$date castable as xs:date or $date castable as xs:gYear or $date castable as xs:gYearMonth">
				<xsl:choose>
					<xsl:when test="number($date) and number($date) &gt; 2099">false</xsl:when>
					<xsl:otherwise>true</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>

	</xsl:function>
</xsl:stylesheet>
