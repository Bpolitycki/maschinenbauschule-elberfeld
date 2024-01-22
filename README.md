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

Die Transformation kann mit dem folgenden Befehl ausgeführt werden:

```bash
saxon -s:data/Abt-1_Tiefbau_Band-1.xml -xsl:xslt/pipeline.xslt base-uri=$(pwd)
```

Der Parameter `base-uri` muss dabei auf das aktuelle Arbeitsverzeichnis gesetzt werden.

Sofern `make` installiert ist, kann die Transformation auch mit dem folgenden Befehl ausgeführt werden:

```bash
make html
```
