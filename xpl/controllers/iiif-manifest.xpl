<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2017 Ethan Gruber
	EADitor
	Apache License 2.0
	Function: Evaluate namespace of the XML document and choose appropriate serialization pipeline into IIIF Manifest JSON-LD	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">
    <p:param type="input" name="data"/>
    <p:param type="output" name="data"/>

    <p:processor name="oxf:pipeline">
        <p:input name="config" href="../models/config.xpl"/>
        <p:output name="data" id="config"/>
    </p:processor>

    <!-- call XPL based on namespace of document -->
    <p:processor name="oxf:unsafe-xslt">
        <p:input name="data" href="#data"/>
        <p:input name="config">
            <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <xsl:template match="/">
                    <recordType>
                        <xsl:choose>
                            <xsl:when test="*/namespace-uri()='http://www.tei-c.org/ns/1.0'">TEI</xsl:when>
                            <xsl:when test="*/namespace-uri()='urn:isbn:1-931666-22-9'">EAD</xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </recordType>
                </xsl:template>
            </xsl:stylesheet>
        </p:input>
        <p:output name="data" id="recordType"/>
    </p:processor>

    <p:choose href="#recordType">
        <p:when test="recordType='TEI'">
            <p:processor name="oxf:pipeline">
                <p:input name="data" href="#data"/>
                <p:input name="config" href="../views/serializations/tei/iiif-manifest.xpl"/>
                <p:output name="data" ref="data"/>
            </p:processor>
        </p:when>
        <p:when test="recordType='EAD'">
            <p:processor name="oxf:pipeline">
                <p:input name="data" href="#data"/>
                <p:input name="config" href="../views/serializations/ead/iiif-manifest.xpl"/>
                <p:output name="data" ref="data"/>
            </p:processor>
        </p:when>
        <p:otherwise>
            <p:processor name="oxf:identity">
                <p:input name="data">
                    <response>Not valid for IIIF</response>
                </p:input>
                <p:output name="data" ref="data"/>
            </p:processor>
        </p:otherwise>

    </p:choose>
</p:config>
