<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html-components="http://www.w3.org/1999/xhtml/components"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:iiif="http://www.dh.uni-wuppertal/ns/schueler/iiif"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:pages="http://www.dh.uni-wuppertal/ns/schueler/pages"
    xmlns:path="http://www.dh.uni-wuppertal/ns/schueler/path"
    xmlns:persons="http://www.dh.uni-wuppertal/ns/schueler/persons"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="html"/>

    <!-- path.xslt is imported here; so we can use the functions defined there -->
    <xsl:import href="components.xslt"/>
    <xsl:import href="iiif.xslt"/>

    <xsl:import href="persons.xslt"/>

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
        <xsl:result-document method="html" href="{$context}">
            <xsl:choose>
                <xsl:when
                    test="$self[@name = $page/@key] or $self[@name = $page/@dynamic-view] or $self[@name = $page/@name]">
                    <xsl:apply-templates
                        select="($self[@name = $page/@key], $self[@name = $page/@dynamic-view], $self[@name = $page/@name])[1]">
                        <xsl:with-param name="context" select="$context" as="xs:string"/>
                        <xsl:with-param name="data" select="$data"
                            as="map(xs:string, document-node())"/>
                        <xsl:with-param name="img-path" select="$img-path" as="xs:string"/>
                        <xsl:with-param name="output-dir" select="$output-dir" as="xs:string"/>
                        <xsl:with-param name="page" select="$page" as="element(pages:page)"/>
                        <xsl:with-param name="pages" select="$pages" as="element(pages:pages)"/>
                        <xsl:with-param name="page-title" select="$page-title" as="xs:string"/>
                        <xsl:with-param name="stylesheets" select="$stylesheets" as="xs:string"/>
                    </xsl:apply-templates>
                    <xsl:message
                        select="'Specific content templates successfully applied to **' || ($page/@key, $page/@name)[1] || '**'"
                    />
                </xsl:when>
                <!-- If no specific template for a page is found, the page named 'default-content' will be applied -->
                <xsl:otherwise>
                    <xsl:message
                        select="'Seems like there are no content templates for **' || ($page/@key, $page/@name)[1] || '**, applyling default content template.'"/>
                    <xsl:apply-templates select="$self[@name = 'default-content']">
                        <xsl:with-param name="context" select="$context" as="xs:string"/>
                        <xsl:with-param name="img-path" select="$img-path" as="xs:string"/>
                        <xsl:with-param name="output-dir" select="$output-dir" as="xs:string"/>
                        <xsl:with-param name="page" select="$page" as="element(pages:page)"/>
                        <xsl:with-param name="pages" select="$pages" as="element(pages:pages)"/>
                        <xsl:with-param name="page-title" select="$page-title" as="xs:string"/>
                        <xsl:with-param name="stylesheets" select="$stylesheets" as="xs:string"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:result-document>
    </xsl:template>

    
    <!-- 
        The fallback template, when not specific content-template was
        found.
        
        @param $context The path of the current file to produce.
        @param $img-path The path to the image-folder.
        @param $output-dir The path to the output-dir.
        @param $page The current context as element(pages:page)
        @param $pages The structure of the application as element(pages:pages) 
        @param $page-title The title of the application / the current page.
        @param $stylesheets Path of stylesheets, which should be included from the static folder.
    -->    
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
                <p>Noch kein Inhalt vorhanden für Seite: <xsl:value-of
                        select="($page/@name | $page/@key)[1]"/></p>
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

    <!-- 
        The template for the start-page / index-page.
        
        @param $context The path of the current file to produce.
        @param $img-path The path to the image-folder.
        @param $output-dir The path to the output-dir.
        @param $page The current context as element(pages:page)
        @param $pages The structure of the application as element(pages:pages) 
        @param $page-title The title of the application / the current page.
        @param $stylesheets Path of stylesheets, which should be included from the static folder.
    -->  
    <xsl:template match="xsl:template[@name = 'index']" name="index">
        <xsl:param name="context" as="xs:string"/>
        <xsl:param name="img-path" as="xs:string"/>
        <xsl:param name="output-dir" as="xs:string"/>
        <xsl:param name="page" as="element(pages:page)"/>
        <xsl:param name="pages" as="element(pages:pages)"/>
        <xsl:param name="page-title" as="xs:string"/>
        <xsl:param name="stylesheets" as="xs:string"/>
        <xsl:variable name="default-content" as="element(html:main)">
            <main class="container">
                <h2>
                    <xsl:value-of select="$page-title"/>
                </h2>
                <p>Hier entsteht eine Beschreibung</p>
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

    <!-- 
        Template for birth places.
        
        @param $context The path of the current file to produce.
        @param $data The TEI-XML loaded data.
        @param $img-path The path to the image-folder.
        @param $output-dir The path to the output-dir.
        @param $page The current context as element(pages:page)
        @param $pages The structure of the application as element(pages:pages) 
        @param $page-title The title of the application / the current page.
        @param $stylesheets Path of stylesheets, which should be included from the static folder.
    -->  
    <xsl:template match="xsl:template[@name = 'geburtsorte']" name="geburtsorte">
        <xsl:param name="context" as="xs:string"/>
        <xsl:param name="data" as="map(xs:string, document-node())"/>
        <xsl:param name="img-path" as="xs:string"/>
        <xsl:param name="output-dir" as="xs:string"/>
        <xsl:param name="page" as="element(pages:page)"/>
        <xsl:param name="pages" as="element(pages:pages)"/>
        <xsl:param name="page-title" as="xs:string"/>
        <xsl:param name="stylesheets" as="xs:string"/>
        <xsl:variable name="style-files" as="xs:string+"
            select="($stylesheets, 'https://unpkg.com/leaflet@1.7.1/dist/leaflet.css', 'https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css', 'https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css')"/>
        <!-- ToDo: Needs refinement, at the moment just birth places are
             tagged as a place, but in future versions the approach
             may break / return wrong results -->
        <xsl:variable name="places" as="element(tei:place)+" select="
                map:for-each($data, function ($_, $value) {
                    $value//tei:place[parent::tei:listPlace]
                })"/>
        <xsl:variable name="places-as-map" as="map(*)+">
            <xsl:for-each select="$places[tei:geo]">
                <xsl:variable name="coordinates" as="xs:string+" select="./tei:geo => tokenize(' ')"/>
                <xsl:map>
                    <xsl:map-entry key="'place_id'" select="./@xml:id/data(.)"/>
                    <xsl:map-entry key="'name'" select="./tei:placeName/text()"/>
                    <xsl:map-entry key="'lat'" select="$coordinates[1]"/>
                    <xsl:map-entry key="'long'" select="$coordinates[2]"/>
                </xsl:map>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="leaflet-scripts" as="element(html:script)+">
            <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"/>
            <script src="https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js"/>
        </xsl:variable>
        <xsl:variable name="page-script" as="element(html:script)">
            <script>
                const places = <xsl:value-of select="
                        '[' || string-join(for $p in $places-as-map
                        return
                            serialize($p, map {'method': 'json'}), ',') || ']'"/>;
                
                const map = L.map('map').setView([40.7128, -74.006], 2); // Default view
                
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '© OpenStreetMap contributors',
                }).addTo(map);
                
                const markers = L.markerClusterGroup();
                
                // Function to add markers
                function addMarkers() {
                places.forEach(function (place) {
                const marker = L.marker([place.lat, place.long]);
                marker.bindPopup(`Name: ${place.name} ID: ${place.place_id}`);
                markers.addLayer(marker); // Add the marker to the cluster group
                }
                );
                }
                
                addMarkers();
                
                // Add the marker cluster group to the map
                map.addLayer(markers);
            </script>
        </xsl:variable>
        <xsl:call-template name="html-components:create-page">
            <xsl:with-param name="page-head"
                select="html-components:create-head($page-title, $context, $style-files)"/>
            <xsl:with-param name="nav"
                select="html-components:create-header-with-nav($page-title, $output-dir, $context, $pages)"/>
            <xsl:with-param name="content" as="element(html:main)">
                <main>
                    <header class="container">
                        <h2>
                            <xsl:value-of select="$page/@name"/>
                        </h2>
                    </header>
                    <section class="container-fluid" id="map"/>
                </main>
            </xsl:with-param>
            <xsl:with-param name="footer"
                select="html-components:create-footer($context, $img-path, ($leaflet-scripts, $page-script))"
            />
        </xsl:call-template>
    </xsl:template>

    <!-- 
        Template for list of student.
        
        @param $context The path of the current file to produce.
        @param $data The TEI-XML loaded data.
        @param $img-path The path to the image-folder.
        @param $output-dir The path to the output-dir.
        @param $page The current context as element(pages:page)
        @param $pages The structure of the application as element(pages:pages) 
        @param $page-title The title of the application / the current page.
        @param $stylesheets Path of stylesheets, which should be included from the static folder.
    -->  
    <xsl:template match="xsl:template[@name = 'schueler']" name="schueler">
        <xsl:param name="context" as="xs:string"/>
        <xsl:param name="data" as="map(xs:string, document-node())"/>
        <xsl:param name="img-path" as="xs:string"/>
        <xsl:param name="output-dir" as="xs:string"/>
        <xsl:param name="page" as="element(pages:page)"/>
        <xsl:param name="pages" as="element(pages:pages)"/>
        <xsl:param name="page-title" as="xs:string"/>
        <xsl:param name="stylesheets" as="xs:string"/>
        <xsl:variable name="surnames" as="element(tei:surname)*" select="
                map:for-each($data, function ($_, $value) {
                    $value//tei:persName/tei:surname
                })"/>
        <xsl:variable name="persons-list" as="map(xs:string, map(xs:string, item()))"
            select="persons:generate-list-entries($surnames, $context)"> </xsl:variable>
        <xsl:call-template name="html-components:create-page">
            <xsl:with-param name="page-head"
                select="html-components:create-head($page-title, $context, $stylesheets)"/>
            <xsl:with-param name="nav"
                select="html-components:create-header-with-nav($page-title, $output-dir, $context, $pages)"/>
            <xsl:with-param name="content" as="element(html:main)">
                <main class="container">
                    <h2>Verzeichnis der Schüler</h2>
                    <nav class="index-nav">
                        <ul>
                            <xsl:for-each-group select="$surnames"
                                group-by="substring(., 1, 1) => upper-case()">
                                <xsl:sort select="current-grouping-key()"/>
                                <li title="Gehe zu '{current-grouping-key()}'">
                                    <a href="#{current-grouping-key()}">
                                        <xsl:value-of select="current-grouping-key()"/>
                                    </a>
                                </li>
                            </xsl:for-each-group>
                        </ul>
                    </nav>
                    <section class="list-of-persons">
                        <xsl:for-each-group select="$surnames"
                            group-by="substring(., 1, 1) => upper-case()">
                            <xsl:sort select="current-grouping-key()"/>
                            <h3 class="index-subheader" id="{current-grouping-key()}">
                                <xsl:value-of select="current-grouping-key()"/>
                            </h3>
                            <ul>
                                <xsl:for-each select="current-group()">
                                    <xsl:sort select="."/>
                                    <xsl:sequence select="
                                            map:get(
                                            $persons-list,
                                            generate-id(.)
                                            )
                                            => map:get('entry')"
                                    />
                                </xsl:for-each>
                            </ul>
                        </xsl:for-each-group>
                    </section>
                </main>
            </xsl:with-param>
            <xsl:with-param name="footer"
                select="html-components:create-footer($context, $img-path)"/>
        </xsl:call-template>
        <!-- Create a new subpage for each person -->
        <xsl:for-each select="$persons-list => map:keys()">
            <xsl:call-template name="create-page">
                <xsl:with-param name="context"
                    select="$persons-list => map:get(.) => map:get('file')" as="xs:string"/>
                <xsl:with-param name="data" select="$data" as="map(xs:string, document-node())"/>
                <xsl:with-param name="img-path" select="$img-path" as="xs:string"/>
                <xsl:with-param name="output-dir" select="$output-dir" as="xs:string"/>
                <xsl:with-param name="page" select="$persons-list => map:get(.) => map:get('page')"
                    as="element(pages:page)"/>
                <xsl:with-param name="pages" select="$page/ancestor::pages:pages"
                    as="element(pages:pages)"/>
                <xsl:with-param name="page-title" select="$page-title" as="xs:string"/>
                <xsl:with-param name="stylesheets" select="$stylesheets" as="xs:string"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <!-- 
        Template for student-details.
        
        @param $context The path of the current file to produce.
        @param $data The TEI-XML loaded data.
        @param $img-path The path to the image-folder.
        @param $output-dir The path to the output-dir.
        @param $page The current context as element(pages:page)
        @param $pages The structure of the application as element(pages:pages) 
        @param $page-title The title of the application / the current page.
        @param $stylesheets Path of stylesheets, which should be included from the static folder.
    --> 
    <xsl:template match="xsl:template[@name = 'schueler-details']" name="schueler-details">
        <xsl:param name="context" as="xs:string"/>
        <xsl:param name="data" as="map(xs:string, document-node())"/>
        <xsl:param name="img-path" as="xs:string"/>
        <xsl:param name="output-dir" as="xs:string"/>
        <xsl:param name="page" as="element(pages:page)"/>
        <xsl:param name="pages" as="element(pages:pages)"/>
        <xsl:param name="page-title" as="xs:string"/>
        <xsl:param name="stylesheets" as="xs:string"/>
        <xsl:variable name="surname" as="element(tei:surname)" select="
                map:for-each($data, function ($_, $value) {
                    $value//tei:persName/tei:surname
                })
                => filter(
                function ($i) {
                    generate-id($i) eq $page/@key
                }
                )"/>
        <xsl:variable name="iiif-img-points" as="xs:string"
            select="iiif:get-points-for-cell-or-row($surname/ancestor::tei:cell)"/>
        <xsl:variable name="img-id" as="xs:string"
            select="iiif:find-image-name($surname/ancestor::tei:cell)"/>
        <xsl:variable name="iiif-img-path" as="xs:string"
            select="iiif:create-url($iiif-host, $image-base, $img-id, $iiif-img-points, 'max', 0)"/>
        <xsl:call-template name="html-components:create-page">
            <xsl:with-param name="page-head"
                select="html-components:create-head($page-title, $context, $stylesheets)"/>
            <xsl:with-param name="nav"
                select="html-components:create-header-with-nav($page-title, $output-dir, $context, $pages)"/>
            <xsl:with-param name="content" as="element(html:main)">
                <main class="container">
                    <h2>
                        <xsl:value-of select="$surname/normalize-space()"/>, <xsl:value-of
                            select="$surname/../tei:forename/normalize-space()"/>
                    </h2>
                    <img src="{$iiif-img-path}"/>
                    <section>
                        <h3>Details</h3>
                        <ul>
                            <li>Laufende Nummer: <xsl:value-of
                                    select="normalize-space($surname/ancestor::tei:row/tei:cell[1]/string())"
                                /></li>
                            <li>Mehr Details dann hier ...</li>
                        </ul>
                    </section>
                </main>
            </xsl:with-param>
            <xsl:with-param name="footer"
                select="html-components:create-footer($context, $img-path)"/>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
