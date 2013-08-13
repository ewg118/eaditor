<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:void="http://rdfs.org/ns/void#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:oac="http://www.openannotation.org/ns/" xmlns:owl="http://www.w3.org/2002/07/owl#" exclude-result-prefixes="xs" version="2.0">

	<xsl:template match="/config">
		<rdf:RDF>
			<void:dataSet>
				<dcterms:title>
					<xsl:value-of select="title"/>
				</dcterms:title>
				<dcterms:description>
					<xsl:value-of select="description"/>
				</dcterms:description>
				<dcterms:publisher>
					<xsl:value-of select="publisher"/>
				</dcterms:publisher>
				<dcterms:license rdf:resource="{license}"/>
				<dcterms:subject rdf:resource="http://dbpedia.org/resource/Annotation"/>
				<void:dataDump rdf:resource="{url}pelagios.rdf"/>
			</void:dataSet>
		</rdf:RDF>
	</xsl:template>
</xsl:stylesheet>
