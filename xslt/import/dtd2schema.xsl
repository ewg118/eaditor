<?xml version="1.0" encoding="UTF-8"?>
<!--
	EAD DTD to Schema XSLT Conversion
	Version: 200701 Alpha
	Date: 20070116
	
	Editors: Stephen Yearl (Yale) and Daniel V. PItti (Virginia)
	
	This XSLT stylesheet takes an EAD instance valid against the 2002 EAD DTD and transforms
	it into a valid instance against either the EAD Relax NG Schema or the W3C Schema. 
	
	The transformation changes all XLINK compatible elements and attributes into XLINK 
	compliant elements and attributes. No other significant changes are intended. Report
	and unintended changes to the EAD listserv: 
	
	Listserv address: EAD@LOC.GOV
    
	Before using this stylesheet, please set the following variables:
	
	schema: value options are "RNG" or "W3C" Default: "W3C"
	
	schemaPath: value should be the directory where the schema is located. Default: ""
	
	This stylesheet does not attempt to "normalize" the following attributes, all of
	which are subject to datatype constraints in the schema:
	
	@normal on <unitdate> and <date>: constrained to date and date range subset of ISO 8601
	@repositorycode: constrained to ISO 15511 (ISIL) 
	@mainagencycode: same as @repositorycode
	@langcode: constrained to ISO 639-2 alpha-3 code list
	@scriptcode: constrained to ISO 15924 code list
	@countrycode: constrained to ISO 3166-1 alpha-2 code list
	
	Future versions of the stylesheet may offer, as an option, such normalization for
	some and perhaps all of the attributes. 

    -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:isbn:1-931666-22-9" exclude-result-prefixes="xsi">

	<xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes" encoding="UTF-8"/>

	<!-- Resulting document: W3C ready? Or RNG (Oxygent) ready? -->

	<xsl:variable name="schema">
		<xsl:text>W3C</xsl:text>
		<!-- Alternatives RNG or W3C-->
	</xsl:variable>

	<!-- Path to schema -->

	<xsl:variable name="schemaPath">
		<xsl:text>http://www.loc.gov/ead/</xsl:text>
	</xsl:variable>

	<!-- Variables for namespace and processing instructions -->


	<xsl:variable name="oXygen_pi">
		<xsl:text>RNGSchema="</xsl:text>
		<xsl:value-of select="$schemaPath"/>
		<xsl:text>ead.rng"</xsl:text>
		<xsl:text> type="xml"</xsl:text>
	</xsl:variable>

	<xsl:variable name="xlink_ns">
		<xsl:text>http://www.w3.org/1999/xlink</xsl:text>
	</xsl:variable>

	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
		<xsl:if test="$schema='RNG'">
			<xsl:text>
</xsl:text>
			<xsl:processing-instruction name="oxygen">
				<xsl:value-of select="$oXygen_pi"/>
			</xsl:processing-instruction>
			<xsl:text>
</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="*|comment()|processing-instruction()"/>
	</xsl:template>

	<xsl:template match="ead">
		<xsl:choose>
			<xsl:when test="$schema='RNG'">
				<ead>
					<xsl:apply-templates select="*|text()|@*|processing-instruction()|comment()"/>
				</ead>
			</xsl:when>
			<xsl:when test="$schema='W3C'">
				<ead xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
					<xsl:attribute name="xsi:schemaLocation">
						<xsl:text>urn:isbn:1-931666-22-9 </xsl:text>
						<xsl:value-of select="$schemaPath"/>
						<xsl:text>ead.xsd</xsl:text>
					</xsl:attribute>
					<xsl:apply-templates select="*|text()|@*|processing-instruction()|comment()"/>
				</ead>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*">
		<xsl:choose>
			<xsl:when test="normalize-space(.)= ''"/>
			
			<!-- UNCOMMENT the following line if mainagencycode can be verified to validate.  If it does not validate to the schema, it cannot be posted to eXist! -->
			<xsl:when test="name(.) = 'mainagencycode'"/>
			<xsl:otherwise>
				<xsl:attribute name="{name(.)}">
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*|@*|comment()|processing-instruction()|text()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="comment()|processing-instruction()">
		<xsl:copy/>
	</xsl:template>

	<!--========== XLINK ==========-->

	<!-- arc-type elements-->
	<xsl:template match="arc">
		<xsl:element name="{name()}">
			<xsl:attribute name="xlink:type">arc</xsl:attribute>
			<xsl:call-template name="xlink_attrs"/>
		</xsl:element>
	</xsl:template>

	<!-- extended-type elements-->
	<xsl:template match="daogrp | linkgrp">
		<xsl:element name="{name()}">
			<xsl:attribute name="xlink:type">extended</xsl:attribute>
			<xsl:call-template name="xlink_attrs"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<!-- locator-type elements-->
	<xsl:template match="daoloc | extptrloc | extrefloc | ptrloc | refloc">
		<xsl:element name="{name()}">
			<xsl:attribute name="xlink:type">locator</xsl:attribute>
			<xsl:call-template name="xlink_attrs"/>
			<xsl:call-template name="hrefHandler"/>
		</xsl:element>
	</xsl:template>

	<!-- resource-type elements-->
	<xsl:template match="resource">
		<xsl:element name="{name()}">
			<xsl:attribute name="xlink:type">resource</xsl:attribute>
			<xsl:call-template name="xlink_attrs"/>
		</xsl:element>
	</xsl:template>

	<!-- simple-type elements-->
	<xsl:template match="archref | bibref | dao | extptr | extref | ptr | ref | title">
		<xsl:element name="{name()}">
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
				<xsl:when test="name()='actuate'">
					<xsl:attribute name="xlink:actuate">
						<xsl:choose>
							<!--EAD's actuateother and actuatenone do not exist in xlink-->
							<xsl:when test=".='onload'">onLoad</xsl:when>
							<xsl:when test=".='onrequest'">onRequest</xsl:when>
							<xsl:when test=".='actuateother'">other</xsl:when>
							<xsl:when test=".='actuatenone'">none</xsl:when>
						</xsl:choose>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="name()='show'">
					<xsl:attribute name="xlink:show">
						<xsl:choose>
							<!--EAD's showother and shownone do not exist in xlink-->
							<xsl:when test=".='new'">new</xsl:when>
							<xsl:when test=".='replace'">replace</xsl:when>
							<xsl:when test=".='embed'">embed</xsl:when>
							<xsl:when test=".='showother'">other</xsl:when>
							<xsl:when test=".='shownone'">none</xsl:when>
						</xsl:choose>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="name()='arcrole' or name()='from' or       name()='label' or name()='role' or       name()='title' or name()='to'">
					<xsl:attribute name="xlink:{name()}">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="name()='linktype' or name()='href' or      name()='xpointer' or name()='entityref'"/>
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
				<xsl:when test="@href and @entityref ">
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


</xsl:stylesheet>