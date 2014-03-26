<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:eaditor="https://github.com/ewg118/eaditor" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">

	<xsl:template name="ead-content">
		<!-- display component if there's an $id, otherwise whole finding aid -->
		<xsl:choose>
			<xsl:when test="string($id)">
				<div class="yui3-g">
					<div class="yui3-u-1">
						<div class="content">
							<xsl:call-template name="component-template"/>
						</div>
					</div>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div class="yui3-g">
					<!-- display archdesc/did, collection image, and map if available -->
					<div class="yui3-u-1">
						<xsl:call-template name="head"/>
						<xsl:call-template name="body"/>
					</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="head">
		<h1>
			<span property="dcterms:title">
				<xsl:value-of select="ead:archdesc/ead:did/ead:unittitle"/>
			</span>
			<xsl:if test="string(ead:archdesc/ead:did/ead:unitdate)">
				<xsl:text>, </xsl:text>
				<span>
					<xsl:value-of select="ead:archdesc/ead:did/ead:unitdate"/>
				</span>
			</xsl:if>
		</h1>
		<xsl:choose>
			<xsl:when test="ead:archdesc/ead:did/ead:dao/@xlink:href">
				<div class="yui3-u-1-2">
					<div class="content">
						<xsl:apply-templates select="ead:archdesc/ead:did"/>
					</div>
				</div>
				<div class="yui3-u-1-2">
					<div class="content">
						<xsl:apply-templates select="ead:archdesc/ead:did/ead:dao"/>
					</div>
				</div>
			</xsl:when>
			<xsl:when test="contains(ead:archdesc/ead:did/ead:daogrp/ead:daoloc[@xlink:label='Small']/@xlink:href, 'flickr.com')">
				<div class="yui3-u-1-2">
					<div class="content">
						<xsl:apply-templates select="ead:archdesc/ead:did"/>
					</div>
				</div>
				<div class="yui3-u-1-2">
					<div class="content">
						<xsl:apply-templates select="ead:archdesc/ead:did/ead:daogrp/ead:daoloc[@xlink:label='Small']" mode="collection-image"/>
					</div>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div class="yui3-u-1">
					<div class="content">
						<xsl:apply-templates select="ead:archdesc/ead:did"/>
					</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="body">
		<div id="tabs">
			<ul>
				<li>
					<a href="#summary">Summary</a>
				</li>
				<xsl:if test="$hasPoints = true()">
					<li>
						<a href="#mapTab">Map</a>
					</li>
				</xsl:if>
			</ul>
			<div id="summary">
				<div class="yui3-u-1-5">
					<div class="content">
						<xsl:call-template name="toc"/>
					</div>
				</div>
				<div class="yui3-u-4-5">
					<div class="content">
						<div id="archdesc-info">
							<xsl:call-template name="archdesc-admininfo"/>
							<xsl:apply-templates select="ead:archdesc/ead:bioghist"/>
							<xsl:apply-templates select="ead:archdesc/ead:scopecontent"/>
							<xsl:apply-templates select="ead:archdesc/ead:arrangement"/>
							<xsl:call-template name="archdesc-relatedmaterial"/>
							<xsl:apply-templates select="ead:archdesc/ead:controlaccess"/>
							<xsl:apply-templates select="ead:archdesc/ead:odd"/>
							<xsl:apply-templates select="ead:archdesc/ead:originalsloc"/>
							<xsl:apply-templates select="ead:archdesc/ead:phystech"/>
							<xsl:apply-templates select="ead:archdesc/ead:descgrp[not(@type='admininfo')]"/>
							<xsl:apply-templates select="ead:archdesc/ead:otherfindaid | ead:archdesc/*/ead:otherfindaid"/>
							<xsl:apply-templates select="ead:archdesc/ead:fileplan | ead:archdesc/*/ead:fileplan"/>
							<xsl:apply-templates select="ead:archdesc/ead:bibliography | ead:archdesc/*/ead:bibliography"/>
							<xsl:apply-templates select="ead:archdesc/ead:index | ead:archdesc/*/ead:index"/>
						</div>
						<div id="dsc">
							<xsl:apply-templates select="ead:archdesc/ead:dsc"/>
						</div>
					</div>
				</div>
			</div>
			<xsl:if test="$hasPoints = true()">
				<div id="mapTab">
					<div id="timemap">
						<div id="mapcontainer">
							<div id="map"/>
						</div>
						<div id="timelinecontainer">
							<div id="timeline"/>
						</div>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

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
				<xsl:if test="ead:archdesc/ead:relatedmaterial   or ead:archdesc/ead:separatedmaterial   or ead:archdesc/*/ead:relatedmaterial   or ead:archdesc/*/ead:separatedmaterial">
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
						<a href="#{generate-id(ead:archdesc/ead:dsc)}">Components List</a>
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

	<!--EAD Header: becoming deprecated in EAD 3.-->
	<!--<xsl:template match="ead:eadheader">
		<xsl:apply-templates select="/ead:ead/ead:frontmatter/ead:titlepage"/>
	</xsl:template>-->

	<!--This template creates a table for the did, inserts the head and then
      each of the other did elements.  To change the order of appearance of these
      elements, change the sequence of the apply-templates statements.-->
	<xsl:template match="ead:archdesc/ead:did">
		<div id="archdesc-did">
			<a name="{generate-id(.)}"/>
			<h2>
				<xsl:choose>
					<xsl:when test="ead:head">
						<xsl:apply-templates select="ead:head"/>
					</xsl:when>
					<xsl:otherwise>Descriptive Identification</xsl:otherwise>
				</xsl:choose>
			</h2>
			<xsl:choose>
				<xsl:when test="ead:dao/@xlink:href">
					<table>
						<tr>
							<td style="width:60%">
								<xsl:call-template name="archdesc-did-elements"/>
							</td>
							<td style="width:40%">
								<xsl:apply-templates select="ead:dao"/>
							</td>
						</tr>
					</table>
				</xsl:when>
				<xsl:when test="contains(ead:daogrp/ead:daoloc[@label='Small']/@xlink:href, 'flickr.com')">
					<table>
						<tr>
							<td style="width:60%">
								<xsl:call-template name="archdesc-did-elements"/>
							</td>
							<td style="width:40%">
								<xsl:apply-templates select="ead:daogrp/ead:daoloc[@xlink:label='Small']" mode="flickr-image"/>
							</td>
						</tr>
					</table>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="archdesc-did-elements"/>
				</xsl:otherwise>
			</xsl:choose>
			<!--One can change the order of appearance for the children of did
		by changing the order of the following statements.-->

		</div>
	</xsl:template>

	<xsl:template name="archdesc-did-elements">
		<dl class="archdesc-did-elements">
			<xsl:apply-templates select="ead:unitid"/>
			<xsl:apply-templates select="ead:container"/>
			<xsl:apply-templates select="ead:repository"/>
			<xsl:apply-templates select="ead:physdesc/ead:extent"/>
			<xsl:apply-templates select="ead:physdesc/ead:dimensions"/>
			<xsl:apply-templates select="ead:physdesc/ead:genreform"/>
			<xsl:apply-templates select="ead:physdesc/ead:physfacet"/>
			<xsl:apply-templates select="ead:origination"/>
			<xsl:apply-templates select="ead:physloc"/>
			<xsl:apply-templates select="ead:langmaterial"/>
			<xsl:apply-templates select="ead:materialspec"/>
			<xsl:apply-templates select="ead:abstract"/>
			<xsl:apply-templates select="ead:note"/>
		</dl>
	</xsl:template>

	<!--This template formats the repostory, origination, physdesc, abstract,
      unitid, physloc and materialspec elements of ead:archdesc/did which share a common presentaiton.
      The sequence of their appearance is governed by the previous template.-->
	<xsl:template
		match="ead:repository | ead:origination | ead:physdesc/ead:extent | ead:physdesc/ead:dimensions | ead:physdesc/ead:genreform | ead:physdesc/ead:physfacet | ead:unitid | ead:physloc | ead:abstract | ead:langmaterial | ead:materialspec | ead:container">
		<dt>
			<xsl:choose>
				<xsl:when test="local-name()='container'">
					<xsl:choose>
						<xsl:when test="string(@type)">
							<xsl:value-of select="concat(upper-case(substring(@type, 1, 1)), substring(@type, 2))"/>
						</xsl:when>
						<!-- display type of the preceding sibling which has a type, if type for current container is not explicit -->
						<!--<xsl:when test="parent::ead:did/parent::ead:c/preceding-sibling::ead:c/ead:did/ead:container[string(@type)]">
							<xsl:variable name="type" select="parent::ead:did/parent::ead:c/preceding-sibling::ead:c/ead:did/ead:container/@type"/>
							<xsl:value-of select="concat(upper-case(substring($type, 1, 1)), substring($type, 2))"/>
							</xsl:when>-->
						<xsl:otherwise>
							<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="string(normalize-space(@label))">
					<xsl:value-of select="normalize-space(@label)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
				</xsl:otherwise>
			</xsl:choose>
		</dt>
		<dd>
			<!-- insert applicable RDFa attributes -->
			<xsl:choose>
				<xsl:when test="local-name()='abstract'">
					<xsl:attribute name="property">dcterms:abstract</xsl:attribute>
				</xsl:when>
				<xsl:when test="local-name()='extent'">
					<xsl:attribute name="property">dcterms:extent</xsl:attribute>
				</xsl:when>
				<xsl:when test="local-name()='origination'">
					<xsl:attribute name="property">dcterms:creator</xsl:attribute>
				</xsl:when>
				<xsl:when test="local-name()='unitid'">
					<xsl:attribute name="property">dcterms:identifier</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates/>
		</dd>
	</xsl:template>


	<!-- The following two templates test for and processes various permutations
      of unittitle and unitdate.-->
	<xsl:template match="ead:archdesc/ead:did/ead:unittitle">
		<!--The template tests to see if there is a label attribute for unittitle,
		inserting the contents if there is or adding one if there isn't. -->
		<div style="display:table;width:100%">
			<dt>
				<b>
					<xsl:value-of select="if (string(@label)) then @label else 'Title'"/>
				</b>
			</dt>
			<dd>
				<!--Inserts the text of unittitle and any children other that unitdate.-->
				<xsl:apply-templates select="text() |* [not(name() = 'unitdate')]"/>
				<xsl:for-each select="ead:unitdate">
					<xsl:value-of select="."/>
					<xsl:if test="not(position()=last())">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="count(parent::node()/ead:unitdate) &gt; 0">
					<xsl:text>, </xsl:text>
					<xsl:for-each select="parent::node()/ead:unitdate">
						<xsl:value-of select="."/>
						<xsl:if test="not(position()=last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
			</dd>
		</div>
	</xsl:template>

	<!--This template processes the note element.-->
	<xsl:template match="ead:archdesc/ead:did/ead:note">
		<div style="display:table;width:100%">
			<dt>
				<xsl:choose>
					<xsl:when test="string(normalize-space(@label))">
						<xsl:value-of select="normalize-space(@label)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Note</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</dt>
			<dd>
				<xsl:apply-templates/>
			</dd>
		</div>
	</xsl:template>

	<!--This template formats various head elements and makes them targets for
      links from the Table of Contents.-->
	<xsl:template
		match="ead:archdesc/ead:bioghist | ead:archdesc/ead:scopecontent | ead:archdesc/ead:arrangement | ead:archdesc/ead:phystech | ead:archdesc/ead:odd | ead:archdesc/ead:descgrp[not(@type='admininfo')] | ead:archdesc/ead:bioghist/ead:note | ead:archdesc/ead:scopecontent/ead:note | ead:archdesc/ead:phystech/ead:note | ead:archdesc/ead:controlaccess/ead:note | ead:archdesc/ead:odd/ead:note">
		<div class="{name()}">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template
		match="ead:archdesc/ead:bioghist/ead:head  | ead:archdesc/ead:scopecontent/ead:head | ead:archdesc/ead:arrangement/ead:head | ead:archdesc/ead:phystech/ead:head | ead:archdesc/ead:descgrp/ead:head | ead:archdesc/ead:controlaccess/ead:head | ead:archdesc/ead:odd/ead:head | ead:archdesc/ead:arrangement/ead:head">
		<h2>
			<a name="{generate-id(parent::node())}"/>
			<xsl:apply-templates/>
		</h2>
	</xsl:template>

	<xsl:template match="ead:p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="ead:archdesc/ead:bioghist/ead:bioghist/ead:head | ead:archdesc/ead:scopecontent/ead:scopecontent/ead:head">
		<h2>
			<a name="{generate-id(parent::node())}"/>
			<xsl:apply-templates/>
		</h2>
	</xsl:template>


	<!--This template rule formats the top-level related material
      elements by combining any related or separated materials
      elements. It begins by testing to see if there related or separated
      materials elements with content.-->
	<xsl:template name="archdesc-relatedmaterial">

		<xsl:if
			test="string(ead:archdesc/ead:relatedmaterial) or string(ead:archdesc/*/ead:relatedmaterial) or string(ead:archdesc/ead:separatedmaterial) or string(ead:archdesc/*/ead:separatedmaterial)">
			<div id="relatedmaterial">
				<a name="relatedmaterial"/>
				<h2>
					<xsl:text>Related Material</xsl:text>
				</h2>

				<xsl:apply-templates select="ead:archdesc/ead:relatedmaterial | ead:archdesc/ead:descgrp/ead:relatedmaterial"/>
				<xsl:apply-templates select="ead:archdesc/ead:separatedmaterial | ead:archdesc/ead:descgrp/ead:separatedmaterial"/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="archdesc-admininfo">
		<xsl:if test="ead:archdesc/ead:descgrp[@type='admininfo']">
			<div class="dd">
				<xsl:apply-templates select="ead:archdesc/ead:descgrp[@type='admininfo']"/>
			</div>
		</xsl:if>
		<xsl:if
			test="ead:archdesc/ead:accessrestrict | ead:archdesc/ead:userestrict | ead:archdesc/ead:prefercite | ead:archdesc/ead:altformavail | ead:archdesc/ead:accruals | ead:archdesc/ead:acqinfo | ead:archdesc/ead:appraisal | ead:archdesc/ead:custodhist | ead:archdesc/ead:processinfo">
			<xsl:if test="not(ead:archdesc/ead:descgrp[@type='admininfo'])">
				<h2>
					<a name="admininfo"/>
					<xsl:choose>
						<xsl:when test="ead:head">
							<xsl:value-of select="ead:head"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>Administrative Information</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</h2>
			</xsl:if>
			<div class="dd">
				<xsl:apply-templates
					select="ead:archdesc/ead:accessrestrict | ead:archdesc/ead:userestrict | ead:archdesc/ead:prefercite | ead:archdesc/ead:altformavail | ead:archdesc/ead:accruals | ead:archdesc/ead:acqinfo | ead:archdesc/ead:appraisal | ead:archdesc/ead:custodhist | ead:archdesc/ead:processinfo"
				/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="descgrp[@type='admininfo']">
		<h2>
			<a name="admininfo"/>
			<xsl:choose>
				<xsl:when test="ead:head">
					<xsl:value-of select="ead:head"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Administrative Information</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</h2>
		<xsl:apply-templates select="ead:accessrestrict | ead:userestrict | ead:prefercite | ead:altformavail | ead:accruals | ead:acqinfo | ead:appraisal | ead:custodhist | ead:processinfo"/>
	</xsl:template>

	<xsl:template match="ead:accessrestrict | ead:userestrict | ead:prefercite | ead:altformavail | ead:accruals | ead:acqinfo | ead:appraisal | ead:custodhist | ead:processinfo">
		<xsl:apply-templates select="ead:head | ead:p" mode="admininfo"/>
	</xsl:template>

	<xsl:template match="ead:head" mode="admininfo">
		<h3>
			<xsl:apply-templates/>
		</h3>
	</xsl:template>

	<xsl:template match="ead:p" mode="admininfo">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template
		match="ead:archdesc/ead:otherfindaid | ead:archdesc/*/ead:otherfindaid | ead:archdesc/ead:bibliography | ead:archdesc/*/ead:bibliography | ead:archdesc/ead:phystech | ead:archdesc/ead:originalsloc">
		<xsl:apply-templates/>
	</xsl:template>

	<!--This template rule tests for and formats the top-level index element. It begins
      by testing to see if there is an index element with content.-->
	<xsl:template match="ead:index">
		<div class="dd">
			<xsl:choose>
				<xsl:when test="@head">
					<xsl:choose>
						<xsl:when test="parent::ead:archdesc">
							<h2>
								<xsl:apply-templates select="ead:head"/>
							</h2>
						</xsl:when>
						<xsl:otherwise>
							<li>
								<b>
									<xsl:apply-templates select="ead:head"/>
								</b>
							</li>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="parent::ead:archdesc">
							<h2>Index</h2>
						</xsl:when>
						<xsl:otherwise>
							<li>
								<b>Index</b>
							</li>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="ead:address | ead:blockquote | ead:chronlist | ead:index | ead:list | ead:listhead | ead:note | ead:p | ead:table"/>

			<xsl:if test="ead:indexentry">
				<ul>
					<xsl:for-each select="ead:indexentry">
						<xsl:apply-templates/>
					</xsl:for-each>
				</ul>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="ead:controlaccess">
		<xsl:variable name="class">
			<xsl:if test="ancestor::ead:c">
				<xsl:text>clevel</xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="controlaccess" as="node()*">
			<controlaccess xmlns="urn:isbn:1-931666-22-9">
				<xsl:copy-of select="*"/>
			</controlaccess>
		</xsl:variable>

		<div>
			<!-- add class for component level controlaccess only, not within archdesc -->
			<xsl:if test="string($class)">
				<xsl:attribute name="class" select="$class"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@head">
					<xsl:choose>
						<xsl:when test="parent::ead:archdesc">
							<h2>
								<xsl:apply-templates select="ead:head"/>
							</h2>
						</xsl:when>
						<xsl:otherwise>
							<b>
								<xsl:apply-templates select="ead:head"/>
							</b>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="parent::ead:archdesc">
							<h2>
								<xsl:value-of select="eaditor:normalize_fields('controlaccess', $lang)"/>
							</h2>
						</xsl:when>
						<xsl:otherwise>
							<b>
								<xsl:value-of select="eaditor:normalize_fields('controlaccess', $lang)"/>
							</b>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="ead:address | ead:blockquote | ead:chronlist | ead:controlaccess | ead:list | ead:listhead | ead:note | ead:p | ead:table"/>

			<!-- created unnumbered list for the access terms: this XSLT is simplified from earlier versions -->
			<xsl:variable name="accessTerms">corpname,famname,function,genreform,geogname,name,occupation,persname,subject,title</xsl:variable>

			<xsl:for-each select="tokenize($accessTerms, ',')">
				<xsl:variable name="element" select="."/>
				<xsl:if test="count($controlaccess//*[local-name()=$element]) &gt; 0">
					<ul>
						<li>
							<xsl:choose>
								<xsl:when test="$class='clevel'">
									<b>
										<xsl:value-of select="eaditor:normalize_fields($element, $lang)"/>
									</b>
								</xsl:when>
								<xsl:otherwise>
									<h3>
										<xsl:value-of select="eaditor:normalize_fields($element, $lang)"/>
									</h3>
								</xsl:otherwise>
							</xsl:choose>
							<ul>
								<xsl:apply-templates select="$controlaccess//*[local-name()=$element]"/>
							</ul>
						</li>
					</ul>
				</xsl:if>
			</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template match="ead:title" mode="controlaccess">
		<li>
			<xsl:value-of select="normalize-space(.)"/>
			<xsl:if test="string(normalize-space(@role))">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="@role"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
		</li>
	</xsl:template>

	<xsl:template match="ead:corpname | ead:famname | ead:function | ead:genreform | ead:geogname | ead:name | ead:occupation | ead:persname | ead:subject">
		<xsl:choose>
			<xsl:when test="ancestor::ead:controlaccess or ancestor::ead:index">
				<xsl:choose>
					<!-- solr facets, create link to search results -->
					<xsl:when test="name()='corpname' or name()='famname' or name()='genreform' or name()='geogname' or name()='persname' or name()='subject'">
						<li>
							<a
								href="{$display_path}results/?q={name()}_facet:&#x022;{if (contains(normalize-space(.), '&amp;')) then encode-for-uri(normalize-space(.)) else normalize-space(.)}&#x022;">
								<xsl:value-of select="normalize-space(.)"/>
							</a>
							<xsl:if test="@source">
								<xsl:choose>
									<xsl:when test="@source='aat'">
										<a href="http://vocab.getty.edu/aat/{@authfilenumber}" target="_blank" title="Getty AAT" rel="dcterms:format">
											<img src="{$include_path}ui/images/external.png" alt="external link" class="external_link"/>
										</a>
									</xsl:when>
									<xsl:when test="@source='geonames'">
										<a href="http://www.geonames.org/{@authfilenumber}" target="_blank" title="Geonames" rel="dcterms:coverage">
											<img src="{$include_path}ui/images/external.png" alt="external link" class="external_link"/>
										</a>
									</xsl:when>
									<xsl:when test="@source='pleiades'">
										<a href="http://pleiades.stoa.org/places/{@authfilenumber}" target="_blank" title="Pleiades" rel="dcterms:coverage">
											<img src="{$include_path}ui/images/external.png" alt="external link" class="external_link"/>
										</a>
									</xsl:when>
									<xsl:when test="@source='lcsh'">
										<a href="http://id.loc.gov/authorities/{@authfilenumber}" target="_blank" title="LCSH" rel="dcterms:subject">
											<img src="{$include_path}ui/images/external.png" alt="external link" class="external_link"/>
										</a>
									</xsl:when>
									<xsl:when test="@source='lcgft'">
										<a href="http://id.loc.gov/authorities/{@authfilenumber}" target="_blank" title="LCGFT" rel="dcterms:format">
											<img src="{$include_path}ui/images/external.png" alt="external link" class="external_link"/>
										</a>
									</xsl:when>
									<xsl:when test="@source='viaf'">
										<a href="http://viaf.org/viaf/{@authfilenumber}" target="_blank" title="VIAF" rel="arch:correspondedWith">
											<img src="{$include_path}ui/images/external.png" alt="external link" class="external_link"/>
										</a>
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="string(normalize-space(@role))">
								<xsl:text> (</xsl:text>
								<xsl:value-of select="@role"/>
								<xsl:text>)</xsl:text>
							</xsl:if>
						</li>
					</xsl:when>
					<xsl:otherwise>
						<li>
							<xsl:value-of select="normalize-space(.)"/>
							<xsl:if test="string(normalize-space(@role))">
								<xsl:text> (</xsl:text>
								<xsl:value-of select="@role"/>
								<xsl:text>)</xsl:text>
							</xsl:if>
						</li>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	<xsl:template match="ead:title">
		<xsl:choose>
			<xsl:when test="@render = 'italic'">
				<i>
					<xsl:apply-templates/>
				</i>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="ead:dao | ead:daoloc">
		<xsl:if test="@xlink:href">
			<xsl:variable name="title" select="normalize-space(@title)"/>
			<img src="{@xlink:href}" title="{$title}"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ead:daoloc" mode="flickr-image">
		<xsl:variable name="photo_id" select="substring-before(tokenize(@xlink:href, '/')[last()], '_')"/>
		<xsl:variable name="flickr_uri" select="eaditor:get_flickr_uri($photo_id)"/>

		<a href="{$flickr_uri}" target="_blank" class="flickrthumb">
			<img class="gi" src="{@xlink:href}"/>
		</a>
		<h3>
			<xsl:value-of select="parent::node()/ead:daodesc/ead:head"/>
		</h3>
		<p>
			<xsl:value-of select="parent::node()/ead:daodesc/ead:p"/>
		</p>
	</xsl:template>

	<xsl:template match="ead:lb">
		<br/>
	</xsl:template>


	<xsl:template match="extref[@xlink:href]">
		<xsl:element name="a">
			<xsl:attribute name="href">
				<xsl:value-of select="@xlink:href"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="ead:subtitle/num">
		<br/>
		<xsl:value-of select="@type"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates/>
		<br/>
	</xsl:template>

	<!-- The following general templates format the display of various RENDER
		attributes.-->
	<xsl:template match="emph[@render='bold']">
		<b>
			<xsl:apply-templates/>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='italic']">
		<i>
			<xsl:apply-templates/>
		</i>
	</xsl:template>
	<xsl:template match="emph[@render='underline']">
		<u>
			<xsl:apply-templates/>
		</u>
	</xsl:template>
	<xsl:template match="emph[@render='sub']">
		<sub>
			<xsl:apply-templates/>
		</sub>
	</xsl:template>
	<xsl:template match="emph[@render='super']">
		<super>
			<xsl:apply-templates/>
		</super>
	</xsl:template>

	<xsl:template match="emph[@render='quoted']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="emph[@render='doublequote']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>
	<xsl:template match="emph[@render='singlequote']">
		<xsl:text>'</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>'</xsl:text>
	</xsl:template>
	<xsl:template match="emph[@render='bolddoublequote']">
		<b>
			<xsl:text>"</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>"</xsl:text>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='boldsinglequote']">
		<b>
			<xsl:text>'</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>'</xsl:text>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='boldunderline']">
		<b>
			<u>
				<xsl:apply-templates/>
			</u>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='bolditalic']">
		<b>
			<i>
				<xsl:apply-templates/>
			</i>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='boldsmcaps']">
		<font style="font-variant: small-caps">
			<b>
				<xsl:apply-templates/>
			</b>
		</font>
	</xsl:template>
	<xsl:template match="emph[@render='smcaps']">
		<font style="font-variant: small-caps">
			<xsl:apply-templates/>
		</font>
	</xsl:template>
	<xsl:template match="title[@render='bold']">
		<b>
			<xsl:apply-templates/>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='italic']">
		<i>
			<xsl:apply-templates/>
		</i>
	</xsl:template>
	<xsl:template match="title[@render='underline']">
		<u>
			<xsl:apply-templates/>
		</u>
	</xsl:template>
	<xsl:template match="title[@render='sub']">
		<sub>
			<xsl:apply-templates/>
		</sub>
	</xsl:template>
	<xsl:template match="title[@render='super']">
		<super>
			<xsl:apply-templates/>
		</super>
	</xsl:template>

	<xsl:template match="title[@render='quoted']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="title[@render='doublequote']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="title[@render='singlequote']">
		<xsl:text>'</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>'</xsl:text>
	</xsl:template>
	<xsl:template match="title[@render='bolddoublequote']">
		<b>
			<xsl:text>"</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>"</xsl:text>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='boldsinglequote']">
		<b>
			<xsl:text>'</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>'</xsl:text>
		</b>
	</xsl:template>

	<xsl:template match="title[@render='boldunderline']">
		<b>
			<u>
				<xsl:apply-templates/>
			</u>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='bolditalic']">
		<b>
			<i>
				<xsl:apply-templates/>
			</i>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='boldsmcaps']">
		<font style="font-variant: small-caps">
			<b>
				<xsl:apply-templates/>
			</b>
		</font>
	</xsl:template>
	<xsl:template match="title[@render='smcaps']">
		<font style="font-variant: small-caps">
			<xsl:apply-templates/>
		</font>
	</xsl:template>
	<!-- This template converts a Ref element into an HTML anchor.-->
	<xsl:template match="ref">
		<a href="#{@target}">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="ead:list">
		<ul>
			<xsl:if test="ead:head">
				<li>
					<b>
						<xsl:apply-templates select="ead:head"/>
					</b>
				</li>
			</xsl:if>
			<xsl:apply-templates select="ead:item"/>
		</ul>
	</xsl:template>

	<xsl:template match="ead:item">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<!--Formats a simple table. The width of each column is defined by the colwidth attribute in a colspec element.-->
	<xsl:template match="ead:table">
		<table width="75%" style="margin-left: 25pt">
			<tr>
				<td colspan="3">
					<h3>
						<xsl:apply-templates select="ead:head"/>
					</h3>
				</td>
			</tr>
			<xsl:for-each select="ead:tgroup">
				<tr>
					<xsl:for-each select="ead:colspec">
						<td width="{@colwidth}"/>
					</xsl:for-each>
				</tr>
				<xsl:for-each select="ead:thead">
					<xsl:for-each select="ead:row">
						<tr>
							<xsl:for-each select="ead:entry">
								<td valign="top">
									<b>
										<xsl:apply-templates/>
									</b>
								</td>
							</xsl:for-each>
						</tr>
					</xsl:for-each>
				</xsl:for-each>

				<xsl:for-each select="ead:tbody">
					<xsl:for-each select="ead:row">
						<tr>
							<xsl:for-each select="ead:entry">
								<td valign="top">
									<xsl:apply-templates/>
								</td>
							</xsl:for-each>
						</tr>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</table>
	</xsl:template>
	<!--This template rule formats a chronlist element.-->
	<xsl:template match="ead:chronlist">
		<table width="100%" style="margin-left:25pt">
			<tr>
				<td width="5%"> </td>
				<td width="15%"> </td>
				<td width="80%"> </td>
			</tr>
			<xsl:apply-templates/>
		</table>
	</xsl:template>

	<xsl:template match="ead:chronlist/head">
		<tr>
			<td colspan="3">
				<h3>
					<xsl:apply-templates/>
				</h3>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="ead:chronlist/listhead">
		<tr>
			<td> </td>
			<td>
				<b>
					<xsl:apply-templates select="head01"/>
				</b>
			</td>
			<td>
				<b>
					<xsl:apply-templates select="head02"/>
				</b>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="ead:chronitem">
		<!--Determine if there are event groups.-->
		<xsl:choose>
			<xsl:when test="ead:eventgrp">
				<!--Put the date and first event on the first line.-->
				<tr>
					<td> </td>
					<td valign="top">
						<xsl:apply-templates select="date"/>
					</td>
					<td valign="top">
						<xsl:apply-templates select="ead:eventgrp/ead:event[position()=1]"/>
					</td>
				</tr>
				<!--Put each successive event on another line.-->
				<xsl:for-each select="ead:eventgrp/ead:event[not(position()=1)]">
					<tr>
						<td> </td>
						<td> </td>
						<td valign="top">
							<xsl:apply-templates select="."/>
						</td>
					</tr>
				</xsl:for-each>
			</xsl:when>
			<!--Put the date and event on a single line.-->
			<xsl:otherwise>
				<tr>
					<td> </td>
					<td valign="top">
						<xsl:apply-templates select="ead:date"/>
					</td>
					<td valign="top">
						<xsl:apply-templates select="ead:event"/>
					</td>
				</tr>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ead:address">
		<div>
			<xsl:for-each select="ead:addressline">
				<xsl:value-of select="."/>
				<xsl:if test="not(position() = last())">
					<br/>
				</xsl:if>
			</xsl:for-each>
		</div>
	</xsl:template>

</xsl:stylesheet>
