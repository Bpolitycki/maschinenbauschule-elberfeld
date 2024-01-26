<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:pages="http://www.dh.uni-wuppertal/ns/schueler/pages"
    xmlns:persons="http://www.dh.uni-wuppertal/ns/schueler/persons"
    xmlns:path="http://www.dh.uni-wuppertal/ns/schueler/path"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.0">

    <xsl:import href="path.xslt"/>


    <xsl:function name="persons:generate-list-entries" as="map(xs:string, map(xs:string, item()))">
        <xsl:param name="persons" as="element(tei:surname)+"/>
        <xsl:param name="outer-file-context" as="xs:string"/>
        <xsl:variable name="dir" select="path:extract-filename-and-dir($outer-file-context)?dir"/>
        <xsl:sequence>
            <xsl:map>
                <xsl:for-each select="$persons">
                    <xsl:variable name="forename" select="./../tei:forename/normalize-space()"/>
                    <xsl:variable name="surname" select="normalize-space(.)"/>
                    <xsl:variable name="id" select="generate-id(.)"/>
                    <xsl:variable name="local-page" as="element(pages:page)">
                        <page xmlns="http://www.dh.uni-wuppertal/ns/schueler/pages"
                            key="{$id}" name="{$forename} {$surname}" dynamic-view="schueler-details"/>
                    </xsl:variable>
                    <xsl:variable name="file" as="xs:string"
                        select="path:construct-file-name($local-page, $dir) => path:make-absolute() => path:add-file-scheme()"/>
                    <xsl:map-entry key="$id">
                        <xsl:map>
                            <xsl:map-entry key="'page'" select="$local-page"/>
                            <xsl:map-entry key="'file'" select="$file"/>
                            <xsl:map-entry key="'entry'">
                                <li title="Mehr erfahren zu: {$forename} {$surname}">
                                    <a href="{path:get-relative-path($outer-file-context, $file)}">
                                        <xsl:value-of select="."/>, <xsl:value-of select="$forename"
                                        />
                                    </a>
                                </li>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                </xsl:for-each>
            </xsl:map>
        </xsl:sequence>
    </xsl:function>

</xsl:stylesheet>
