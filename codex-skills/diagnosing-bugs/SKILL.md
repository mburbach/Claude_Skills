---
name: diagnosing-bugs
description: Diagnosis loop for hard bugs, errors, failing tests, crashes, flaky behavior and performance regressions where the cause is unclear. Use for "debug das", "warum geht das nicht", "da ist ein Fehler", "der Test schlägt fehl", "das ist langsam geworden", "finde die Ursache". Do NOT use when the cause is already known and only the fix is left.
---

# Fehlersuche für Codex

Disziplin für schwer greifbare Fehler, angepasst nach Matt Pococks Skill (github.com/mattpocock/skills). Überspringe eine Phase nur mit ausdrücklicher Begründung. Nutze Subagenten nur, wenn der Nutzer Delegation ausdrücklich verlangt.

## Geheimnisse schwärzen

Schreibe `<REDACTED>` an die Stelle jedes Geheimnisses in Befehlen, Ausgaben und Artefakten. Schleifen lesen Zugangsdaten aus Umgebungsvariablen. Zitiere aus erfassten Artefakten nur die Zeilen mit dem Signal. Reicht die geschwärzte Ausgabe nicht, sage das und frage nach.

Auf Live-Systemen ändere Instrumentierung oder Konfiguration nur nach ausdrücklicher Freigabe des Nutzers.

## Phase 1: Feedback-Schleife bauen

Das ist der Kern. Ohne ein Signal, das genau bei diesem Fehler rot wird, hilft kein Code lesen. Stelle keine Hypothesen auf, bevor ein Befehl existiert, der mindestens einmal gelaufen ist und folgende Kriterien erfüllt:

- Rot-fähig: Er geht den echten Fehlerpfad und prüft das genaue Symptom des Nutzers. "Läuft ohne Fehler" reicht nicht.
- Deterministisch: Gleiches Ergebnis bei jedem Lauf (bei Flakes: eine feste hohe Reproduktionsrate).
- Schnell: Sekunden, nicht Minuten.
- Vom Agenten ausführbar: ohne Mensch, außer über das HITL-Skript (human in the loop).

Mögliche Schleifen, ungefähr in dieser Reihenfolge:

1. Fehlschlagender Test an einer Naht, die den Fehler erreicht.
2. curl oder HTTP-Skript gegen einen laufenden Dev-Server.
3. CLI-Aufruf mit Fixture, Ausgabe gegen bekannten Snapshot.
4. Headless-Browser-Skript (Playwright, Puppeteer).
5. Replay einer aufgezeichneten Anfrage oder eines Event-Logs.
6. Wegwerf-Harness mit minimalem Systemausschnitt.
7. Property- oder Fuzz-Schleife bei "manchmal falsche Ausgabe".
8. Bisektions-Harness für `git bisect run`.
9. Differenzschleife: alte gegen neue Version oder zwei Konfigurationen.
10. HITL-Skript als letzter Ausweg.

Straffe die Schleife danach: schneller (Setup cachen, Umfang eingrenzen), schärfer (das konkrete Symptom prüfen), deterministischer (Zeit fixieren, Zufall seeden, Netz einfrieren). Bei nicht deterministischen Fehlern erhöhe die Reproduktionsrate: Auslöser 100 Mal wiederholen, parallelisieren, Zeitfenster verengen.

Lässt sich keine Schleife bauen: Stopp, nenne die Versuche und bitte um Zugang zur reproduzierenden Umgebung, ein geschwärztes Artefakt (HAR, Log, Core Dump) oder die Erlaubnis für temporäre Instrumentierung. Keine Hypothesen ohne Schleife.

### HITL-Skript

Interaktive Eingaben laufen nicht in der Shell des Agenten. Kopiere `../../shared/diagnosing-bugs/scripts/hitl-loop.template.sh` (relativ zum Skill-Verzeichnis) an einen Scratch-Ort, passe die Schritte an und bitte den Nutzer, es in seinem eigenen Terminal auszuführen. Die erfassten KEY=VALUE-Zeilen gibt er dir zurück.

## Phase 2: Reproduzieren und minimieren

- Lass die Schleife laufen und beobachte das Rot.
- Prüfe, dass es der vom Nutzer beschriebene Fehler ist, nicht ein benachbarter, und halte das genaue Symptom fest.
- Minimiere: Entferne Eingaben, Aufrufer, Konfiguration, Daten und Schritte einzeln und lasse nach jedem Schnitt neu laufen. Fertig, wenn jedes verbleibende Element tragend ist.

## Phase 3: Hypothesen

Formuliere 3 bis 5 gerankte, falsifizierbare Hypothesen, bevor du eine testest. Format: "Wenn X die Ursache ist, verschwindet der Fehler bei Änderung Y und wird bei Z schlimmer." Ohne Vorhersage verwerfen oder schärfen. Zeige die Liste dem Nutzer vor dem Testen, blockiere aber nicht, wenn er nicht erreichbar ist.

## Phase 4: Instrumentieren

- Jede Sonde gehört zu einer Vorhersage aus Phase 3. Ändere eine Variable nach der anderen.
- Bevorzuge Debugger oder REPL, dann gezielte Logs an den trennenden Grenzen. Nie "alles loggen und greppen".
- Markiere jedes Debug-Log mit einem eindeutigen Präfix wie `[DEBUG-a4f2]`.
- Bei Performance: erst Basismessung (Timing, Profiler, Query-Plan), dann bisektieren.

## Phase 5: Fix und Regressionstest

Schreibe den Regressionstest vor dem Fix, aber nur an einer korrekten Naht, die das echte Fehlermuster an der Aufrufstelle abbildet. Gibt es keine, ist das selbst ein Befund. Halte ihn fest.

1. Minimierten Repro als fehlschlagenden Test schreiben.
2. Rot beobachten (bei erzwungenem Rot per `diff` gegen eine saubere Kopie belegen).
3. Fix umsetzen.
4. Grün beobachten.
5. Phase-1-Schleife am ursprünglichen Szenario erneut laufen lassen.

## Phase 6: Aufräumen

- [ ] Ursprünglicher Repro tritt nicht mehr auf
- [ ] Regressionstest grün oder fehlende Naht dokumentiert
- [ ] Alle `[DEBUG-...]`-Ausgaben entfernt (Präfix greppen)
- [ ] Wegwerf-Prototypen gelöscht
- [ ] Bestätigte Ursache in der Commit- oder PR-Nachricht benannt
