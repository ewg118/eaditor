<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:eaditor="https://github.com/ewg118/eaditor" exclude-result-prefixes="#all" version="2.0">

	<xsl:template name="tei-content">
		<xsl:choose>
			<xsl:when test="string($id)">
				<div class="row">
					<div class="col-md-12">
						<h1>
							<xsl:value-of
								select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
						</h1>
						<h2>
							<xsl:value-of
								select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/>
						</h2>
						<xsl:apply-templates/>
					</div>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div class="row">
					<div class="col-md-12">
						<h1>
							<xsl:value-of
								select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
						</h1>
						<h2>
							<xsl:value-of
								select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/>
						</h2>
					</div>
				</div>
				<div class="row">
					<div class="col-md-4">
						<xsl:apply-templates select="tei:teiHeader/tei:fileDesc"/>
					</div>
					<div class="col-md-8">
						<xsl:call-template name="facsimiles"/>
					</div>
				</div>
				<xsl:if test="tei:text">
					<div class="row">
						<div class="col-md-12">
							<xsl:apply-templates select="tei:text"/>
						</div>
					</div>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:fileDesc">
		<xsl:apply-templates select="tei:publicationStmt"/>
		<xsl:apply-templates select="tei:notesStmt/tei:note[@type='abstract']"/>
	</xsl:template>

	<xsl:template name="facsimiles">
		<div>
			<xsl:call-template name="page-navigation"/>
			<div>
				<div id="annot"/>
			</div>
			<table id="slider">
				<tr>
					<td id="left-scroll">
						<span class="glyphicon glyphicon-arrow-left"/>
					</td>
					<td>
						<div id="slider-thumbs">
							<xsl:apply-templates select="tei:facsimile" mode="slider"/>
						</div>
					</td>
					<td id="right-scroll">
						<span class="glyphicon glyphicon-arrow-right"/>
					</td>
				</tr>

			</table>

			<!-- controls -->
			<div style="display:none">
				<span id="image-path">
					<xsl:value-of
						select="concat($include_path, 'ui/media/archive/', tei:facsimile[1]/tei:graphic/@url, '.jpg')"
					/>
				</span>
				<span id="image-id">
					<xsl:value-of select="tei:facsimile[1]/@xml:id"/>
				</span>
				<span id="display_path">
					<xsl:value-of select="$display_path"/>
				</span>
				<span id="doc">
					<xsl:value-of select="$doc"/>
				</span>
				<span id="first-page">
					<xsl:value-of select="tei:facsimile[1]/@xml:id"/>
				</span>
				<span id="last-page">
					<xsl:value-of select="tei:facsimile[last()]/@xml:id"/>
				</span>
				<span id="image-container"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="tei:facsimile" mode="slider">
		<a href="{$include_path}ui/media/archive/{tei:graphic/@url}.jpg" title="{tei:graphic/@n}"
			class="page-image" id="{@xml:id}">
			<img src="{$include_path}ui/media/thumbnail/{tei:graphic/@url}.jpg"
				alt="{tei:graphic/@n}">
				<xsl:if test="position()=1">
					<xsl:attribute name="class">selected</xsl:attribute>
				</xsl:if>
			</img>
		</a>
	</xsl:template>

	<xsl:template name="page-navigation">
		<div class="highlight">
			<a href="#" id="prev-page" class="disabled"><span class="glyphicon glyphicon-arrow-left"
				/>Previous</a>
			<span id="goto-container">
				<xsl:text>Go to page: </xsl:text>
				<select id="goto-page" class="form-control">
					<xsl:for-each select="tei:facsimile">
						<option value="{@xml:id}">
							<xsl:choose>
								<xsl:when test="tei:graphic/@n">
									<xsl:value-of select="tei:graphic/@n"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="tei:graphic/@url"/>
								</xsl:otherwise>
							</xsl:choose>
						</option>
					</xsl:for-each>
				</select>
			</span>
			<a href="#" id="next-page">Next<span class="glyphicon glyphicon-arrow-right"/></a>
		</div>
	</xsl:template>

	<!-- ******************** TEI TEMPLATES *********************** -->
	<xsl:template match="tei:publicationStmt">
		<div>
			<h3>Publication Statement</h3>
			<dl class="dl-horizontal">
				<xsl:if test="tei:publisher">
					<dt>Publisher</dt>
					<dd>
						<xsl:value-of select="tei:publisher"/>
					</dd>
				</xsl:if>
				<xsl:if test="tei:pubPlace">
					<dt>Publication Place</dt>
					<dd>
						<xsl:value-of select="tei:pubPlace"/>
					</dd>
				</xsl:if>
				<xsl:if test="tei:idno[@type='donum']">
					<dt>Donum</dt>
					<dd>
						<a href="http://numismatics.org/library/{tei:idno[@type='donum']}">
							<xsl:text>http://numismatics.org/library/</xsl:text>
							<xsl:value-of select="tei:idno[@type='donum']"/>
						</a>
					</dd>
				</xsl:if>
			</dl>
		</div>
	</xsl:template>

	<xsl:template match="tei:note[@type='abstract']">
		<div>
			<h3>Abstract</h3>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="tei:p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

</xsl:stylesheet>
