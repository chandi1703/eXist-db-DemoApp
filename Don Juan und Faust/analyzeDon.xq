xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=xhtml media-type=text/html";
declare variable $page-title as xs:string := "Zahlenmagie";

declare variable $play-uri := "data/donfaust.xml";

declare function local:word-count($elms as element()*) as xs:integer
{
    sum($elms ! count(tokenize(., "\W+")))
};

let $play-document := doc($play-uri)
let $play-title := string($play-document//tei:biblFull//tei:titleStmt/tei:title)
let $speakers := distinct-values($play-document//tei:sp/tei:speaker)
let $all-lines := $play-document//tei:sp//tei:l
let $all-word-count := local:word-count($all-lines)

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
                <h1 style="font-family:serif;">{$page-title}: {$play-title}</h1>
                <p>Total lines: {count($all-lines)}</p>
                <p>Total words: {$all-word-count}</p>
                <p>Total speakers: {count($speakers)}</p>
                <br/>
                <table
                    border="1" style="background:white;margin-bottom:50px;">
                    <tr>
                        <th>Speaker</th>
                        <th>Lines</th>
                        <th>Words</th>
                        <th>Perc</th>
                    </tr>
                    {
                        for $speaker in $speakers
                        
                        (: eq funktioniert nur bei einem Vergleich von einem Wert, gäbe es mehrere Namen, würde das einen Fehler erzeugen :)
                        let $speaker-lines := $play-document//tei:sp[tei:speaker eq $speaker]//tei:l
                        
                        (: Hier erster Funktionsaufruf der obrigen Funktion :)
                        let $speaker-word-count := local:word-count($speaker-lines)
                        
                        (: div für Division :)
                        let $speaker-word-perc := ($speaker-word-count div $all-word-count) * 100
                        order by $speaker
                        return
                            <tr>
                                <td>{$speaker}</td>
                                <td>{count($speaker-lines)}</td>
                                <td>{$speaker-word-count}</td>
                                <td>{format-number($speaker-word-perc, "0.00")}%</td>
                            </tr>
                    }
                </table>
            </div>
        </body>
    </html>