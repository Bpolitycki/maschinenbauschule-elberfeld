<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:path="http://www.dh.uni-wuppertal/ns/schueler/path"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="#all" version="3.0">
    
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:import href="path.xslt"/>
    
    <xsl:param name="places-file" as="xs:string"/>
    <xsl:variable name="places" as="array(*)" select="$places-file => json-doc()"/>
    
    
    <xsl:template match="place[parent::listPlace][not(geo)]">
        <place>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <xsl:sequence select="tei:create-geo-info(., $places)"/>
        </place>
    </xsl:template>
    
    <xsl:function name="tei:create-geo-info" as="element(geo)?">
        <xsl:param name="place" as="element(place)"/>
        <xsl:param name="places" as="array(*)"/>
        <xsl:variable name="place-entry" as="map(*)?" select="tei:find-place-entry($place/@xml:id/data(.), $places)"/>
        <xsl:sequence>
            <xsl:if test="exists($place-entry)">
                <geo cert="{if (xs:boolean($place-entry?found_at_retry)) then 'low' else 'mid'}">
                    <xsl:value-of select="$place-entry?lat || ' ' || $place-entry?long"/>
                </geo>
            </xsl:if>
        </xsl:sequence>
    </xsl:function>
    
    <xsl:function name="tei:find-place-entry" as="map(*)?">
        <xsl:param name="place" as="xs:string"/>
        <xsl:param name="places" as="array(*)"/>
        <xsl:variable name="results" select="$places => array:filter(function($x as map(*)) {map:get($x, 'place_id') = $place})"/>
        <xsl:sequence>
            <xsl:if test="exists($results) and array:size($results) > 0">
                <xsl:sequence select="array:get($results, 1)"/>
            </xsl:if>
        </xsl:sequence>
    </xsl:function>
    
</xsl:stylesheet>
