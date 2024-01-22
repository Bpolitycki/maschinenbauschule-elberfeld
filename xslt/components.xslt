<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:html-components="http://www.w3.org/1999/xhtml/components"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="3.0"
    >
    
    <!--
         Creates a HTML head with a page title and a link to external
         resources like stylesheets.
         
         @param $title The page title
         @return The HTML head as element(head)
    -->
    <xsl:function name="html-components:create-head" as="element(html:head)">
        <xsl:param name="title" as="xs:string"/>
        <xsl:sequence>
            <head>
                <title><xsl:value-of select="$title"/></title>
                <meta charset="UTF-8"/>
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css"/>
            </head>
        </xsl:sequence>
    </xsl:function>
    
    
    
</xsl:stylesheet>
