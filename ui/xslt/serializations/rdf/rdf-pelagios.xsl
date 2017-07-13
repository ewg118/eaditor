<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:digest="org.apache.commons.codec.digest.DigestUtils"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:schema="http://schema.org/" xmlns:oa="http://www.w3.org/ns/oa#" xmlns:pelagios="http://pelagios.github.io/vocab/terms#"
    xmlns:relations="http://pelagios.github.io/vocab/relations#" exclude-result-prefixes="xs xsl digest" version="2.0">

    <xsl:variable name="url" select="/content/config/url"/>

    <xsl:template match="/">
        <rdf:RDF>
            <foaf:Organization rdf:about="{$url}pelagios.rdf#agents/me">
                <foaf:name>
                    <xsl:value-of select="/content/config/publisher"/>
                </foaf:name>
            </foaf:Organization>
            <xsl:apply-templates select="//rdf:RDF/*" mode="annotation"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="*" mode="annotation">
        <xsl:variable name="id" select="digest:md5Hex(string(@rdf:about))"/>

        <pelagios:AnnotatedThing rdf:about="{$url}pelagios.rdf#{$id}">
            <xsl:copy-of select="dcterms:title | dcterms:type | dcterms:isPartOf | foaf:thumbnail | foaf:depiction"/>
            <xsl:apply-templates select="dcterms:date[@rdf:datatype]"/>

            <foaf:homepage rdf:resource="{@rdf:about}"/>
        </pelagios:AnnotatedThing>

        <xsl:for-each select="dcterms:coverage[starts-with(@rdf:resource, 'https://pleiades.stoa.org')]">
            <oa:Annotation rdf:about="{$url}pelagios.rdf#{$id}/annotations/{format-number(position(), '000')}">
                <oa:hasBody rdf:resource="{@rdf:resource}#this"/>
                <oa:hasTarget rdf:resource="{$url}pelagios.rdf#{$id}"/>
                <pelagios:relation rdf:resource="http://pelagios.github.io/vocab/relations#attestsTo"/>
                <oa:annotatedBy rdf:resource="{$url}pelagios.rdf#agents/me"/>
                <oa:annotatedAt rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                    <xsl:value-of select="current-dateTime()"/>
                </oa:annotatedAt>
            </oa:Annotation>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="dcterms:date">
        <dcterms:temporal>
            <xsl:value-of select="."/>
        </dcterms:temporal>
    </xsl:template>

</xsl:stylesheet>
