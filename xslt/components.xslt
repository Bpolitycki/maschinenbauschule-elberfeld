<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:html-components="http://www.w3.org/1999/xhtml/components"
    xmlns:pages="http://www.dh.uni-wuppertal/ns/schueler/pages"
    xmlns:path="http://www.dh.uni-wuppertal/ns/schueler/path"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0"
    >
    
    <xsl:import href="path.xslt"/>
    
    <!--
         Creates a HTML head with a page title and a link to external
         resources like stylesheets.
         
         @param $title The page title
         @param $context-file The file that is the context for the page
         @param $style-files A sequence of paths to stylesheets (http or absolute paths)
         @return The HTML head as element(head)
    -->
    <xsl:function name="html-components:create-head" as="element(html:head)">
        <xsl:param name="title" as="xs:string"/>
        <xsl:param name="context-file" as="xs:string"/>
        <xsl:param name="style-files" as="xs:string*"/>
        <xsl:sequence>
            <head>
                <title>
                    <xsl:value-of select="$title"/>
                </title>
                <meta charset="UTF-8"/>
                <xsl:for-each select="$style-files">
                    <xsl:choose>
                        <xsl:when test="$style-files => starts-with('http')">
                            <link rel="stylesheet" href="{$style-files}"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <link rel="stylesheet" href="{path:get-relative-path($context-file, .)}"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </head>
        </xsl:sequence>
    </xsl:function>
    
    <xsl:function name="html-components:create-header-with-nav" as="element(html:header)">
        <xsl:param name="title" as="xs:string"/>
        <xsl:param name="output-dir" as="xs:string"/>
        <xsl:param name="context-file" as="xs:string"/>
        <xsl:param name="pages" as="element(pages:pages)"/>
        <xsl:sequence>
            <header class="container">
                <a href="{path:get-relative-path($context-file, path:join(($output-dir, 'index.html')))}" title="Zur Startseite">
                    <h1>
                        <xsl:value-of select="$title"/>
                    </h1>
                </a>
                <nav>
                    <ul>
                        <xsl:for-each select="$pages/pages:page">
                            <xsl:if test=".[not(@key = '/')]">
                                <xsl:sequence select="html-components:create-nav-entry($output-dir, $context-file, .)"/>
                            </xsl:if>
                            
                        </xsl:for-each>
                    </ul>
                </nav>
            </header>
        </xsl:sequence>
    </xsl:function>
    
    
    <!--
         Creates the entries for the navigation bar.
         
         @param $path-base The base path for the page as xs:string
         @param $context-file The file that is the context for the page as xs:string
         @param $current-page The current page as element(pages:page)
         @return The navigation entry as element(html:li)
    -->
    <xsl:function name="html-components:create-nav-entry" as="element(html:li)">
        <xsl:param name="path-base" as="xs:string"/>
        <xsl:param name="context-file" as="xs:string"/>
        <xsl:param name="current-page" as="element(pages:page)"/>
        <xsl:variable name="page-path" as="xs:string" select="path:construct-file-name($current-page, $path-base)"/>
        <xsl:sequence>
            <xsl:choose>
                <xsl:when test="$current-page/pages:page">
                    <li role="list" dir="rtl">
                        <a href="#" aria-haspopup="listbox">
                            <xsl:value-of select="$current-page/@name"/>
                        </a>
                        <ul role="listbox">
                            <xsl:for-each select="$current-page/pages:page">
                                <xsl:sequence select="html-components:create-nav-entry($page-path, $context-file, .)"/>
                            </xsl:for-each>
                        </ul>
                    </li>
                </xsl:when>
                <xsl:when test="$current-page/@menu-only and xs:boolean($current-page/@menu-only)">
                    <li class="not-active">
                        <xsl:value-of select="$current-page/@name"/>
                    </li>
                </xsl:when>
                <xsl:when test="$context-file => ends-with($current-page/@key || '.html')">
                    <li title="Aktuelle Seite">
                        <xsl:value-of select="$current-page/@name"/>
                    </li>
                </xsl:when>
                <xsl:otherwise>
                    <li>
                        <a href="{path:get-relative-path($context-file, $page-path)}" title="{$current-page/@name}">
                            <xsl:value-of select="$current-page/@name"/>
                        </a>
                    </li>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:sequence>
    </xsl:function>
    
    <xsl:function name="html-components:create-footer" as="element(html:footer)">
        <xsl:param name="context-file" as="xs:string"/>
        <xsl:param name="image-path" as="xs:string*"/>
        <xsl:sequence>
            <footer class="container-fluid">
                <p>Letzte Änderung: <xsl:value-of select="format-date(current-date(), '[D01].[M01].[Y0001]')"/></p>
                <a href="https://www.uni-wuppertal.de/" target="_blank" title="Uni Wuppertal">
                    <img src="{path:get-relative-path($context-file, path:join(($image-path, 'buw_logo.png')))}" alt="Logo der BUW"/>
                </a>
            </footer>
        </xsl:sequence>
    </xsl:function>
    
    <xsl:template name="html-components:create-page">
        <xsl:param name="page-head" as="element(html:head)"/>
        <xsl:param name="nav" as="element(html:header)"/>
        <xsl:param name="content" as="element()"/>
        <xsl:param name="footer" as="element(html:footer)"/>
        <html>
            <xsl:sequence select="$page-head"/>
            <body>
                <xsl:sequence select="($nav, $content, $footer)"/>
            </body>
        </html>
    </xsl:template>
    
    
    
    
    
</xsl:stylesheet>
