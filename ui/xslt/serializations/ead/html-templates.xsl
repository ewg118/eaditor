<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:eaditor="https://github.com/ewg118/eaditor">

	<xsl:template match="ead:dsc">
		<a name="{generate-id(.)}"/>
		<h1>
			<xsl:choose>
				<xsl:when test="ead:head">
					<xsl:value-of select="ead:head"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
				</xsl:otherwise>
			</xsl:choose>
		</h1>

		<xsl:apply-templates select="ead:p | ead:note"/>

		<xsl:choose>
			<!-- render a list of items as a table when there are only items -->
			<xsl:when test="count(ead:c[@level = 'item']) = count(ead:c)">
				<table class="table table-striped">
					<tbody>
						<xsl:apply-templates select="ead:c" mode="table"/>
					</tbody>
				</table>
			</xsl:when>
			<xsl:otherwise>
				<ul id="dsc-list">
					<xsl:apply-templates select="ead:c" mode="list"/>
				</ul>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ead:c" mode="table">
		<tr id="{@id}">
			<td>
				<xsl:call-template name="component-template"/>
			</td>
			<xsl:if test="count(ead:dao | ead:daogrp) = 1">
				<td>
					<xsl:apply-templates select="ead:dao | ead:daogrp"/>
				</td>
			</xsl:if>
		</tr>
	</xsl:template>

	<xsl:template match="ead:c" mode="list">
		<li id="{@id}">
			<xsl:call-template name="component-template"/>
		</li>
	</xsl:template>

	<xsl:template name="component-template">

		<xsl:apply-templates select="ead:did"/>

		<xsl:apply-templates
			select="ead:bioghist | ead:scopecontent | ead:arrangement | ead:accessrestrict | ead:userestrict | ead:prefercite | ead:acqinfo | ead:altformavail | ead:accruals | ead:appraisal | ead:custodhist | ead:processinfo | ead:originalsloc | ead:phystech | ead:odd | ead:note | ead:bibliography | ead:otherfindaid | ead:relatedmaterial | ead:separatedmaterial | ead:fileplan"
			mode="did_level"/>

		<xsl:apply-templates select="ead:index | ead:controlaccess"/>

		<xsl:if test="count(ead:dao | ead:daogrp) &gt; 1">
			<div class="row">
				<div class="col-md-12">
					<h4>Images</h4>
					<xsl:apply-templates select="ead:dao | ead:daogrp"/>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="count(ead:c) &gt; 0">
			<xsl:choose>
				<!-- render a list of items as a table when there are only items -->
				<xsl:when test="count(ead:c[@level = 'item']) = count(ead:c)">
					<table class="table table-striped">
						<tbody>
							<xsl:apply-templates select="ead:c" mode="table"/>
						</tbody>
					</table>
				</xsl:when>
				<xsl:otherwise>
					<ul>
						<xsl:apply-templates select="ead:c" mode="list"/>
					</ul>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<xsl:if test="@level = 'series'">
			<div class="backtotop">
				<a href="#top" target="_self">Back to Top</a>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ead:did">
		<xsl:apply-templates select="ead:unittitle" mode="content"/>

		<xsl:if
			test="ead:unitid or ead:repository or ead:physdesc or ead:origination or ead:physloc or ead:langmaterial or ead:materialspec or ead:abstract or ead:note or ead:container">
			<dl class="dl-horizontal">
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
		</xsl:if>
	</xsl:template>

	<xsl:template
		match="ead:bioghist | ead:scopecontent | ead:arrangement | ead:accessrestrict | ead:userestrict | ead:prefercite | ead:acqinfo | ead:altformavail | ead:accruals | ead:appraisal | ead:custodhist | ead:processinfo | ead:originalsloc | ead:phystech | ead:odd | ead:note | ead:bibliography | ead:otherfindaid | ead:relatedmaterial | ead:separatedmaterial | ead:fileplan"
		mode="did_level">
		<xsl:variable name="default_label">
			<xsl:choose>
				<xsl:when test="ead:head">
					<xsl:value-of select="ead:head"/>
				</xsl:when>
				<xsl:when test="@label">
					<xsl:value-of select="@label"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
					<xsl:text>: </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="clevel">
			<i>
				<xsl:value-of select="$default_label"/>
			</i>
			<xsl:apply-templates select="*[not(local-name() = 'head')]"/>
		</div>
	</xsl:template>

	<xsl:template match="ead:unittitle" mode="content">
		<xsl:choose>
			<xsl:when test="parent::node()/parent::node()/@level = 'subseries'">
				<h3 property="dcterms:title">
					<xsl:if test="@label">
						<xsl:value-of select="@label"/>
						<xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:apply-templates/>
					<xsl:if test="parent::node()/ead:unitdate">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="parent::node()/ead:unitdate"/>
					</xsl:if>
				</h3>
			</xsl:when>
			<xsl:when test="parent::ead:did/parent::node()/@level = 'series' or parent::ead:did/parent::ead:c[parent::ead:dsc]">
				<h2 property="dcterms:title">
					<xsl:if test="@label">
						<xsl:value-of select="@label"/>
						<xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:apply-templates/>
					<xsl:if test="parent::node()/ead:unitdate">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="parent::node()/ead:unitdate"/>
					</xsl:if>
				</h2>
			</xsl:when>
			<xsl:otherwise>
				<h4 property="dcterms:title">
					<xsl:if test="@label">
						<xsl:value-of select="@label"/>
						<xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:apply-templates/>
					<xsl:if test="parent::node()/ead:unitdate">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="parent::node()/ead:unitdate"/>
					</xsl:if>
				</h4>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- hide head for now, only use unittitle -->
	<xsl:template match="ead:head" mode="content"/>

	<xsl:template match="ead:container">
		<xsl:param name="count"/>
		<xsl:variable name="width">
			<xsl:value-of select="floor(100 div number($count))"/>
		</xsl:variable>
		<div style="float:left;width:{$width}%">
			<xsl:choose>
				<xsl:when test="@label"><xsl:value-of select="@label"/>: </xsl:when>
				<xsl:when test="@type"><xsl:value-of select="@type"/>: </xsl:when>
			</xsl:choose>
			<xsl:value-of select="."/>
		</div>
	</xsl:template>


	<!-- images -->
	<xsl:template match="ead:daoloc" mode="collection-image">
		<xsl:variable name="photo_id" select="substring-before(tokenize(@xlink:href, '/')[last()], '_')"/>
		<xsl:variable name="flickr_uri" select="eaditor:get_flickr_uri($photo_id)"/>
		<a href="{$flickr_uri}" target="_blank">
			<img class="ci" src="{@xlink:href}"/>
		</a>
		<xsl:if test="string(parent::node()/ead:daodesc/ead:head)">
			<h3>
				<xsl:value-of select="parent::node()/ead:daodesc/ead:head"/>
			</h3>
		</xsl:if>
		<xsl:if test="string(parent::node()/ead:daodesc/ead:p[1])">
			<xsl:apply-templates select="parent::node()/ead:daodesc/ead:p"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ead:daogrp">
		<xsl:apply-templates select="ead:daoloc[@xlink:label = 'Small']"/>
	</xsl:template>

	<xsl:template match="ead:dao | ead:daoloc">
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="child::ead:daodesc">
					<xsl:choose>
						<xsl:when test="ead:daodesc/ead:head">
							<xsl:value-of select="ead:daodesc/ead:head"/>
						</xsl:when>
						<xsl:when test="ead:daodesc/ead:p[1]">
							<xsl:value-of select="ead:daodesc/ead:p[1]"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="parent::ead:daogrp/ead:daodesc/ead:head">
							<xsl:value-of select="parent::ead:daogrp/ead:daodesc/ead:head"/>
						</xsl:when>
						<xsl:when test="parent::ead:daogrp/ead:daodesc/ead:p[1]">
							<xsl:value-of select="parent::ead:daogrp/ead:daodesc/ead:p[1]"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="contains(@xlink:href, 'flickr.com')">
				<a
					href="{if (parent::node()/ead:daoloc[@xlink:label = 'Original']) then parent::node()/ead:daoloc[@xlink:label = 'Original']/@xlink:href else parent::node()/ead:daoloc[@xlink:label = 'Medium']/@xlink:href}"
					class="thumbImage" rel="gallery">
					<xsl:if test="string($title)">
						<xsl:attribute name="title" select="$title"/>
					</xsl:if>
					<img class="ci" src="{@xlink:href}"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="href">
					<xsl:choose>
						<xsl:when test="matches(@xlink:href, 'https?://')">
							<xsl:value-of select="@xlink:href"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($display_path, @xlink:href)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="medium-href">
					<xsl:choose>
						<xsl:when test="contains(parent::node()/ead:daoloc[@xlink:label = 'Medium']/@xlink:href, 'http://')">
							<xsl:value-of select="parent::node()/ead:daoloc[@xlink:label = 'Medium']/@xlink:href"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($display_path, parent::node()/ead:daoloc[@xlink:label = 'Medium']/@xlink:href)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="string($medium-href)">
						<a href="{$medium-href}" class="thumbImage" rel="gallery">
							<xsl:if test="string($title)">
								<xsl:attribute name="title" select="$title"/>
							</xsl:if>
							<img src="{$href}"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<img src="{$href}">
							<xsl:if test="string($title)">
								<xsl:attribute name="title" select="$title"/>
							</xsl:if>
						</img>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
