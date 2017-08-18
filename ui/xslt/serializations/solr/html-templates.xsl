<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eaditor="https://github.com/ewg118/eaditor" version="2.0">

	<xsl:template match="arr[@name='collection_thumb']/str">
		<xsl:variable name="title" select="ancestor::doc/str[@name='unittitle_display']"/>
		<div class="thumbImage">
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
			<!--<xsl:choose>
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
			</xsl:choose>-->
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
	
	<xsl:template match="doc">
		<xsl:variable name="sort_category" select="substring-before($sort, ' ')"/>
		<xsl:variable name="regularized_sort">
			<xsl:value-of select="eaditor:normalize_fields($sort_category, $lang)"/>
		</xsl:variable>
		
		<tr>
			<td>
				<dl class="dl-horizontal">
					<dt>
						<xsl:value-of select="eaditor:normalize_fields('title', $lang)"/>
					</dt>
					<dd>
						<xsl:variable name="objectUri">
							<xsl:choose>
								<xsl:when test="//config/aggregator='true'">
									<xsl:choose>
										<xsl:when test="//config/ark[@enabled='true']">
											<xsl:choose>
												<xsl:when test="string(str[@name='cid'])">
													<xsl:value-of select="concat($display_path, str[@name='collection-name'], '/ark:/', //config/ark/naan, '/', str[@name='recordId'], '/', str[@name='cid'])"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat($display_path, str[@name='collection-name'], '/ark:/', //config/ark/naan, '/', str[@name='recordId'])"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="string(str[@name='cid'])">
													<xsl:value-of select="concat($display_path, str[@name='collection-name'], '/id/', str[@name='recordId'], '/', str[@name='cid'])"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat($display_path, str[@name='collection-name'], '/id/', str[@name='recordId'])"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="//config/ark[@enabled='true']">
											<xsl:choose>
												<xsl:when test="string(str[@name='cid'])">
													<xsl:value-of select="concat($display_path, 'ark:/', //config/ark/naan, '/', str[@name='recordId'], '/', str[@name='cid'])"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat($display_path, 'ark:/', //config/ark/naan, '/', str[@name='recordId'])"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="string(str[@name='cid'])">
													<xsl:value-of select="concat($display_path, 'id/', str[@name='recordId'], '/', str[@name='cid'])"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat($display_path, 'id/', str[@name='recordId'])"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
							
						</xsl:variable>
						<a href="{$objectUri}">
							<xsl:value-of select="str[@name='unittitle_display']"/>
						</a>
					</dd>
					<xsl:if test="string(str[@name='unitdate_display'])">
						<dt>
							<xsl:value-of select="eaditor:normalize_fields('date', $lang)"/>
						</dt>
						<dd>
							<xsl:value-of select="str[@name='unitdate_display']"/>
						</dd>
					</xsl:if>
					<xsl:if test="string(str[@name='publisher_display'])">
						<dt>
							<xsl:value-of select="eaditor:normalize_fields('publisher', $lang)"/>
						</dt>
						<dd>
							<xsl:value-of select="str[@name='publisher_display']"/>
							<xsl:if test="str[@name='agencycode_facet']">
								<xsl:value-of select="concat(' (', str[@name='agencycode_facet'], ')')"/>
							</xsl:if>
						</dd>
					</xsl:if>
					<xsl:if test="string(str[@name='physdesc_display'])">
						<dt>
							<xsl:value-of select="eaditor:normalize_fields('physdesc', $lang)"/>
						</dt>
						<dd>
							<xsl:value-of select="str[@name='physdesc_display']"/>
						</dd>
					</xsl:if>
					<xsl:if test="string(arr[@name='level_facet']/str[1])">
						<dt>
							<xsl:value-of select="eaditor:normalize_fields('level_facet', $lang)"/>
						</dt>
						<dd>
							<xsl:value-of select="arr[@name='level_facet']/str[1]"/>
						</dd>
					</xsl:if>
					<!-- hierarchy -->
					<xsl:if test="count(arr[@name='dsc_hier']/str) &gt; 0">
						<xsl:variable name="ark" select="//config/ark/@enabled" as="xs:boolean"/>
						<xsl:variable name="naan" select="normalize-space(//config/ark/naan)"/>
						<dt>Organization</dt>
						<dd>
							<xsl:for-each select="arr[@name='dsc_hier']/str">
								<xsl:variable name="pieces" select="tokenize(., '\|')"/>
								<xsl:choose>
									<xsl:when test="$ark = true()">
										<a href="{$display_path}ark:/{$naan}/{$pieces[2]}">
											<xsl:value-of select="$pieces[3]"/>
											<xsl:text>: </xsl:text>
											<xsl:value-of select="$pieces[4]"/>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<a href="{$display_path}id/{$pieces[2]}">
											<xsl:value-of select="$pieces[3]"/>
											<xsl:text>: </xsl:text>
											<xsl:value-of select="$pieces[4]"/>
										</a>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="not(position()=last())">
									<xsl:text> | </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</dd>
					</xsl:if>
				</dl>
			</td>
			<td class="col-md-4 text-right">
				<xsl:choose>
					<xsl:when test="count(arr[@name='collection_thumb']/str) &gt; 0">
						<xsl:apply-templates select="arr[@name='collection_thumb']/str"/>
					</xsl:when>
					<xsl:when test="string(//config/results_default_image)">
						<xsl:choose>
							<xsl:when test="matches(//config/results_default_image, 'https?://')">
								<img src="{//config/results_default_image}" alt="thumbnail" title="thumbnail"/>
							</xsl:when>
							<xsl:otherwise>
								<img src="{concat($include_path, 'ui/images/', //config/results_default_image)}" alt="thumbnail" title="thumbnail"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>

</xsl:stylesheet>
