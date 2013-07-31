<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

	<xsl:template name="header">
		<div id="hd">
			<div id="banner">
				<xsl:if test="string($config/config/banner_text)">
					<div class="banner_text">
						<xsl:value-of select="$config/config/banner_text"/>
					</div>
				</xsl:if>
				<xsl:if test="string($config/config/banner_image/@xlink:href)">
					<img src="{$display_path}ui/images/{$config/config/banner_image/@xlink:href}" alt="banner image"/>
				</xsl:if>
			</div>
			<ul role="menubar" id="menu">
				<li role="presentation">
					<a href="{$display_path}.">Home</a>
				</li>

				<li role="presentation">
					<a href="{$display_path}results/?q=*:*">Browse</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}search/">Search</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}maps/">Maps</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}admin/">Admin</a>
				</li>
			</ul>
		</div>
	</xsl:template>

	<xsl:template name="footer">
		<div id="ft">
			<a href="https://github.com/ewg118/eaditor">EADitor</a> ©2013 Ethan Gruber. <a href="http://www.apache.org/licenses/LICENSE-2.0.html">License.</a>
		</div>
	</xsl:template>

</xsl:stylesheet>
