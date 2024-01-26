<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html-components="http://www.w3.org/1999/xhtml/components"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:pages="http://www.dh.uni-wuppertal/ns/schueler/pages"
    xmlns:path="http://www.dh.uni-wuppertal/ns/schueler/path"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="html"/>

    <!-- path.xslt is imported here; so we can use the functions defined there -->
    <xsl:import href="components.xslt"/>

    <xsl:variable name="self" select="document('')/*/xsl:template" as="element(xsl:template)*"/>

    <!-- 
        This named template will create the content for a page, when it's called
        it will use all templates defined in **this** xslt-stylesheets.
        
        It uses some 'magic' to match xsl:templates itself instead of the
        provided xml-context. 
        
        See https://stackoverflow.com/questions/5656129/xslt-call-template-with-dynamic-qname
        for more details on this approach.
        
        For parameters see below.
    -->

    <xsl:template name="create-page">
        <xsl:param name="context" as="xs:string"/>
        <xsl:param name="data" as="map(xs:string, document-node())"/>
        <xsl:param name="img-path" as="xs:string"/>
        <xsl:param name="output-dir" as="xs:string"/>
        <xsl:param name="page" as="element(pages:page)"/>
        <xsl:param name="pages" as="element(pages:pages)"/>
        <xsl:param name="page-title" as="xs:string"/>
        <xsl:param name="stylesheets" as="xs:string"/>
        <xsl:message select="'Will create page: **' || $page/@key || '** saved as ' || $context"/>
        <xsl:variable name="specific-content">
            <xsl:apply-templates select="$self[@name = $page/@key]">
                <xsl:with-param name="context" select="$context" as="xs:string"/>
                <xsl:with-param name="img-path" select="$img-path" as="xs:string"/>
                <xsl:with-param name="output-dir" select="$output-dir" as="xs:string"/>
                <xsl:with-param name="page" select="$page" as="element(pages:page)"/>
                <xsl:with-param name="pages" select="$pages" as="element(pages:pages)"/>
                <xsl:with-param name="page-title" select="$page-title" as="xs:string"/>
                <xsl:with-param name="stylesheets" select="$stylesheets" as="xs:string"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="page-content">
            <xsl:choose>
                <xsl:when test="$specific-content/* => empty()">
                    <xsl:message select="'Seems like there are no content templates for **' || $page/@key || '**, applyling default content template.'"/>
                        <xsl:apply-templates select="$self[@name = 'default-content']">
                            <xsl:with-param name="context" select="$context" as="xs:string"/>
                            <xsl:with-param name="img-path" select="$img-path" as="xs:string"/>
                            <xsl:with-param name="output-dir" select="$output-dir" as="xs:string"/>
                            <xsl:with-param name="page" select="$page" as="element(pages:page)"/>
                            <xsl:with-param name="pages" select="$pages" as="element(pages:pages)"/>
                            <xsl:with-param name="page-title" select="$page-title" as="xs:string"/>
                            <xsl:with-param name="stylesheets" select="$stylesheets" as="xs:string"/>
                        </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message select="'Specific content templates successfully applied!'"/>
                    <xsl:sequence select="$specific-content"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:result-document method="html" href="{$context}">
            <xsl:sequence select="$page-content"/>
        </xsl:result-document>
    </xsl:template>


    <xsl:template match="xsl:template[@name = 'default-content']" name="default-content">
        <xsl:param name="context" as="xs:string"/>
        <xsl:param name="img-path" as="xs:string"/>
        <xsl:param name="output-dir" as="xs:string"/>
        <xsl:param name="page" as="element(pages:page)"/>
        <xsl:param name="pages" as="element(pages:pages)"/>
        <xsl:param name="page-title" as="xs:string"/>
        <xsl:param name="stylesheets" as="xs:string"/>
        <xsl:variable name="default-content" as="element(html:main)">
            <main class="container">
                <h1>
                    <xsl:value-of select="$page/@key"/>
                </h1>
                <p>Noch kein Inhalt vorhanden für Seite: <xsl:value-of select="($page/@name | $page/@key)[1]"/></p>
            </main>
        </xsl:variable>
        <xsl:call-template name="html-components:create-page">
            <xsl:with-param name="page-head"
                select="html-components:create-head($page-title, $context, $stylesheets)"/>
            <xsl:with-param name="nav"
                select="html-components:create-header-with-nav($page-title, $output-dir, $context, $pages)"/>
            <xsl:with-param name="content" select="$default-content"/>
            <xsl:with-param name="footer"
                select="html-components:create-footer($context, $img-path)"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
