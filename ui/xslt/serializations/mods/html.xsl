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
					<dt>Form</dt>
					<dd>
						<a
							href="{$display_path}results/?q=genreform_facet:&#x022;{mods:physicalDescription/mods:form}&#x022;">
							<xsl:value-of select="mods:physicalDescription/mods:form"/>
						</a>
					</dd>
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
					<xsl:if test="string(mods:relatedItem/mods:physicalDescription/mods:form)">
						<dt>Form</dt>
						<dd>
							<a
								href="{$display_path}results/?q=genreform_facet:&#x022;{mods:relatedItem/mods:physicalDescription/mods:form}&#x022;">
								<xsl:value-of
									select="mods:relatedItem/mods:physicalDescription/mods:form"/>
							</a>
						</dd>
					</xsl:if>
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
						<xsl:for-each select="mods:subject/mods:topic">
							<dt>Term</dt>
							<dd>
								<a href="{$display_path}results/?q=subject_facet:&#x022;{.}&#x022;">
									<xsl:value-of select="."/>
								</a>
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
