<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eaditor="http://code.google.com/p/eaditor/" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
	version="2.0">
	<xsl:include href="../results_functions.xsl"/>
	<xsl:param name="q">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	</xsl:param>
	<xsl:param name="tokenized_q" select="tokenize($q, ' AND ')"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>test</title>
			</head>
			<body>
				<xsl:call-template name="remove_facets"/>
			</body>
		</html>
		
	</xsl:template>

	<xsl:template name="remove_facets">
		<xsl:for-each select="$tokenized_q">
			<xsl:variable name="val" select="."/>
			<xsl:variable name="new_query">
				<xsl:for-each select="$tokenized_q[not($val = .)]">
					<xsl:value-of select="."/>
					<xsl:if test="position() != last()">
						<xsl:text> AND </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<!--<xsl:value-of select="."/>-->
			<xsl:choose>
				<xsl:when test="not(. = '*:*') and not(substring(., 1, 1) = '(')">
					<xsl:variable name="field" select="substring-before(., ':')"/>
					<xsl:variable name="name">
						<xsl:value-of select="eaditor:normalize_fields($field)"/>
					</xsl:variable>
					<xsl:variable name="term" select="replace(substring-after(., ':'), '&#x022;', '')"/>

					<div class="ui-widget ui-state-default ui-corner-all stacked_term">
						<span class="term">
							<b><xsl:value-of select="$name"/>: </b>
							<xsl:value-of select="if ($field = 'century_sint') then eaditor:normalize_century($term) else $term"/>
						</span>
						<a class="ui-icon ui-icon-closethick remove_filter" href="?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}">X</a>
					</div>

				</xsl:when>
				<!-- if the token contains a parenthisis, then it was probably sent from the search widget and the token must be broken down further to remove other facets -->
				<xsl:when test="substring(., 1, 1) = '('">
					<xsl:variable name="tokenized-fragments" select="tokenize(translate(., '()', ''), ' OR ')"/>
					<xsl:variable name="field" select="substring-before($tokenized-fragments[1], ':')"/>
					<xsl:variable name="name">
						<xsl:value-of select="eaditor:normalize_fields($field)"/>
					</xsl:variable>

					<xsl:variable name="multifields">
						<xsl:call-template name="multifields">
							<xsl:with-param name="field" select="$field"/>
							<xsl:with-param name="position" select="1"/>
							<xsl:with-param name="fragments" select="$tokenized-fragments"/>
							<xsl:with-param name="count" select="count($tokenized-fragments)"/>
						</xsl:call-template>
					</xsl:variable>

					<div class="ui-widget ui-state-default ui-corner-all stacked_term">
						<span class="term">
							<xsl:if test="$multifields != 'true'">
								<b><xsl:value-of select="$name"/>: </b>
							</xsl:if>
							<xsl:for-each select="$tokenized-fragments">
								<xsl:variable name="value" select="."/>
								<xsl:variable name="new_multicategory">
									<xsl:for-each select="$tokenized-fragments[not(. = $value)]">
										<xsl:value-of select="."/>
										<xsl:if test="position() != last()">
											<xsl:text> OR </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</xsl:variable>
								<xsl:variable name="multicategory_query">
									<xsl:choose>
										<xsl:when test="contains($new_multicategory, ' OR ')">
											<xsl:value-of select="concat('(', $new_multicategory, ')')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$new_multicategory"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>

								<!-- display either the term or the regularized name for the century -->
								<xsl:variable name="term" select="replace(substring-after(., ':'), '&#x022;', '')"/>

								<xsl:if test="$multifields = 'true'">
									<b>
										<xsl:value-of select="eaditor:normalize_fields(substring-before(., ':'))"/>
										<xsl:text>: </xsl:text>
									</b>
								</xsl:if>
								<xsl:value-of select="if (substring-before(., ':') = 'century_sint') then eaditor:normalize_century($term) else $term"/>



								<xsl:text>[</xsl:text>
								<!-- concatenate the query with the multicategory removed with the new multicategory, or if the multicategory is empty, display just the $new_query -->
								<a
									href="?q={if (string($multicategory_query) and string($new_query)) then encode-for-uri(concat($new_query, ' AND ', $multicategory_query)) else if (string($multicategory_query) and not(string($new_query))) then encode-for-uri($multicategory_query) else $new_query}"
									>X</a>
								<xsl:text>]</xsl:text>
								<xsl:if test="position() != last()">
									<xsl:text> OR </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</span>
						<a class="ui-icon ui-icon-closethick remove_filter" href="?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}">X</a>

					</div>
				</xsl:when>
				<xsl:when test="not(contains(., ':'))">
					<div class="ui-widget ui-state-default ui-corner-all stacked_term">
						<span>
							<b>Keyword: </b>
							<xsl:value-of select="."/>
						</span>
					</div>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<xsl:if test="string($tokenized_q[2])">
			<div class="ui-widget ui-state-default ui-corner-all stacked_term">
				<span class="term" id="clear_all">
					<a href="?q=*:*">Clear All Terms</a>
				</span>
			</div>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
