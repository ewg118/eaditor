<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
	version="2.0">
	<!-- ********************************** FUNCTIONS ************************************ -->

	<!-- data normalization -->
	<xsl:function name="eaditor:normalize_century">
		<xsl:param name="name"/>
		<xsl:value-of select="concat($name, '00s')"/>
	</xsl:function>	

	<xsl:function name="eaditor:normalize_fields">
		<xsl:param name="field"/>
		<xsl:param name="lang"/>

		<xsl:variable name="elem" select="if (contains($field, '_')) then substring-before($field, '_') else $field"/>

		<xsl:choose>
			<xsl:when test="$lang='fr'"> </xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$elem = 'abstract'">Abstract</xsl:when>
					<xsl:when test="$elem = 'accessrestrict'">Access Restriction</xsl:when>
					<xsl:when test="$elem = 'accruals'">Accruals</xsl:when>
					<xsl:when test="$elem = 'acqinfo'">Acquisition Information</xsl:when>
					<xsl:when test="$elem = 'agency'">Agency</xsl:when>
					<xsl:when test="$elem = 'altformavail'">Alternate Form Available</xsl:when>
					<xsl:when test="$elem = 'appraisal'">Appraisal</xsl:when>
					<xsl:when test="$elem = 'arrangement'">Arrangement</xsl:when>
					<xsl:when test="$elem = 'bibliography'">Bibliography</xsl:when>
					<xsl:when test="$elem = 'bioghist'">Biographical/Historical Commentary</xsl:when>
					<xsl:when test="$elem = 'century'">Century</xsl:when>
					<xsl:when test="$elem = 'container'">Container</xsl:when>
					<xsl:when test="$elem = 'controlaccess'">Controlled Access Headings</xsl:when>
					<xsl:when test="$elem = 'corpname'">Corporate Name</xsl:when>
					<xsl:when test="$elem = 'custodhist'">Custodial History</xsl:when>
					<xsl:when test="$elem = 'decade'">Decade</xsl:when>
					<xsl:when test="$elem = 'descgrp'">Descriptive Group</xsl:when>
					<xsl:when test="$elem = 'dimensions'">Dimensions</xsl:when>
					<xsl:when test="$elem = 'extent'">Extent</xsl:when>
					<xsl:when test="$elem = 'famname'">Family Name</xsl:when>
					<xsl:when test="$elem = 'fileplan'">Fileplan</xsl:when>
					<xsl:when test="$elem = 'fulltext'">Keyword</xsl:when>
					<xsl:when test="$elem = 'genreform'">Genre/Format</xsl:when>
					<xsl:when test="$elem = 'geogname'">Geographical Name</xsl:when>
					<xsl:when test="$elem = 'langmaterial'">Language</xsl:when>
					<xsl:when test="$elem = 'language'">Language</xsl:when>
					<xsl:when test="$elem = 'materialspec'">Technical</xsl:when>
					<xsl:when test="$elem = 'note'">Note</xsl:when>
					<xsl:when test="$elem = 'odd'">Other Descriptive Data</xsl:when>
					<xsl:when test="$elem = 'originalsloc'">Location of Originals</xsl:when>
					<xsl:when test="$elem = 'origination'">Creator</xsl:when>
					<xsl:when test="$elem = 'otherfindaid'">Other Finding Aid</xsl:when>
					<xsl:when test="$elem = 'persname'">Personal Name</xsl:when>
					<xsl:when test="$elem = 'physfacet'">Physical Facet</xsl:when>
					<xsl:when test="$elem = 'physloc'">Location</xsl:when>
					<xsl:when test="$elem = 'phystech'">Physical Characteristics</xsl:when>
					<xsl:when test="$elem = 'prefercite'">Preferred Citation</xsl:when>
					<xsl:when test="$elem = 'processinfo'">Processing Information</xsl:when>
					<xsl:when test="$elem = 'relatedmaterial'">Related Material</xsl:when>
					<xsl:when test="$elem = 'repository'">Repository</xsl:when>
					<xsl:when test="$elem = 'scopecontent'">Scope and Content</xsl:when>
					<xsl:when test="$elem = 'separatedmaterial'">Separated Material</xsl:when>
					<xsl:when test="$elem = 'subject'">Subject</xsl:when>
					<xsl:when test="$elem = 'timestamp'">Record publication date</xsl:when>
					<xsl:when test="$elem = 'unittitle'">Title</xsl:when>
					<xsl:when test="$elem = 'unitid'">Unit ID</xsl:when>
					<xsl:when test="$elem = 'userestrict'">Use Restriction</xsl:when>
					<xsl:when test="$elem = 'year'">Year</xsl:when>
					<xsl:otherwise>
						<xsl:text>[</xsl:text>
						<xsl:value-of select="$elem"/>
						<xsl:text>]</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- flickr API -->
	<xsl:function name="eaditor:get_flickr_uri">
		<xsl:param name="photo_id"/>
		<xsl:value-of
			select="document(concat('http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&amp;api_key=', $flickr-api-key, '&amp;photo_id=', $photo_id, '&amp;format=rest'))/rsp/photo/urls/url[@type='photopage']"
		/>
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