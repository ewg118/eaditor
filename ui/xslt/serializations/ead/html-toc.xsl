<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xlink="http://www.w3.org/1999/xlink"
	version="2.0">
	
	<xsl:template name="toc">
		<div class="toc">
			<!-- The Table of Contents template performs a series of tests to
				determine which elements will be included in the table
				of contents.  Each if statement tests to see if there is
				a matching element with content in the finding aid.-->
			
			<ul class="toc_ul">
				<xsl:if
					test="ead:archdesc/ead:accessrestrict or ead:archdesc/ead:userestrict or ead:archdesc/ead:prefercite or ead:archdesc/ead:altformavail or ead:archdesc/ead:accruals or ead:archdesc/ead:acqinfo or ead:archdesc/ead:appraisal or ead:archdesc/ead:custodhist or ead:archdesc/ead:processinfo or ead:archdesc/ead:descgrp[@type='admininfo']">
					<li>
						<a href="#admininfo">
							<xsl:text>Administrative Information</xsl:text>
						</a>
					</li>
				</xsl:if>
				<xsl:apply-templates select="ead:archdesc/ead:bioghist" mode="tocLink"/>
				<xsl:apply-templates select="ead:archdesc/ead:scopecontent" mode="tocLink"/>
				<xsl:apply-templates select="ead:archdesc/ead:arrangement" mode="tocLink"/>
				<xsl:apply-templates select="ead:archdesc/ead:controlaccess" mode="tocLink"/>
				<xsl:apply-templates select="ead:archdesc/ead:note" mode="tocLink"/>
				<xsl:if
					test="ead:archdesc/ead:relatedmaterial   or ead:archdesc/ead:separatedmaterial   or ead:archdesc/*/ead:relatedmaterial   or ead:archdesc/*/ead:separatedmaterial">
					<li>
						<a href="#relatedmaterial">
							<xsl:text>Related Material</xsl:text>
						</a>
					</li>
				</xsl:if>
				
				<xsl:if test="ead:archdesc/ead:otherfindaid or ead:archdesc/*/ead:otherfindaid">
					<xsl:choose>
						<xsl:when test="ead:archdesc/ead:otherfindaid">
							<xsl:apply-templates select="ead:archdesc/ead:otherfindaid" mode="tocLink"/>
						</xsl:when>
						<xsl:when test="ead:archdesc/*/ead:otherfindaid">
							<xsl:apply-templates select="ead:archdesc/*/ead:otherfindaid" mode="tocLink"/>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				
				<!--The next test covers the situation where there is more than one odd element
					in the document.-->
				<xsl:if test="ead:archdesc/ead:odd">
					<xsl:apply-templates select="ead:archdesc/ead:odd" mode="tocLink"/>
				</xsl:if>
				
				<xsl:if test="ead:archdesc/ead:bibliography    or ead:archdesc/*/ead:bibliography">
					<xsl:choose>
						<xsl:when test="ead:archdesc/ead:bibliography">
							<xsl:apply-templates select="ead:archdesc/ead:bibliography" mode="tocLink"/>
						</xsl:when>
						<xsl:when test="ead:archdesc/*/ead:bibliography">
							<xsl:apply-templates select="ead:archdesc/*/ead:bibliography" mode="tocLink"/>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				
				<xsl:if test="ead:archdesc/ead:index or ead:archdesc/*/ead:index">
					<xsl:choose>
						<xsl:when test="ead:archdesc/ead:index">
							<xsl:apply-templates select="ead:archdesc/ead:index/ead:head" mode="tocLink"/>
						</xsl:when>
						<xsl:when test="ead:archdesc/*/ead:index">
							<xsl:apply-templates select="ead:archdesc/*/ead:index/ead:head" mode="tocLink"/>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				
				<xsl:if test="ead:archdesc/ead:descgrp[not(@type='admininfo')]">
					<xsl:apply-templates select="ead:archdesc/ead:descgrp[not(@type='admininfo')]" mode="tocLink"/>
				</xsl:if>
				
				<!-- display components contents -->
				<xsl:if test="ead:archdesc/ead:dsc/ead:c[@level='series' or @level='subseries' or @level='subgrp' or @level='subcollection']">
					<li>
						<a href="#{generate-id(ead:archdesc/ead:dsc)}">
							<xsl:value-of select="eaditor:normalize_fields('dsc', $lang)"/>
						</a>
					</li>
					<ul>
						<xsl:for-each select="ead:archdesc/ead:dsc/ead:c[@level='series' or @level='subseries' or @level='subgrp' or @level='subcollection']">
							<li>
								<a href="#{@id}">
									<xsl:value-of select="ead:did/ead:unittitle"/>
								</a>
							</li>
							<xsl:if test="child::ead:c[@level='subseries']">
								<ul>
									<xsl:for-each select="ead:c[@level='subseries']">
										<li>
											<a href="#{@id}">
												<xsl:value-of select="ead:did/ead:unittitle"/>
											</a>
										</li>
									</xsl:for-each>
								</ul>
							</xsl:if>
						</xsl:for-each>
					</ul>
				</xsl:if>
			</ul>
		</div>
	</xsl:template>
	
	<xsl:template match="node()" mode="tocLink">
		<li>
			<xsl:choose>
				<xsl:when test="ead:head">
					<xsl:choose>
						<xsl:when test="@id">
							<a href="#{@id}">
								<xsl:value-of select="ead:head"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="#{generate-id(.)}">
								<xsl:value-of select="ead:head"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="@label">
					<xsl:choose>
						<xsl:when test="@id">
							<a href="#{@id}">
								<xsl:value-of select="@label"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="#{generate-id(.)}">
								<xsl:value-of select="@label"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@id">
							<a href="#{@id}">
								<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="#{generate-id(.)}">
								<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</li>
	</xsl:template>
	
</xsl:stylesheet>