<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html-components="http://www.w3.org/1999/xhtml/components"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:pages="http://www.dh.uni-wuppertal/ns/schueler/pages"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:output method="html"/>
    
    <xsl:import href="components.xslt"/>
    
    <xsl:param name="base-uri" as="xs:string" select="html:create-default-build-path(root())"/>
    <xsl:param name="data-dir" select="'data'" as="xs:string"/>
    <xsl:param name="page-title" as="xs:string" select="'Die Schülerverzeichnisse der Maschinenbauschule Elberfeld-Barmen'"/>
    
    <xsl:variable name="output-dir" as="xs:string" select="html:join-path(($base-uri, 'build'))"/>
    <xsl:variable name="output-dir-with-scheme" as="xs:string" select="'file:///' || $output-dir"/>
    
    <xsl:variable name="data-path" as="xs:string" select="'file:///' || html:join-path(($base-uri, $data-dir))"/>
    
    <xsl:template match="pages:pages">
        <xsl:message select="'Starting generation for ' || count(.//pages:page) || ' page-elements:'"/>
        <xsl:message select="'Placing output into: ' || $output-dir"/>
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
        <xsl:choose>
            <xsl:when test="$page/pages:page">
                <xsl:variable name="context-path" as="xs:string" select="html:construct-file-name($page, $path-base)"/>
                <xsl:message select="'Page **' || $page/@key || '** has subpages and will be a directory'"/>
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
                <xsl:message select="'Will create page: **' || $page/@key || '** saved as ' || html:construct-file-name($page, $path-base)"/>
                <xsl:result-document href="{html:construct-file-name($page, $path-base)}" method="html">
                    <html>
                        <xsl:sequence select="html-components:create-head($page-title)"/>
                        <body>
                            <h1>
                                <xsl:value-of select="$page/@name"/>
                            </h1>
                        </body>
                    </html>
                </xsl:result-document>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="html:construct-file-name" as="xs:string">
        <xsl:param name="page" as="element(pages:page)"/>
        <xsl:param name="output-dir" as="xs:string"/>
        <xsl:variable name="path" as="xs:string">
            <xsl:choose>
                <xsl:when test="$page/@key = '/' and not($page/@name)">
                    <xsl:value-of select="html:join-path(($output-dir, 'index.html'))"/>
                </xsl:when>
                <xsl:when test="$page/pages:page">
                    <xsl:value-of select="html:join-path(($output-dir, $page/@key))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="html:join-path(($output-dir, $page/@key, 'index.html'))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$path"/>
    </xsl:function>
    
    <xsl:function name="html:join-path" as="xs:string">
        <xsl:param name="components" as="xs:string+"/>
        <xsl:value-of select="string-join($components, '/')"/>
    </xsl:function>
    
    <xsl:function name="html:load-data" as="document-node()+">
        <xsl:param name="page" as="element(pages:page)"/>
        <xsl:sequence select="tokenize($page/@data-src, ' ') ! doc(html:join-path(($data-path, .)))"/>
    </xsl:function>
    
    <xsl:function name="html:create-default-build-path" as="xs:string">
        <xsl:param name="context" as="document-node()"/>
        <xsl:value-of select="substring-after(string-join((tokenize($context => document-uri(), '/')[position() lt last()]), '/') || '/..', 'file:')"/>
    </xsl:function>
    
</xsl:stylesheet>
