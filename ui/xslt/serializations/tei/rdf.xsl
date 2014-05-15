<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xhv="http://www.w3.org/1999/xhtml/vocab#" xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" exclude-result-prefixes="#all" version="2.0">

	<!-- ***************** TEI-TO-RDF ******************-->
	<xsl:template name="tei-content">
		<rdf:Description rdf:about="{$objectUri}">
			<dcterms:title>
				<xsl:choose>
					<xsl:when test="string(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)">
						<xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@xml:id"/>
					</xsl:otherwise>
				</xsl:choose>
			</dcterms:title>
			<xsl:apply-templates select="descendant::tei:ref"/>
		</rdf:Description>
	</xsl:template>

	<xsl:template match="tei:ref">
		<skos:related rdf:resource="{@target}"/>
	</xsl:template>

</xsl:stylesheet>
