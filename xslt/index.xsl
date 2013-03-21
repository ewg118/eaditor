<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" version="2.0">
	<xsl:output doctype-public="-//W3C//DTD HTML 4.01//EN" method="html" encoding="UTF-8"/>
	<xsl:include href="header-public.xsl"/>
	<xsl:include href="footer-public.xsl"/>

	<xsl:variable name="exist-url" select="/exist-url"/>
	<xsl:variable name="config" select="document(concat($exist-url, 'eaditor/config.xml'))"/>
	<xsl:variable name="ui-theme" select="exsl:node-set($config)/config/theme/jquery_ui_theme"/>
	<xsl:variable name="display_path"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="exsl:node-set($config)/config/title"/>
				</title>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/grids/grids-min.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/reset-fonts-grids/reset-fonts-grids.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/base/base-min.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/fonts/fonts-min.css"/>

				<!-- EADitor styling -->
				<link rel="stylesheet" href="{$display_path}css/style.css"/>
				<link rel="stylesheet" href="{$display_path}css/themes/{$ui-theme}.css"/>

				<script type="text/javascript" src="{$display_path}javascript/jquery-1.4.2.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/menu.js"/>
			</head>
			<body class="yui-skin-sam">
				<div id="doc4">
					<!-- header -->
					<xsl:call-template name="header-public"/>

					<div id="bd">
						<div id="yui-main">
							<div class="yui-b">
								<div class="yui-gc">
									<div class="yui-u first">
										<h2>Introduction</h2>
										<p>EADitor is an XForms framework for the creation and editing of <a href="http://www.loc.gov/ead/" rel="nofollow">Encoded Archival Description</a> (EAD)
											finding aids using <a href="http://www.orbeon.com" rel="nofollow">Orbeon</a>, an enterprise-level XForms Java application, which runs in Apache Tomcat. </p>
										<h2>Why XForms?</h2>
										<p>Many institutions have faced challenges in the efficient creation of electronic finding aids since the introduction of EAD in 1998. For finding aids to be
											useful to patrons of archives, robust metadata is required to adequately describe the conceptual organization of a manuscript collection. Subject
											specialists contribute their knowledge to provide context to the collection, which allows it to be searched more relevantly. EAD is a complex descriptive
											schema, and not all archivists or subject specialists can (or should) be required to be competent in XML encoding. The use of <a
												href="http://www.w3.org/MarkUp/Forms/" rel="nofollow">XForms</a>, a W3C standard, to allow the creation of robust metadata through a next-generation web
											form removes barriers from subject specialists in the creation of EAD guides and reduces the potential for human errors in semantic usage or invalid XML. </p>
										<p>Since XForms is used for creating true XML, it is also possible to import EAD files from the "wild" into EADitor with some minor transformation to correct
											encoding inconsistencies. This is a feature that cannot be easily accomplished in Archon or Archivists' Toolkit, which flatten out complicated hierarchical
											XML structure to fit into a series of database tables. XForms and XForms applications, like Orbeon, are ripe for integrating into the Library, Archive, and
											Museum (LAM) universe. Other organizations are endeavoring to utilize XForms for the creation of MODS, Dublin Core, and VRA Core records. XForms represent
											the future for metadata creation in the library and archival communities. </p>
										<h2>More Info</h2>
										<p>Technical list, geared toward XForms developers in libraries: <a href="https://list.mail.virginia.edu/mailman/listinfo/xforms4lib" rel="nofollow"
												>https://list.mail.virginia.edu/mailman/listinfo/xforms4lib</a>
										</p>
										<p>Non-technical list, for librarians and archivists interested in EADitor specifically: <a href="http://groups.google.com/group/eaditor" rel="nofollow"
												>http://groups.google.com/group/eaditor</a>
										</p>
									</div>
									<div class="yui-u">
										<div class="quick_search">
											<h3>Search Entire Collection</h3>
											<form action="results/" method="GET">
												<input type="text" id="qs_text" name="q"/>
												<input id="qs_button" type="submit" value="Search"/>
											</form>
										</div>
										<div id="linked_data">
											<h3>Linked Data</h3>
											<a href="{$display_path}feed/?q=*:*">
												<img src="{$display_path}images/atom-large.png" title="Atom" alt="Atom"/>
											</a>
											<xsl:if test="exsl:node-set($config)/config/oai-pmh/@active='true'">
												<a href="{$display_path}oai/?verb=ListRecords&amp;metadataPrefix=oai_dc&amp;set=ead">
													<img src="{$display_path}images/oai-pmh.png" title="OAI-PMH" alt="OAI-PMH"/>
												</a>
											</xsl:if>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					<!-- footer -->
					<xsl:call-template name="footer-public"/>
				</div>



			</body>
		</html>
	</xsl:template>





</xsl:stylesheet>
