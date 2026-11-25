# Code Smells

Katalog für die Analyse in `refactoring-legacy` und für die Prüfzeile Wartbarkeit in `evidence-code-review`. Ein Code Smell ist ein Urteil und kein Messwert, die Signale in der Spalte Erkennen sind Hinweise und keine Grenzwerte.

| Code Smell | Erkennen | Zielform |
|---|---|---|
| Long Method | Methode passt nicht auf eine Bildschirmseite, mehrere Abschnitte mit Leerzeilen oder Kommentaren als Überschrift | Abschnitte als eigene Methoden mit sprechendem Namen herausziehen (Extract Method) |
| God Class | Klasse mit mehreren unabhängigen Aufgaben, Feldgruppen, die nur je eine Methodengruppe nutzt, Name wie `Manager` oder `Util` | Nach Verantwortung in kleinere Klassen aufteilen, die Ursprungsklasse delegiert oder entfällt |
| Feature Envy | Methode greift überwiegend auf Daten einer fremden Klasse zu, viele Getter-Aufrufe auf dasselbe Fremdobjekt | Methode in die Klasse verschieben, deren Daten sie nutzt (Move Method) |
| Data Clumps | Dieselben zwei bis vier Werte stehen in mehreren Signaturen oder Feldlisten nebeneinander | Werttyp oder Parameterobjekt einführen |
| Primitive Obsession | `String`, `int` oder `Map` trägt Fachbedeutung (Kontonummer, Betrag, Status), Format wird an mehreren Stellen geprüft | Kleiner Werttyp mit eigener Prüfung, Enum für feste Werte |
| Shotgun Surgery | Eine fachliche Änderung erzwingt Edits an vielen Klassen, im Verlauf (`git log`) ändern sich dieselben Dateien immer gemeinsam | Verstreute Logik an einer Stelle bündeln (Move Method, Inline Class) |
| Long Parameter List | Mehr als vier Parameter, Flag-Parameter vom Typ `boolean`, die das Verhalten umschalten | Parameterobjekt, Flag in zwei Methoden aufteilen |
| Duplicated Code | Gleiche oder fast gleiche Blöcke an mindestens zwei Stellen, Fehlerbehebung musste mehrfach eingebaut werden | Gemeinsame Methode oder Basisklasse herausziehen, Unterschiede als Parameter |
| Dead Code | Keine Aufrufer (Suche über das ganze Repo und Reflection prüfen), auskommentierte Blöcke, nie gesetzte Feature-Flags | Löschen, die Versionsverwaltung bewahrt den Stand |
| Hardcoding / Magic Numbers | Literale mit Fachbedeutung (`86400`, `"PROD"`, Webadressen, Pfade) im Code | Benannte Konstante, Konfiguration oder Enum |
| Deep Nesting | Mehr als drei verschachtelte `if` oder Schleifen, Pfeilform im Einzug | Guard Clauses mit frühem Return, innere Blöcke als Methoden |
| Temporal Coupling | Methoden müssen in fester Reihenfolge aufgerufen werden (`init()` vor `run()`), sonst Fehler zur Laufzeit | Reihenfolge im Typsystem erzwingen, etwa Konstruktor oder Builder |
| Hidden Dependency | Statischer Zugriff oder `new` auf Datenbank, Uhr, Dateisystem oder Singleton mitten in der Methode, Test braucht echte Infrastruktur | Abhängigkeit als Parameter oder Konstruktorargument übergeben (Seam schaffen) |
| Switch on Type | Mehrfach wiederholte `switch` oder `if`-Ketten über denselben Typ oder Status | Polymorphie oder Strategie, bei wenigen Fällen ein Enum mit Methode |
| Reinvented Wheel | Eigener Code für etwas, das eine schon eingebundene Bibliothek (Build-Datei wie `pom.xml` oder `package.json` prüfen) oder die Standardbibliothek kann. Gilt auch für Testcode. Typische Zeichen: eigener Leser für HTML, XML, JSON oder CSV mit Schleife über Zeichen, Zustand für Anführungszeichen, `lastIndexOf('<')` oder vielen Regex-Konstanten, dazu Tests, die nur diesen eigenen Leser prüfen. Befunde wie „Schreibweise X wird nicht erkannt“ sind oft nur das Symptom | Durch Aufrufe der vorhandenen Bibliothek ersetzen, zum Beispiel jsoup mit `Parser.xmlParser()` statt eigenem XML-Leser. Abweichungen im Verhalten (dekodierte Entities, Leerzeichen, Fehlerfälle) mit einem Vergleich alt gegen neu sichtbar machen und dem Nutzer vorlegen, nicht durch nachträgliches Umformen der Ausgabe ausgleichen. Eine neue Abhängigkeit nur nach Rückfrage beim Nutzer |
| Comments as Deodorant | Kommentar erklärt, was der Code tut, statt warum | Code durch Umbenennen oder Extract Method selbsterklärend machen, Kommentar auf das Warum kürzen |
