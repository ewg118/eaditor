<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eaditor="https://github.com/ewg118/eaditor" version="2.0">

	<xsl:template match="arr[@name='collection_thumb']/str">
		<xsl:variable name="title" select="ancestor::doc/str[@name='unittitle_display']"/>
		<div class="thumbImage">
			<xsl:choose>
				<xsl:when test="contains(., 'flickr.com')">
					<xsl:variable name="photo_id" select="substring-before(tokenize(., '/')[last()], '_')"/>
					<xsl:variable name="flickr_uri" select="ancestor::doc/arr[@name='flickr_uri']/str[1]"/>

					<a href="#{generate-id()}" title="{$title}">
						<img class="ci" src="{.}"/>
					</a>
					<div style="display:none">
						<div id="{generate-id()}">
							<a target="_blank" href="{$flickr_uri}" class="flickr-link">
								<img src="{ancestor::doc/arr[@name='collection_reference']/str[contains(., $photo_id)]}"/>
							</a>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="position" select="position()"/>
					<xsl:choose>
						<xsl:when test="ancestor::doc/arr[@name='collection_reference']/str[position()=$position]">
							<a href="{ancestor::doc/arr[@name='collection_reference']/str[position()=$position]}" title="{$title}">
								<img src="{.}" alt="thumb"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<img src="{.}" alt="thumb"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template name="paging">
		<xsl:variable name="start_var" as="xs:integer">
			<xsl:choose>
				<xsl:when test="string($start)">
					<xsl:value-of select="$start"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="next">
			<xsl:value-of select="$start_var+$rows"/>
		</xsl:variable>

		<xsl:variable name="previous">
			<xsl:choose>
				<xsl:when test="$start_var &gt;= $rows">
					<xsl:value-of select="$start_var - $rows"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="current" select="$start_var div $rows + 1"/>
		<xsl:variable name="total" select="ceiling($numFound div $rows)"/>

		<div class="paging_div row">
			<div class="col-md-6">
				<xsl:variable name="startRecord" select="$start_var + 1"/>
				<xsl:variable name="endRecord">
					<xsl:choose>
						<xsl:when test="$numFound &gt; ($start_var + $rows)">
							<xsl:value-of select="$start_var + $rows"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$numFound"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<span>
					<b>
						<xsl:value-of select="$startRecord"/>
					</b>
					<xsl:text> to </xsl:text>
					<b>
						<xsl:value-of select="$endRecord"/>
					</b>
					<text> of </text>
					<b>
						<xsl:value-of select="$numFound"/>
					</b>
					<xsl:text> total results.</xsl:text>
				</span>
			</div>

			<!-- paging functionality -->
			<div class="col-md-6 page-nos">
				<div class="btn-toolbar" role="toolbar">
					<div class="btn-group" style="float:right">
						<xsl:choose>
							<xsl:when test="$start_var &gt;= $rows">
								<a class="btn btn-default" title="First" href="{if($pipeline='results') then 'results' else ''}?q={encode-for-uri($q)}{if (string($sort)) then concat('&amp;sort=',
									$sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default" title="Previous" href="{if($pipeline='results') then 'results' else ''}?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then
									concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="First" href="{if($pipeline='results') then 'results' else ''}?q={encode-for-uri($q)}{if (string($sort)) then
									concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default disabled" title="Previous" href="{if($pipeline='results') then 'results' else ''}?q={encode-for-uri($q)}&amp;start={$previous}{if
									(string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
						<!-- current page -->
						<button type="button" class="btn btn-default disabled">
							<b>
								<xsl:value-of select="$current"/>
							</b>
						</button>
						<!-- next page -->
						<xsl:choose>
							<xsl:when test="$numFound - $start_var &gt; $rows">
								<a class="btn btn-default" title="Next" href="{if($pipeline='results') then 'results' else ''}?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then
									concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default" href="{if($pipeline='results') then 'results' else ''}?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then
									concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="Next" href="{if($pipeline='results') then 'results' else ''}?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then
									concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default disabled" href="{if($pipeline='results') then 'results' else ''}?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if
									(string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
