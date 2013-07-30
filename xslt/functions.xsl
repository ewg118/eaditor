<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eaditor="http://code.google.com/p/eaditor/" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
	version="2.0">
	<!-- ********************************** FUNCTIONS ************************************ -->
	<xsl:function name="eaditor:normalize_century">
		<xsl:param name="name"/>
		<xsl:value-of select="concat($name, '00s')"/>
	</xsl:function>

	<xsl:function name="eaditor:normalize_fields">
		<xsl:param name="field"/>
		<xsl:choose>
			<xsl:when test="$field = 'agency_facet'">Agency</xsl:when>
			<xsl:when test="$field = 'century_sint'">Century</xsl:when>
			<xsl:when test="$field = 'corpname_facet'">Corporate Name</xsl:when>
			<xsl:when test="$field = 'decade_sint'">Decade</xsl:when>
			<xsl:when test="$field = 'famname_facet'">Family Name</xsl:when>
			<xsl:when test="$field = 'genreform_facet'">Genre/Format</xsl:when>
			<xsl:when test="$field = 'geogname_facet'">Geographical Name</xsl:when>
			<xsl:when test="$field = 'language_facet'">Language</xsl:when>
			<xsl:when test="$field = 'persname_facet'">Personal Name</xsl:when>
			<xsl:when test="$field = 'subject_facet'">Subject</xsl:when>
			<xsl:when test="$field = 'fulltext'">Keyword</xsl:when>
			<xsl:otherwise>Undefined Category</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- ********************************** TEMPLATES ************************************ -->

	<xsl:template name="multifields">
		<xsl:param name="field"/>
		<xsl:param name="position"/>
		<xsl:param name="fragments"/>
		<xsl:param name="count"/>

		<xsl:if test="substring-before($fragments[$position], ':') != $field">
			<xsl:text>true</xsl:text>
		</xsl:if>
		<xsl:if test="$position &lt; $count and substring-before($fragments[$position], ':') = $field">
			<xsl:call-template name="multifields">
				<xsl:with-param name="position" select="$position + 1"/>
				<xsl:with-param name="fragments" select="$fragments"/>
				<xsl:with-param name="field" select="$field"/>
				<xsl:with-param name="count" select="$count"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
