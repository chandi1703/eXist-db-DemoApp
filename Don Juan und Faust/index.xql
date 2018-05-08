xquery version "3.0";

(: Angabe des Namespaces für XPath-Ausdrücke TEI :)
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: HTML Ausgabe der XQuery Anfrage :)
declare option exist:serialize "method=xhtml media-type=text/html";

declare variable $page-title := "Don Juan und Faust";
declare variable $author := "Christian Dietrich Grabbe";

(: gibt Zeilen des jeweilig übergebenen Sprechers aus :)
declare function local:getSpeakerLines($speaker as xs:string) {
    let $data := collection('/db/apps/demoApp/data')
    for $document in $data
    return
        <div
            id="text">
            {
                for $speach in $document//tei:sp[tei:speaker = $speaker]//tei:l
                return
                    <p>
                        {$speach}
                    </p>
            }
        </div>
};

let $play-info :=
<plays>
    {
        (: Würde im Falle mehrerer XML Dokumente alle auf einmal einlesen :)
        for $resource in collection('/db/apps/demoApp/data')
        return
            
            (: Speichert Titel und Link zur Ressource im XML-Element plays :)
            <play
                uri="{base-uri($resource)}"
                name="{
                        util:unescape-uri(replace(base-uri($resource),
                        ".+/(.+)$", "$1"), "UTF-8")
                    }">
                {
                    (: XPath Ausdruck, der direkt auf das TEI der Ressource zugreift :)
                    $resource//tei:titleStmt/tei:title/text()
                }
            </play>
    }
</plays>



(: Bis hierher Vorarbeiten. Der Ausdruck "return" gibt nun Dinge zurück, in diesem Fall: Ein html-Dokument :)

return
    <html>
        <head>
            <meta
                HTTP-EQUIV="Content-Type"
                content="text/html; Charset=UTF-8"/>
            
            <!-- Zugriff auf die Variable page-title, welche zu Beginn des Dokuments deklariert wurde -->
            <title>{$page-title}</title>
            
            <link
                rel="stylesheet"
                type="text/css"
                href="resources/css/style.css"/>
        
        </head>
        <body>
            
            <div
                id="pagewrap">
                <!-- Einsetzen von XQuery-Code wird immer mit geschweiften Klammern angezeigt -->
                <h1>{$page-title}</h1>
                <h2>{$author}</h2>
                
                <!-- Anlegen einer unordered list -->
                <ul>
                    {
                        for $play in $play-info/play
                        return
                            (<li>{string($play)}
                                ({string($play/@name)})
                            </li>,
                            <li><a
                                    href="analyzeDon.xq?uri={encode-for-uri($play/@uri)}">Analyse</a></li>)
                    }
                
                </ul>
                
                <div
                    id="box">
                    <div
                        class="left">
                        
                        <h2>
                            Don Juan
                        </h2>
                        
                        {
                            (: Funktion für Don Juan aufrufen :)
                            local:getSpeakerLines("DON JUAN")
                        }
                    </div>
                    <div
                        class="right">
                        
                        <h2>Faust</h2>
                        
                        {
                            (: Funktion für Faust aufrufen :)
                            local:getSpeakerLines("FAUST")
                        }
                    </div>
                </div>
            
            </div>
        </body>
    </html>