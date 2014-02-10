<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xhv="http://www.w3.org/1999/xhtml/vocab#" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
	exclude-result-prefixes="mods xlink" version="2.0">
	<!-- ***************** MODS-TO-RDF ******************-->
	<xsl:template name="mods-content">
		<rdf:Description rdf:about="{$objectUri}">
			<dcterms:title>
				<xsl:value-of select="mods:titleInfo/mods:title"/>
			</dcterms:title>
		</rdf:Description>
	</xsl:template>
</xsl:stylesheet>
