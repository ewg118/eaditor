<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:template name="header">
	
	<div class="top-msg-wrap">
  		<div class="full-wrap clearfix">
      		</div>
	</div>

<div id="header_wrapper">

  <header id="header" role="banner">
    <div class="senylrc_top_container">
    <div class="top_left">
              <div id="logo">
          <a href="/" title="Home"><img src="http://www2.empireadc.org/sites/www2.empireadc.org/files/ead_logo.gif"/></a>
        </div>
      
      <h1 id="site-title">
        <a href="/" title="Home"></a>
      
      </h1>
    </div>
	  
    <div class="top_right">
	<div id="site-description">Finding Aids at Your Fingertips</div> 
      <nav id="main-menu"  role="navigation">
        <a class="nav-toggle" href="#">Menu</a>
        <div class="menu-navigation-container">
          <ul class="menu"><li class="first leaf"><a href="http://www2.empireadc.org/ead/results" title="">Browse</a></li>
<li class="leaf"><a href="http://www2.empireadc.org/ead/search" title="">Search</a></li>
<li class="leaf"><a href="http://www2.empireadc.org/ead/maps" title="">Map</a></li>
<li class="leaf"><a href="/participate" title="">Participate</a></li>
<li class="last leaf"><a href="/about" title="">About</a></li>
</ul>        </div>
        <div class="clear"></div>
      </nav>
    </div>
	</div>

    <div class="clear"></div>

  </header>
	</div>
	</xsl:template>
	<xsl:template name="footer">
		<xsl:copy-of select="//config/content/footer/*"/>
	</xsl:template>

</xsl:stylesheet>
