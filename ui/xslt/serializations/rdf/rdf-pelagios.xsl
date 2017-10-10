<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:digest="org.apache.commons.codec.digest.DigestUtils"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:schema="http://schema.org/" xmlns:oa="http://www.w3.org/ns/oa#" xmlns:pelagios="http://pelagios.github.io/vocab/terms#"
    xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:svcs="http://rdfs.org/sioc/services#" xmlns:doap="http://usefulinc.com/ns/doap#"
    xmlns:relations="http://pelagios.github.io/vocab/relations#" exclude-result-prefixes="xs xsl digest" version="2.0">

    <xsl:variable name="url" select="/content/config/url"/>

    <xsl:template match="/">
        <rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:schema="http://schema.org/"
            xmlns:oa="http://www.w3.org/ns/oa#" xmlns:pelagios="http://pelagios.github.io/vocab/terms#" xmlns:edm="http://www.europeana.eu/schemas/edm/"
            xmlns:svcs="http://rdfs.org/sioc/services#" xmlns:doap="http://usefulinc.com/ns/doap#" xmlns:relations="http://pelagios.github.io/vocab/relations#">
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
            
            
            <xsl:apply-templates select="dcterms:title | dcterms:type | dcterms:isPartOf | foaf:thumbnail | foaf:depiction" />

            <!-- determine whether IIIF services should be attached -->
            <xsl:choose>
                <xsl:when test="edm:isShownBy/edm:WebResource">
                    <edm:isShownBy rdf:resource="{edm:isShownBy/edm:WebResource/@rdf:about}"/>
                </xsl:when>
                <xsl:when test="edm:isShownBy/@rdf:resource">
                    <edm:isShownBy rdf:resource="{edm:isShownBy/@rdf:resource}"/>
                </xsl:when>
            </xsl:choose>

            <xsl:apply-templates select="dcterms:date[@rdf:datatype]"/>

            <foaf:homepage rdf:resource="{@rdf:about}"/>
        </pelagios:AnnotatedThing>

        <!-- determine whether IIIF services should be attached -->
        <xsl:apply-templates select="edm:isShownBy"/>

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
    
    <xsl:template match="dcterms:title | dcterms:type | dcterms:isPartOf | foaf:thumbnail | foaf:depiction | dcterms:isReferencedBy | dcterms:conformsTo | doap:implements">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:if test="@rdf:resource">
                <xsl:attribute name="rdf:resource" select="@rdf:resource"/>                
            </xsl:if>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <!-- 'flatten' out the IIIF service metadata by applying templates under different conditions of nested RDF/XML -->
    <xsl:template match="edm:isShownBy">
        <xsl:choose>
            <xsl:when test="edm:WebResource">
                <xsl:apply-templates select="edm:WebResource"/>
            </xsl:when>
            <xsl:when test="@rdf:resource">
                <xsl:variable name="uri" select="@rdf:resource"/>

                <xsl:if test="//edm:WebResource[@rdf:about = $uri]">
                    <xsl:apply-templates select="//edm:WebResource[@rdf:about = $uri]"/>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="edm:WebResource">
        <xsl:element name="{name()}">
            <xsl:attribute name="rdf:about" select="@rdf:about"/>
            <xsl:apply-templates select="dcterms:isReferencedBy"/>
            <xsl:choose>
                <xsl:when test="svcs:has_service/svcs:Service">
                    <svcs:has_service rdf:resource="{svcs:has_service/svcs:Service/@rdf:about}"/>
                </xsl:when>
                <xsl:when test="svcs:has_service/@rdf:resource">
                    <svcs:has_service rdf:resource="{svcs:has_service/@rdf:resource}"/>
                </xsl:when>
            </xsl:choose>
        </xsl:element>
        <xsl:apply-templates select="svcs:has_service"/>
    </xsl:template>

    <xsl:template match="svcs:has_service">
        <xsl:choose>
            <xsl:when test="svcs:Service">
                <xsl:apply-templates select="svcs:Service"/>
            </xsl:when>
            <xsl:when test="@rdf:resource">
                <xsl:variable name="uri" select="@rdf:resource"/>

                <xsl:if test="//svcs:Service[@rdf:about = $uri]">
                    <xsl:apply-templates select="//svcs:Service[@rdf:about = $uri]"/>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="svcs:Service">
        <xsl:element name="{name()}" namespace="http://rdfs.org/sioc/services#">
            <xsl:attribute name="rdf:about" select="@rdf:about"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dcterms:date">
        <dcterms:temporal>
            <xsl:value-of select="."/>
        </dcterms:temporal>
    </xsl:template>

</xsl:stylesheet>
