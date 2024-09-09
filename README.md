# Maschinenbauschule Elberfeld

Dies ist das Repository für die Digitalisierung, Erschließung, Transkription und ggf. Publikation (kurz:Datafizierung) der Schülerverzeichnisse der Maschinenbauschule Elberfeld, wie sie als Archivalien im Universitätsarchiv Wuppertal vorliegen.

## Zugang zur Transkribus Collection

- die collection ist in der standalone-Version und im Browser (https://app.transkribus.eu/collection/217025) zugänglich
- Für den Zugang zu einer Transkribus Collection braucht man einen Transkribus-Account (denn kriegt man hier => https://readcoop.eu/).
- Die für den Account verwendete Email-Adresse muss einem entsprechend berechtigten Nutzer der Collection mitgeteilt werden.
Für die Collection "Schüler der Maschinenbauschule" sind das:
  - ...
- Letztere können neue Nutzer (die einen Transkribus Account haben) über den "User Manager" mittels Email-Adresse finden und der Collection hinzufügen.

## Generierung der Website / Präsentation

Die [XML-Daten](./data) werden mithilfe von XSLT in eine statische HTML-Ausgabe überführt. Die Transformation kann mit einem XSLT 3.0 kompatiblen Prozessor erfolgen (siehe hierzu u.a. die [Saxon-Doku](https://www.saxonica.com/html/documentation12/using-xsl/xslt30.html)).

### Voraussetzungen

Um die Transformation zu starten, muss auf dem System Java zur Verfügung stehen. Dies ist notwendig, um den XSLT-Prozessor Saxon zu starten. Die passende Version findet sich bspw. auf der [Adoptium-Website](https://adoptium.net/de/).

### 'Händische' Transformation

Die Transformation kann mit dem folgenden Befehl ausgeführt werden:

```bash
lib/saxon/saxon-he-12.4.jar -s:xslt/pages.xml -xsl:xslt/pipeline.xslt base-uri=$(pwd)
```

Der Parameter `base-uri` muss dabei auf das aktuelle Arbeitsverzeichnis gesetzt werden.

### Transformation mit `make` (Mac / Linux)

Sofern `make` installiert ist, kann die Transformation auch mit dem folgenden Befehl ausgeführt werden:

```bash
make html
```

**Achtung**: Wird kein `make` verwendet, muss der Ordner `static` manuell in den Ausgabeordner (`build`) kopiert werden.

### Transformation mithilfe des `.bat`-Skripts (Windows)

Unter Windows kann die Transformation einfach über einen Doppelklick auf die Datei `build.bat` gestartet werden. Dieses ruft das PowerShell-Skript `build.ps1` auf, welches die Transformation durchführt / startet.

### Transformation mit Docker

Es wird empfohlen, die Transformation in einem Docker-Container auszuführen (umgeht Probleme mit Windows-Pfaden und stellt sicher, dass die Transformation auf verschiedenen Systemen konsistent ist). Hierzu kann (sofern Docker vorhanden ist) folgender Befehl verwendet werden:

```bash
docker compose up -d && docker compose exec -it pagebuilder make html
```

## Ansicht der Website

Die generierte Website kann im Browser betrachtet werden, indem die Datei `build/index.html` geöffnet wird. Ein Webserver oder ähnliches ist nicht notwendig.