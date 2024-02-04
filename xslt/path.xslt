<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:pages="http://www.dh.uni-wuppertal/ns/schueler/pages"
                xmlns:path="http://www.dh.uni-wuppertal/ns/schueler/path"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:param name="strip-default-index-name" as="xs:boolean" select="true()"/>
    
    <xsl:variable name="default-index-name" select="'index.html'" as="xs:string"/>
    
    <!--
         Create a file- or directory-name from a page element.
         
         @param $page The page element.
         @param $output-dir The directory where the file should be created.
         @return The file- or directory-name.
    -->
    <xsl:function name="path:construct-file-name" as="xs:string">
        <xsl:param name="page" as="element(pages:page)"/>
        <xsl:param name="output-dir" as="xs:string"/>
        <xsl:variable name="path" as="xs:string">
            <xsl:choose>
                <xsl:when test="$page/@key = '/'">
                    <xsl:value-of select="path:join(($output-dir, $default-index-name))"/>
                </xsl:when>
                <xsl:when test="$page/pages:page">
                    <xsl:value-of select="path:join(($output-dir, encode-for-uri($page/@key)))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="path:join(($output-dir, encode-for-uri($page/@key), $default-index-name))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$path"/>
    </xsl:function>
    
    <!--
         Simple function to join path components.
         
         @param $components The path components as xs:string+.
         @return The joined path.
    -->
    <xsl:function name="path:join" as="xs:string">
        <xsl:param name="components" as="xs:string+"/>
        <xsl:value-of select="string-join($components, '/')"/>
    </xsl:function>
    
    <!--
         Load all data documents from a data-src-path, which are
         listed in a pages:pages-element.
         
         @param $data-src-path The path used as a base for data loading.
         @param $pages The pages structure as element(pages:pages).
         @return The loaded documents as map(xs:string, document-node())
    -->
    <xsl:function name="path:load-documents" as="map(xs:string, document-node())">
        <xsl:param name="data-src-path" as="xs:string"/>
        <xsl:param name="pages" as="element(pages:pages)"/>
        <xsl:variable name="names" as="xs:string+"
            select="($pages//@data-src ! tokenize(., ' ')) => distinct-values()"/>
        <xsl:variable name="documents" as="document-node()+"
            select="path:load($data-src-path, $names)"/>
        <xsl:sequence select="
            for-each-pair(
                $names, $documents,
                function ($name as xs:string, $document as document-node()) as map(xs:string, document-node()) {
                    map {$name: $document}
                }
            ) => map:merge()"/>
    </xsl:function>
    
    <!--
         Load one or more documents from a src-path by a given name.
         
         @param $data-src-path The path used as a base for data loading.
         @param $name One or more names of documents to load.
         @return The loaded documents as document-node()+.
    -->
    
    <xsl:function name="path:load" as="document-node()+">
        <xsl:param name="data-src-path" as="xs:string"/>
        <xsl:param name="name" as="xs:string+"/>
        <xsl:sequence select="$name ! (path:join(($data-src-path, .)) => doc())"/>
    </xsl:function>
    
    <!--
         Create a path to the build directory from the context of the current document.
         The build directory is always ../build relative to the input document, when
         this function is called.
         
         @param $context The context of the current document.
         @return The path to the build directory.
    -->
    <xsl:function name="path:create-default-build-path" as="xs:string">
        <xsl:param name="context" as="document-node()"/>
        <xsl:variable name="doc-uri" as="xs:anyURI" select="base-uri($context)"/>
        <xsl:variable name="context-dir" as="xs:string"
            select="xs:string($doc-uri) => path:extract-filename-and-dir() => map:get('dir')"/>
        <xsl:variable name="calculated-project-dir" as="xs:string"
            select="($context-dir => path:tokenize())[position() lt last()] => path:join() => path:remove-file-scheme() => path:make-absolute()"/>
        <xsl:value-of
            select="$calculated-project-dir"
            />
    </xsl:function>
    
    <!--
         Create a relative path from a source path to a target path.
         
         @param $source-path The source path.
         @param $target-path The target path.
         @return The relative path from the source path to the target path.
    -->
    <xsl:function name="path:get-relative-path" as="xs:string">
        <xsl:param name="source-path" as="xs:string"/>
        <xsl:param name="target-path" as="xs:string"/>
        <xsl:variable name="source-segments" as="xs:string*" select="path:tokenize($source-path)"/>
        <xsl:variable name="target-segments" as="xs:string*" select="path:tokenize($target-path)"/>
        <xsl:variable name="common-length" as="xs:integer">
            <xsl:iterate select="$source-segments">
                <xsl:param name="index" as="xs:integer" select="1"/>
                <xsl:on-completion select="$index"/>
                <xsl:choose>
                    <xsl:when
                        test="exists($target-segments[$index]) and . = $target-segments[$index]">
                        <xsl:next-iteration>
                            <xsl:with-param name="index" select="$index + 1"/>
                        </xsl:next-iteration>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:break select="$index - 1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:iterate>
        </xsl:variable>
        <xsl:variable name="up-segments" as="xs:string*" select="
            for $_ in 1 to count($source-segments) - $common-length - 1
            return
                '..'"/>
        <xsl:variable name="down-segments" as="xs:string*"
            select="$target-segments[position() gt $common-length]"/>
        <xsl:variable name="target-path" as="xs:string" select="path:join(('.', $up-segments, $down-segments))"/>
        <xsl:variable name="target-path-components" as="map(xs:string, xs:string?)" select="path:extract-filename-and-dir($target-path)"/>
        <xsl:sequence>
            <xsl:choose>
                <xsl:when test="$target-path-components?filename => exists() and $target-path-components?filename = $default-index-name and $strip-default-index-name">
                    <xsl:value-of select="$target-path-components?dir"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$target-path"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:sequence>
    </xsl:function>
    
    <!--
         Extract the filename and the directory from a path.
         
         @param $input-path The path from which the filename and the directory should be extracted.
         @return A map containing the filename and the directory. Where filename may be an empty-sequence()
    -->
    <xsl:function name="path:extract-filename-and-dir" as="map(xs:string, xs:string?)">
        <xsl:param name="input-path" as="xs:string"/>
        <xsl:variable name="components" as="xs:string*" select="path:tokenize($input-path)"/>
        <xsl:sequence>
            <xsl:map>
                <xsl:map-entry key="'filename'" select="$components[last()][path:is-file(.)]"/>
                <xsl:map-entry key="'dir'"
                    select="path:join($components[position() lt last() or not(path:is-file(.))])"/>
            </xsl:map>
        </xsl:sequence>
    </xsl:function>
    <!--
         Determine if a string is / may be a filename
         
         @param $input The to check.
         @return true() if the input is a filenemae otherwise false()
    -->
    <xsl:function name="path:is-file" as="xs:boolean">
        <xsl:param name="input" as="xs:string"/>
        <xsl:sequence select="matches($input, '^.*\.\w+$')"/>
    </xsl:function>
    
    <!--
         Tokenize a path.
         
         @param $input-path The path to be tokenized.
         @return The tokens of the path.
    -->
    <xsl:function name="path:tokenize" as="xs:string*">
        <xsl:param name="input-path" as="xs:string"/>
        <xsl:sequence>
            <xsl:for-each select="path:remove-file-scheme($input-path) => tokenize('/')">
                <xsl:if test="normalize-space(.) != ''">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:sequence>
    </xsl:function>
    
    <!--
         Add a file scheme to a path.
         
         @param $input-path The path to which the file scheme should be added.
         @return The path with the file scheme.
    -->
    <xsl:function name="path:add-file-scheme" as="xs:string">
        <xsl:param name="input-path" as="xs:string"/>
        <xsl:value-of select="'file://' || $input-path"/>
    </xsl:function>
    
    <!--
         Remove a file scheme from a path.
         
         @param $input-path The path from which the file scheme should be removed.
         @return The path without the file scheme.
    -->
    <xsl:function name="path:remove-file-scheme" as="xs:string">
        <xsl:param name="input-path" as="xs:string"/>
        <xsl:value-of select="$input-path => replace('^file://?(.*)', '$1')"/>
    </xsl:function>
    
    <xsl:function name="path:make-absolute" as="xs:string">
        <xsl:param name="input-path" as="xs:string"/>
        <xsl:sequence select="if ($input-path => starts-with('/')) then $input-path else '/' || $input-path"/>
    </xsl:function>
</xsl:stylesheet>
