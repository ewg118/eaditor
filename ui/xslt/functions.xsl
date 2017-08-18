<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
	version="2.0">
	<!-- ********************************** FUNCTIONS ************************************ -->

	<!-- data normalization -->
	<xsl:function name="eaditor:normalize_century">
		<xsl:param name="name"/>
		<xsl:variable name="cleaned" select="number(translate($name, '\', ''))"/>
		<xsl:variable name="century" select="abs($cleaned)"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$century mod 10 = 1 and $century != 11">
					<xsl:text>st</xsl:text>
				</xsl:when>
				<xsl:when test="$century mod 10 = 2 and $century != 12">
					<xsl:text>nd</xsl:text>
				</xsl:when>
				<xsl:when test="$century mod 10 = 3 and $century != 13">
					<xsl:text>rd</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>th</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat($century, $suffix)"/>
		<xsl:if test="$cleaned &lt; 0">
			<xsl:text> B.C.</xsl:text>
		</xsl:if>
	</xsl:function>	

	<xsl:template name="eaditor:get_date_hierarchy">
		<xsl:param name="date"/>
		
		<xsl:if test="$date castable as xs:gYear">
			<xsl:variable name="year_string" select="string(abs(number($date)))"/>
			<xsl:variable name="century"
				select="
				if (number($date) &gt; 0) then
				ceiling(number($date) div 100)
				else
				floor(number($date) div 100)"/>
			<xsl:variable name="decade" select="floor(abs(number($date)) div 10) * 10"/>
			
			<xsl:if test="number($century)">
				<field name="century_num">
					<xsl:if test="$upload = true()">
						<xsl:attribute name="update">set</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$century"/>
				</field>
			</xsl:if>
			<field name="decade_num">
				<xsl:if test="$upload = true()">
					<xsl:attribute name="update">set</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="$decade"/>
			</field>
			<xsl:if test="number($date)">
				<field name="year_num">
					<xsl:if test="$upload = true()">
						<xsl:attribute name="update">set</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="number($date)"/>
				</field>
			</xsl:if>
		</xsl:if>
	</xsl:template>

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
					<xsl:when test="$elem = 'controlaccess'">Related Entities</xsl:when>
					<xsl:when test="$elem = 'corpname'">Organization</xsl:when>
					<xsl:when test="$elem = 'custodhist'">Custodial History</xsl:when>
					<xsl:when test="$elem = 'date'">Date</xsl:when>
					<xsl:when test="$elem = 'decade'">Decade</xsl:when>
					<xsl:when test="$elem = 'descgrp'">Descriptive Group</xsl:when>
					<xsl:when test="$elem = 'dimensions'">Dimensions</xsl:when>
					<xsl:when test="$elem = 'dsc'">Collection Hierarchy</xsl:when>
					<xsl:when test="$elem = 'extent'">Extent</xsl:when>
					<xsl:when test="$elem = 'famname'">Family</xsl:when>
					<xsl:when test="$elem = 'fileplan'">Fileplan</xsl:when>
					<xsl:when test="$elem = 'text'">Keyword</xsl:when>
					<xsl:when test="$elem = 'function'">Function</xsl:when>
					<xsl:when test="$elem = 'genreform'">Genre/Format</xsl:when>
					<xsl:when test="$elem = 'geogname'">Place</xsl:when>
					<xsl:when test="$elem = 'langmaterial'">Language</xsl:when>
					<xsl:when test="$elem = 'language'">Language</xsl:when>
					<xsl:when test="$elem = 'level'">Level</xsl:when>
					<xsl:when test="$elem = 'materialspec'">Technical</xsl:when>
					<xsl:when test="$elem = 'name'">Name</xsl:when>
					<xsl:when test="$elem = 'note'">Note</xsl:when>
					<xsl:when test="$elem = 'occupation'">Occupation</xsl:when>
					<xsl:when test="$elem = 'odd'">Other Descriptive Data</xsl:when>
					<xsl:when test="$elem = 'originalsloc'">Location of Originals</xsl:when>
					<xsl:when test="$elem = 'origination'">Creator</xsl:when>
					<xsl:when test="$elem = 'otherfindaid'">Other Finding Aid</xsl:when>
					<xsl:when test="$elem = 'persname'">Person</xsl:when>
					<xsl:when test="$elem = 'physdesc'">Physical Description</xsl:when>
					<xsl:when test="$elem = 'physfacet'">Physical Facet</xsl:when>
					<xsl:when test="$elem = 'physloc'">Location</xsl:when>
					<xsl:when test="$elem = 'phystech'">Physical Characteristics</xsl:when>
					<xsl:when test="$elem = 'prefercite'">Preferred Citation</xsl:when>
					<xsl:when test="$elem = 'processinfo'">Processing Information</xsl:when>
					<xsl:when test="$elem = 'publisher'">Publisher</xsl:when>
					<xsl:when test="$elem = 'relatedmaterial'">Related Material</xsl:when>
					<xsl:when test="$elem = 'repository'">Repository</xsl:when>
					<xsl:when test="$elem = 'scopecontent'">Scope and Content</xsl:when>
					<xsl:when test="$elem = 'separatedmaterial'">Separated Material</xsl:when>
					<xsl:when test="$elem = 'subject'">Subject</xsl:when>
					<xsl:when test="$elem = 'timestamp'">Record publication date</xsl:when>
					<xsl:when test="$elem = 'title'">Title</xsl:when>
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
		<!--<xsl:value-of
			select="document(concat('https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&amp;api_key=', //config/flickr_api_key, '&amp;photo_id=', $photo_id, '&amp;format=rest'))/rsp/photo/urls/url[@type='photopage']"
		/>-->
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
