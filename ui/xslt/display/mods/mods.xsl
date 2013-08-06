<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
	
	<xsl:template name="mods-content">
		<div class="yui3-g">
			<div class="yui3-u-1-2">
				<div class="content">
					<h1>
						<xsl:value-of select="mods:titleInfo/mods:title"/>
					</h1>
					<xsl:apply-templates select="mods:name"/>
					<xsl:if test="string(mods:abstract)">
						<p>
							<xsl:value-of select="mods:abstract"/>
						</p>
					</xsl:if>
					<h2>Description of Digital Image</h2>
					<ul>
						<li>
							<b>Image Number: </b>
							<xsl:value-of select="mods:identifier"/>
						</li>
						<li>
							<b>Form: </b>
							<a href="{$display_path}results/?q=genreform_facet:&#x022;{mods:physicalDescription/mods:form}&#x022;">
								<xsl:value-of select="mods:physicalDescription/mods:form"/>
							</a>
						</li>
					</ul>
					
					<h2>Description of Original Item</h2>
					<ul>
						<xsl:if test="string(mods:relatedItem/mods:originInfo/mods:dateCreated)">
							<li>
								<b>Date Created: </b>
								<xsl:value-of select="mods:relatedItem/mods:originInfo/mods:dateCreated"/>
							</li>
						</xsl:if>
						<xsl:if test="string(mods:relatedItem/mods:physicalDescription/mods:form)">
							<li>
								<b>Form: </b>
								<a href="{$display_path}results/?q=genreform_facet:&#x022;{mods:relatedItem/mods:physicalDescription/mods:form}&#x022;">
									<xsl:value-of select="mods:relatedItem/mods:physicalDescription/mods:form"/>
								</a>
							</li>
						</xsl:if>
						<xsl:if test="string(mods:relatedItem/mods:physicalDescription/mods:extent)">
							<li>
								<b>Extent: </b>
								<xsl:value-of select="mods:relatedItem/mods:physicalDescription/mods:extent"/>
							</li>
						</xsl:if>
						<xsl:if test="string(mods:relatedItem/mods:location/mods:physicalLocation)">
							<li>
								<b>Physical Location: </b>
								<xsl:value-of select="mods:relatedItem/mods:location/mods:physicalLocation"/>
							</li>
						</xsl:if>
						<xsl:if test="string(mods:relatedItem/mods:physicalDescription/mods:note)">
							<li>
								<b>Note: </b>
								<xsl:value-of select="mods:relatedItem/mods:physicalDescription/mods:note"/>
							</li>
						</xsl:if>
					</ul>
					<xsl:if test="count(mods:subject/mods:topic) &gt; 0">
						<h2>Subjects</h2>
						<ul>
							<xsl:for-each select="mods:subject/mods:topic">
								<li>
									<b>Term: </b>
									<a href="{$display_path}results/?q=subject_facet:&#x022;{.}&#x022;">
										<xsl:value-of select="."/>
									</a>
								</li>
							</xsl:for-each>
						</ul>
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
					<p><b>Photo Access: </b>ANS staff can log in to Staff View to see the image. Outside researchers please contact the ANS Archivist.</p>
				</div>
			</div>
			<div class="yui3-u-1-2">
				<div class="content">
					<xsl:apply-templates select="mods:location/mods:url[@usage='primary display']"/>
				</div>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="mods:name">
		<span>
			<b><xsl:value-of select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/> Name: </b>
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
