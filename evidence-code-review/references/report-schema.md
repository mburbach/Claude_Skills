# Datenstruktur des Berichts

Eine JSON-Datei, aus der `scripts/build_report.py` die Artifact-Seite erzeugt. Dieselbe Struktur dient als Gliederung für die Terminal-Ausgabe.

Alle Texte sind reiner Text, kein HTML und kein Markdown. Das Template setzt sie mit `textContent` ein. Code in Auszügen wird exakt so übernommen, wie er in der Datei steht, einschließlich Einrückung.

## Felder

```json
{
  "meta": {
    "titel": "Review LOGA-Austritte",
    "repo": "beihilfeapiantragservice",
    "branch": "feature/CBD-412-loga-austritte",
    "basis": "develop",
    "datum": "2026-09-23",
    "stufe": "high",
    "ticket": { "key": "CBD-412", "url": "https://.../browse/CBD-412" },
    "mr": { "nr": "187", "url": "https://gitlab.../merge_requests/187" },
    "umfang": { "dateien": 23, "plus": 766, "minus": 41 },
    "urteil": "Überarbeiten",
    "zusammenfassung": "Zwei bis vier Sätze."
  },
  "kontext": {
    "ziel": "Was die Änderung bewirken soll, laut Ticket und MR.",
    "quellen": ["Jira CBD-412", "MR-Beschreibung", "README Abschnitt LOGA"],
    "hinweise": ["MR-Beschreibung war leer"]
  },
  "lauffaehigkeit": {
    "status": "lauffaehig | eingeschraenkt | nicht_lauffaehig",
    "befehl": "./mvnw -B verify",
    "ergebnis": "46 Tests, alle grün, 3 übersprungen",
    "fehler": "Entscheidende Zeilen der Fehlermeldung, sonst leer",
    "ursache": "Umgebung oder Code, mit Begründung",
    "schritte": ["Konkreter Schritt, um es lauffähig zu machen"],
    "testabdeckung": "Welche neuen Klassen von Tests ausgeführt werden und welche nicht"
  },
  "findings": [
    {
      "id": "F1",
      "schwere": "Blocker | Sollte | Nit | Frage",
      "kategorie": "Sicherheit | Korrektheit | Tests | Architektur | Wartbarkeit | Stil",
      "titel": "Ein Satz, der den Mangel benennt",
      "ort": "src/main/java/de/firma/loga/AustrittMapper.java:57",
      "auszuege": [
        {
          "datei": "src/main/java/de/firma/loga/AustrittMapper.java",
          "start": 52,
          "sprache": "java",
          "markiert": [57],
          "code": "exakter Code ab Zeile 52, Zeilen mit \\n getrennt"
        }
      ],
      "warum": "Mechanismus in zwei bis fünf Sätzen.",
      "szenario": "Eingabe oder Zustand, dann das falsche Ergebnis.",
      "gegenprobe": "Was geprüft wurde und was dabei herauskam.",
      "pruefung": {
        "status": "bestaetigt | plausibel",
        "durch": ["selbst", "sonnet", "codex"],
        "notiz": "Abweichende Sicht eines Prüfers, sonst leer"
      },
      "vorschlag": "Konkreter Vorschlag.",
      "vorschlag_code": "Optionaler Code-Schnipsel, sonst leer",
      "quelle": ["eigene Prüfung", "/code-review"]
    }
  ],
  "positiv": [
    { "text": "Personenbezogene Felder werden im Log maskiert", "ort": "src/main/resources/logback-spring.xml:12" }
  ],
  "verworfen": [
    { "titel": "Möglicher NPE bei fehlendem Austrittsgrund", "ort": "AustrittService.java:88", "grund": "DTO ist mit @NotNull validiert, siehe AustrittDto.java:21", "quelle": "/code-review" }
  ],
  "abschluss": {
    "naechste_schritte": ["F1 und F2 vor dem Merge beheben", "Test für Austritt am Monatsletzten ergänzen"]
  }
}
```

## Regeln

- `id` bleibt über Neuveröffentlichungen stabil. Das Artifact speichert den Prüfstatus unter dieser ID.
- `findings` ist nach Schweregrad sortiert (Blocker, Sollte, Frage, Nit) und innerhalb davon nach Kategorie-Priorität (Sicherheit, Korrektheit, Tests, Architektur, Wartbarkeit, Stil).
- `markiert` enthält absolute Zeilennummern der Datei, nicht Positionen im Auszug.
- Leere oder unbekannte Felder als leeren String oder leere Liste angeben, nicht weglassen.
- `ticket`, `mr` dürfen `null` sein.
