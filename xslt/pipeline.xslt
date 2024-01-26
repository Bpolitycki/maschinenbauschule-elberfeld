<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html-components="http://www.w3.org/1999/xhtml/components"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:pages="http://www.dh.uni-wuppertal/ns/schueler/pages"
    xmlns:path="http://www.dh.uni-wuppertal/ns/schueler/path"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="html"/>

    <!-- path.xslt and components are imported in content.xslt; so we can use the functions also here -->
    <xsl:import href="content.xslt"/>

    <xsl:param name="base-uri" as="xs:string" select="path:create-default-build-path(root())"/>
    <xsl:param name="data-dir" select="'data'" as="xs:string"/>
    <xsl:param name="static-dir" select="'static'" as="xs:string"/>
    <xsl:param name="page-title" as="xs:string"
        select="'Die Schülerverzeichnisse der Maschinenbauschule Elberfeld-Barmen'"/>

    <xsl:variable name="output-dir" as="xs:string" select="path:join(($base-uri, 'build'))"/>
    <xsl:variable name="output-dir-with-scheme" as="xs:string"
        select="path:add-file-scheme($output-dir)"/>

    <xsl:variable name="data-path" as="xs:string"
        select="path:join(($base-uri, $data-dir)) => path:add-file-scheme()"/>
    <xsl:variable name="img-path" as="xs:string"
        select="path:join(($output-dir, $static-dir, 'images'))"/>
    <xsl:variable name="stylesheets" as="xs:string"
        select="path:join(($output-dir, $static-dir, 'main.css'))"/>

    <xsl:variable name="data-loaded" as="map(xs:string, document-node())"
        select="path:load-documents($data-path, ./pages:pages)"/>

    <xsl:template match="pages:pages">
        <xsl:message
            select="'Starting generation for ' || count(.//pages:page) || ' page-elements:'"/>
        <xsl:message select="'Placing output into: ' || $output-dir"/>
        <xsl:message select="$base-uri"/>
        <xsl:message select="$data-path"/>
        <xsl:for-each select="pages:page">
            <xsl:call-template name="create-pages">
                <xsl:with-param name="page" as="element(pages:page)" select="."/>
                <xsl:with-param name="path-base" as="xs:string" select="$output-dir-with-scheme"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="create-pages">
        <xsl:param name="page" as="element(pages:page)"/>
        <xsl:param name="path-base" as="xs:string"/>
        <xsl:variable name="file-context" as="xs:string"
            select="path:construct-file-name($page, $path-base)"/>
        <xsl:choose>
            <xsl:when test="$page/pages:page">
                <xsl:variable name="context-path" as="xs:string" select="$file-context"/>
                <xsl:message
                    select="'Page **' || $page/@key || '** has subpages and will be a directory'"/>
                <xsl:for-each select="$page/pages:page">
                    <xsl:call-template name="create-pages">
                        <xsl:with-param name="page" as="element(pages:page)" select="."/>
                        <xsl:with-param name="path-base" as="xs:string" select="$context-path"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$page/@menu-only and xs:boolean($page/@menu-only)">
                <xsl:message select="'**' || $page/@key || '** is only a menu entry'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message
                    select="'Will create page: **' || $page/@key || '** saved as ' || $file-context"/>

                <xsl:call-template name="create-page">
                    <xsl:with-param name="context" select="$file-context" as="xs:string"/>
                    <xsl:with-param name="data" select="$data-loaded"
                        as="map(xs:string, document-node())"/>
                    <xsl:with-param name="img-path" select="$img-path" as="xs:string"/>
                    <xsl:with-param name="output-dir" select="$output-dir" as="xs:string"/>
                    <xsl:with-param name="page" select="$page" as="element(pages:page)"/>
                    <xsl:with-param name="pages" select="$page/ancestor::pages:pages"
                        as="element(pages:pages)"/>
                    <xsl:with-param name="page-title" select="$page-title" as="xs:string"/>
                    <xsl:with-param name="stylesheets" select="$stylesheets" as="xs:string"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



</xsl:stylesheet>
