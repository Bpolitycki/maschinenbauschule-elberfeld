<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:pages="http://www.dh.uni-wuppertal/ns/schueler/pages"
    xmlns:iiif="http://www.dh.uni-wuppertal/ns/schueler/iiif"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.0">

    <xsl:variable name="iiif-host" as="xs:string"
        select="'https://iiif.dh-projekte.uni-wuppertal.de/iiif/2'"/>
    <xsl:variable name="image-base" as="xs:string" select="'schuelerverzeichnisse'"/>

    <!--
         Create a URL for a IIIF image
         
         @param $host The host name
         @param $image_base The image base
         @param $image_id The image id
         @param $part The part of the image to show ('full' for the complete image)
         @param $scale The scale factor
         @param $rotation The rotation angle
         @return The URL as xs:string
    -->
    <xsl:function name="iiif:create-url" as="xs:string">
        <xsl:param name="host" as="xs:string"/>
        <xsl:param name="image_base" as="xs:string"/>
        <xsl:param name="image_id" as="xs:string"/>
        <xsl:param name="part" as="xs:string"/>
        <xsl:param name="scale" as="xs:string"/>
        <xsl:param name="rotation" as="xs:integer"/>

        <xsl:sequence>
            <xsl:text expand-text="yes">{$host}/{$image_base}%2F{$image_id}/{$part}/{$scale}/{xs:string($rotation)}/default.jpg</xsl:text>
        </xsl:sequence>
    </xsl:function>

    <!--
         Convert a TEI zone to a IIIF region
         
         @param $zone The TEI zone element
         @return The IIIF region as xs:string
    -->
    <xsl:function name="iiif:points-to-part" as="xs:string">
        <xsl:param name="zones" as="element(tei:zone)+"/>
        <xsl:variable name="point_pairs" as="xs:string+" select="$zones ! tokenize(./@points, '\s')"/>
        <xsl:variable name="xs" as="xs:integer*"
            select="$point_pairs ! xs:integer(substring-before(., ','))"/>
        <xsl:variable name="ys" as="xs:integer*"
            select="$point_pairs ! xs:integer(substring-after(., ','))"/>

        <!-- Calculate bounding box -->
        <xsl:variable name="min_x" select="min($xs)"/>
        <xsl:variable name="max_x" select="max($xs)"/>
        <xsl:variable name="min_y" select="min($ys)"/>
        <xsl:variable name="max_y" select="max($ys)"/>
        <xsl:variable name="width" select="$max_x - $min_x"/>
        <xsl:variable name="height" select="$max_y - $min_y"/>

        <xsl:sequence select="string-join(($min_x, $min_y, $width, $height), ',')"/>
    </xsl:function>

    <!--
        Calculate the bounding box for a tei:cell- or tei:row-element. 
        The function retrieves all corresponding tei:zone-elements and
        returns the calculated bounding box.
        
        @param $context-cell The current cell as element(tei:cell)
        @return The bounding box (for IIIF) as xs:string
     -->
    <xsl:function name="iiif:get-points-for-cell-or-row" as="xs:string">
        <xsl:param name="context-cell" as="element()"/>
        <xsl:sequence select="iiif:points-to-part(iiif:find-zones($context-cell))"/>
    </xsl:function>

    <!-- 
        Finds all corresponding tei:zone-elements for a given 
        context. Uses the tei:lb-children and the supplied
        values of @facs.
        
        @param $context The context as element()
        @return The corresponding zones as element(tei:zone)+
     -->
    <xsl:function name="iiif:find-zones" as="element(tei:zone)+">
        <xsl:param name="context" as="element()"/>
        <xsl:sequence>
            <xsl:for-each select="$context//tei:lb/@facs">
                <xsl:sequence select="id(substring-after(., '#'), $context/ancestor::tei:TEI)"/>
            </xsl:for-each>
        </xsl:sequence>
    </xsl:function>

    <!-- 
        Find the name of image for a page / a table.
        
        @param $context-cell The current cell as element(tei:cell)
        @return The name as xs:string
    -->
    <xsl:function name="iiif:find-image-name" as="xs:string">
        <xsl:param name="context-cell" as="element(tei:cell)"/>
        <xsl:variable name="parent-table" select="$context-cell/ancestor::tei:table"/>
        <xsl:sequence
            select="id(substring-after($parent-table/@facs, '#'), $parent-table/ancestor::tei:TEI)/ancestor-or-self::tei:surface/tei:graphic[1]/@url/data()"
        />
    </xsl:function>

</xsl:stylesheet>
