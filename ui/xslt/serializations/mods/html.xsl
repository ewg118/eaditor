<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9"
	xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xlink="http://www.w3.org/1999/xlink"
	version="2.0">

	<xsl:template name="mods-content">
		<div class="row">
			<div class="col-md-12">
				<h1>
					<xsl:value-of select="mods:titleInfo/mods:title"/>
				</h1>
			</div>
			<div class="col-md-6">
				<xsl:apply-templates select="mods:name"/>
				<xsl:if test="string(mods:abstract)">
					<p>
						<xsl:value-of select="mods:abstract"/>
					</p>
				</xsl:if>
				<h2>Description of Digital Image</h2>
				<dl class="dl-horizontal">
					<dt>Image Number</dt>
					<dd>
						<xsl:value-of select="mods:identifier"/>
					</dd>
					<xsl:apply-templates select="mods:physicalDescription/mods:form"/>					
				</dl>

				<h2>Description of Original Item</h2>
				<dl class="dl-horizontal">
					<xsl:if test="string(mods:relatedItem/mods:originInfo/mods:dateCreated)">
						<dt>Date Created</dt>
						<dd>
							<xsl:value-of select="mods:relatedItem/mods:originInfo/mods:dateCreated"
							/>
						</dd>
					</xsl:if>
					<xsl:apply-templates select="mods:relatedItem/mods:physicalDescription/mods:form"/>					
					<xsl:if test="string(mods:relatedItem/mods:physicalDescription/mods:extent)">
						<dt>Extent</dt>
						<dd>
							<xsl:value-of
								select="mods:relatedItem/mods:physicalDescription/mods:extent"/>
						</dd>
					</xsl:if>
					<xsl:if test="string(mods:relatedItem/mods:location/mods:physicalLocation)">
						<dt>Physical Location</dt>
						<dd>
							<xsl:value-of
								select="mods:relatedItem/mods:location/mods:physicalLocation"/>
						</dd>
					</xsl:if>
					<xsl:if test="string(mods:relatedItem/mods:physicalDescription/mods:note)">
						<dt>Note</dt>
						<dd>
							<xsl:value-of
								select="mods:relatedItem/mods:physicalDescription/mods:note"/>
						</dd>
					</xsl:if>
				</dl>
				<xsl:if test="count(mods:subject/mods:topic) &gt; 0">
					<h2>Subjects</h2>
					<dl class="dl-horizontal">
						<xsl:for-each select="mods:subject/*">
							<dt>
								<xsl:choose>
									<xsl:when test="local-name()='genre'">Genre</xsl:when>	
									<xsl:when test="local-name()='geographic'">Geographic</xsl:when>									
									<xsl:when test="local-name()='name'">
										<xsl:choose>
											<xsl:when test="@type='personal'">Person</xsl:when>
											<xsl:when test="@type='corporate'">Corporate</xsl:when>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="local-name()='occupation'">Occupation</xsl:when>
									<xsl:when test="local-name()='topic'">Subject</xsl:when>									
								</xsl:choose>
							</dt>
							<dd>
								<xsl:variable name="facet">
									<xsl:choose>
										<xsl:when test="local-name()='genre'">genreform</xsl:when>	
										<xsl:when test="local-name()='geographic'">geogname</xsl:when>									
										<xsl:when test="local-name()='name'">
											<xsl:choose>
												<xsl:when test="@type='personal'">persname</xsl:when>
												<xsl:when test="@type='corporate'">corpname</xsl:when>
											</xsl:choose>
										</xsl:when>
										<xsl:when test="local-name()='occupation'">occupation</xsl:when>
										<xsl:when test="local-name()='topic'">subject</xsl:when>									
									</xsl:choose>
								</xsl:variable>
								<a href="{$display_path}results/?q={$facet}_facet:&#x022;{.}&#x022;">
									<xsl:value-of select="if (mods:namePart) then mods:namePart else ."/>
								</a>
								<xsl:if test="string(@valueURI)">
									<a href="{@valueURI}" rel="dcterms:subject">
										<img src="{$include_path}ui/images/external.png" alt="external link" class="external_link"/>
									</a>
								</xsl:if>
							</dd>
						</xsl:for-each>
					</dl>
				</xsl:if>
				<xsl:if test="mods:accessCondition">
					<p>
						<b>Access Condition: </b>
						<xsl:value-of select="mods:accessCondition"/>
					</p>
				</xsl:if>
				<xsl:if test="mods:note[@type='preferred_citation']">
					<p>
						<b>Preferred Citation: </b>
						<xsl:value-of select="mods:note[@type='preferred_citation']"/>
					</p>
				</xsl:if>
				<p><b>Photo Access: </b>ANS staff can log in to Staff View to see the image. Outside
					researchers please contact the ANS Archivist.</p>
			</div>
			<div class="col-md-6">
				<xsl:apply-templates select="mods:location/mods:url[@usage='primary display']"/>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="mods:form">
		<dt>Form</dt>
		<dd>
			<a
				href="{$display_path}results/?q=genreform_facet:&#x022;{.}&#x022;">
				<xsl:value-of
					select="."/>
			</a>
			<xsl:if test="string(@valueURI)">
				<a href="{@valueURI}" rel="dcterms:format">
					<img src="{$include_path}ui/images/external.png" alt="external link" class="external_link"/>
				</a>
			</xsl:if>
		</dd>
	</xsl:template>

	<xsl:template match="mods:name">
		<span>
			<b><xsl:value-of
					select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/> Name: </b>
			<xsl:value-of select="mods:namePart[1]"/>
			<xsl:if test="mods:namePart[@type='date']">
				<xsl:value-of select="mods:namePart[@type='date']"/>
			</xsl:if>
		</span>
	</xsl:template>

	<xsl:template match="mods:url">
		<img src="{.}" alt="Photograph" style="max-width:450px"/>
	</xsl:template>

</xsl:stylesheet>
