---
name: evidence-code-review
description: Review a merge request, pull request, branch, or diff with reproducible evidence, explicit counter-checks, build and test results, and prioritized German findings. Use for requests such as "mach ein Code Review", "reviewe den MR", "prüf die Änderungen gegen develop", or "prüf Finding F3 nochmal". This workflow is read-only unless the user separately asks for fixes or publication.
---

# Evidence Code Review for Codex

Erstelle ein nachvollziehbares Code Review nach Martins Reviewroutine. Ein Finding ist erst fertig, wenn die betroffene Stelle gelesen, der erreichbare Codepfad geprüft, aktiv nach einer Widerlegung gesucht und ein konkretes Fehlerszenario formuliert wurde.

## Grenzen

- Arbeite nur lesend. Ändere, committe und pushe nichts. Implementiere Fixes erst auf einen ausdrücklichen Folgeauftrag.
- Veröffentliche keine Kommentare, Jira-Inhalte oder Statusänderungen ohne Freigabe des exakten Textes.
- Kritisiere den Code, nicht die Person.
- Antworte auf Deutsch. Verwende keine Gedankenstriche als Satzzeichen und keine Semikola. Schreibe ungebräuchliche Abkürzungen bei der ersten Verwendung aus.
- Befolge die Berechtigungs- und Sandboxregeln der aktuellen Codex-Sitzung. Diese Skill-Datei erteilt keine zusätzlichen Rechte.

## Parameter

Ermittle aus dem Auftrag:

- Ziel: Pull Request, Merge Request, Branch oder aktueller Checkout
- Basis: ausdrücklich genannter Branch, sonst `develop`, falls vorhanden, sonst Default-Branch des Remotes
- Tiefe: `high` bei "gründlich", sonst `medium`
- Ausgabe: Markdown im Chat oder eigenständiger HTML-Bericht

Fehlt nur eine unwesentliche Angabe, verwende die genannten Defaults und nenne sie. Frage nur, wenn Ziel oder Basis nicht sicher ermittelbar sind oder die Ausgabeentscheidung das Ergebnis wesentlich verändert.

## 1. Kontext und Umfang

1. Ermittle das Ziel der Änderung aus Ticket, Beschreibung des Pull Requests oder Merge Requests, Commit-Nachrichten und Projektdokumentation.
2. Lies bei verfügbarem Jira- oder Atlassian-Zugriff Beschreibung, Akzeptanzkriterien, Kommentare, Anhänge und relevante Verlinkungen. Fehlt der Zugriff, dokumentiere diese Grenze und arbeite mit lokalen Quellen weiter.
3. Lies `AGENTS.md`, `CLAUDE.md`, README, relevante Dateien unter `docs/` und Architecture Decision Records.
4. Ermittle den exakten Diff mit Merge Base. Wechsle nicht den Checkout des Nutzers. Nutze bei einem anderen Ziel einen temporären Worktree unter `/tmp` und entferne ihn anschließend wieder.
5. Prüfe bei einem übergeordneten Arbeitsverzeichnis alle betroffenen Git-Repositories. Führe Umfang, Basis und Lauffähigkeit je Repository auf.

Erfasse mindestens geänderte Dateien, hinzugefügte und entfernte Zeilen sowie die Commits im Umfang.

## 2. Build, Tests und Lauffähigkeit

Lies zuerst Builddateien, Continuous-Integration-Konfiguration, README, Containerdateien und Beispielkonfiguration. Verwende den dokumentierten Buildbefehl und bevorzuge vorhandene Wrapper.

- Installiere nichts systemweit und erfinde keine Zugangsdaten.
- Starte länger laufende Befehle als fortsetzbare Terminalsitzung und prüfe währenddessen den Diff.
- Eine Container-Laufzeit darf nur gestartet werden, wenn die Sitzung dies erlaubt. Kündige den Zustandswechsel an, protokolliere ihn und stelle den vorherigen Zustand wieder her.
- Gleiche Java-, Laufzeit-, Container- und Continuous-Integration-Versionen ab.
- Suche im gesamten relevanten Bereich nach deaktivierten oder ausgeschlossenen Tests.
- Prüfe für jede neue oder wesentlich geänderte Klasse, ob aussagekräftige Tests sie tatsächlich ausführen.

Ordne das Ergebnis als `lauffaehig`, `eingeschraenkt` oder `nicht_lauffaehig` ein. Nenne exakten Befehl, relevante Ausgabe, Zahl übersprungener Tests, Ursache und konkrete Schritte zur Reproduktion oder Behebung. Ein durch den Diff verursachter Fehlschlag ist zusätzlich ein Finding.

## 3. Diff von außen nach innen lesen

Lies nicht nur Patchzeilen, sondern bei Bedarf die vollständigen Dateien und Aufrufpfade:

1. Konfiguration und Abhängigkeiten
2. Einstiegspunkte wie Controller, Scheduler, Listener und Befehle
3. Kernlogik einschließlich Randfällen, Fehlerpfaden, Transaktionen, Nebenläufigkeit, Zeit und Datum
4. Tests und deren Fähigkeit, die zentrale Änderung tatsächlich zu erkennen

Prüfe in dieser Priorität: Sicherheit, Korrektheit, Tests, Architektur, Wartbarkeit, Stil. Bündele gleichartige Stilprobleme. Prüfe bei neuen oder umbenannten Methoden Sprach- und Projektkonvention sowie die Übereinstimmung von Name, Nebenwirkungen und Verhalten. Frameworkvorgaben und Overrides sind ausgenommen.

## 4. Unabhängiger zweiter Durchgang

Führe nach dem eigenen ersten Durchgang einen zweiten, bewusst unabhängigen Reviewdurchgang aus. Lies die bis dahin notierten Kandidaten erst nach diesem Durchgang erneut und führe Dubletten zusammen.

Nutze Subagenten oder weitere Modelle nur, wenn der Nutzer Delegation ausdrücklich verlangt oder die aktuelle Umgebung dies ausdrücklich vorsieht. Übergib dann ausschließlich Behauptung, Ort, Diff, Ziel und das neutrale Prüfschema aus [`../../shared/evidence-code-review/references/verifier-prompt.md`](../../shared/evidence-code-review/references/verifier-prompt.md). Übergib nicht die eigene Bewertung. Fehlt eine solche Möglichkeit, ist der unabhängige zweite eigene Durchgang ausreichend und wird transparent als solcher bezeichnet.

## 5. Kandidaten verifizieren

Für jeden Kandidaten:

1. Stelle mit Kontext erneut lesen.
2. Aufrufer und Aufgerufene verfolgen.
3. Aktiv nach Widerlegung suchen, darunter Validierung, Vorbedingungen, Defaults, Frameworkverhalten, Tests und dokumentierte Entscheidungen.
4. Ein erreichbares Szenario mit Eingabe oder Zustand und falschem Ergebnis formulieren.
5. Status vergeben:
   - `nachgewiesen`: zusätzlich lokal am laufenden System reproduziert
   - `bestaetigt`: Pfad erreichbar, Gegenprobe ohne Widerlegung
   - `plausibel`: Mechanismus stimmt, aber eine relevante Laufzeitannahme bleibt offen
   - `verworfen`: konkrete Absicherung gefunden

Ein lokaler Laufzeitnachweis darf keine fremden oder produktiven Systeme ansprechen und keine dauerhaften Daten hinterlassen. Beende gestartete Prozesse und dokumentiere Anfrage, Antwort und Aufräumen.

## 6. Findings und Abschluss

Sortiere nach Schweregrad und danach nach Kategorie:

- `[Blocker]`: vor dem Merge zu beheben
- `[Sollte]`: relevant, aber nicht zwingend mergeblockierend
- `[Frage]`: Ziel oder Laufzeitverhalten nicht sicher entscheidbar
- `[Nit]`: gebündelte Kleinigkeit

Jedes Finding enthält stabile ID, Titel, `datei:zeile`, exakte Codeauszüge mit Zeilennummern, Mechanismus, Szenario, Gegenprobe, Prüfstatus, konkrete Empfehlung und Quelle. Verwende keine aus dem Gedächtnis rekonstruierten Auszüge. Nenne zwei bis fünf konkrete positive Punkte nur, wenn tatsächlich belegt.

Schließe mit `Freigeben`, `Freigeben mit Anmerkungen` oder `Überarbeiten`, einer kurzen Zusammenfassung, Zahlen je Schweregrad, Zahl verworfener Kandidaten und nächsten Schritten. Ein offener Blocker bedeutet immer `Überarbeiten`.

## Ausgabe

Für Markdown nutze diese Reihenfolge: Kopf mit Repository, Branch, Basis, Datum, Tiefe und Umfang, Gesamturteil und Zusammenfassung, Kontext, Lauffähigkeit, Findings, Positives, verworfene Kandidaten und Abschluss.

Formatiere jedes Finding so:

````markdown
### F3 [Blocker] Austrittsdatum wird bei Zeitzone UTC um einen Tag verschoben
🔴 Korrektheit · `src/main/java/.../AustrittMapper.java:57` · bestätigt (selbst) · Quelle: eigene Prüfung

```java
55  public Austritt map(LogaRecord r) {
56      Austritt a = new Austritt();
57 >    a.setDatum(r.getTimestamp().toLocalDate());
58      return a;
59  }
```

**Warum ist das ein Problem:** ...
**Szenario:** ...
**Gegenprobe:** ...
**Vorschlag:** ...
````

Markiere die entscheidende Codezeile mit `>`. Setze die Sprache des Codeblocks passend zur Datei.

Für HTML:

1. Lies [`../../shared/evidence-code-review/references/report-schema.md`](../../shared/evidence-code-review/references/report-schema.md).
2. Schreibe die Berichtsdaten unter `/tmp` als JSON.
3. Erzeuge den Bericht mit `python3 ../../shared/evidence-code-review/scripts/build_report.py <review.json> <review.html>`, wobei der Skriptpfad vom Skillverzeichnis aus aufgelöst wird.
4. Gib einen klickbaren Link auf die HTML-Datei aus. Die Seite funktioniert ohne Claude über Browser-Speicher. Eine synchronisierte Artifact-Datenbank steht in Codex nicht automatisch zur Verfügung.

Prüfe auf Zuruf einzelne Finding-IDs erneut. IDs bleiben bei aktualisierten Berichten stabil.
