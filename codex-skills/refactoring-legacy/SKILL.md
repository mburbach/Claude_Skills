---
name: refactoring-legacy
description: Restrukturiert bestehenden Code ohne Verhaltensänderung. Pinnt das Verhalten zuerst mit Charakterisierungstests fest und baut dann in kleinen grünen Schritten um, ein Commit pro Schritt. Startet nur auf ausdrücklichen Aufruf durch den Nutzer.
---

# Refactoring Legacy Code für Codex

Umbau von bestehendem Code bei unverändertem Verhalten. Für das Aufräumen nach einem neuen Feature ist dieser Skill nicht gedacht. Projektregeln (CLAUDE.md, CONTRIBUTING.md) haben Vorrang.

## Vor Phase 1

- Im Gedächtnis suchen: `am-search "<kurzer Begriff>"` und `am-search -p global "Refactor"`. Mehrere kurze Stichwörter probieren.
- Du analysierst, schneidest die Schritte mit genauen Stellen und Zielform und prüfst die Ergebnisse. Die Umsetzung machst du selbst. Subagenten nutzt du nur, wenn der Nutzer Delegation ausdrücklich verlangt.
- Eigener Branch für das Refactoring. Push und Pull Request (PR) erst nach dem OK des Nutzers.

## Phase 1: Einstieg

- Der Nutzer nennt ein Ziel ("zerlege Klasse X in Y und Z"): springe zu Phase 3 und setze es um.
- Der Nutzer nennt nur Code ("räum Modul X auf"): zuerst Phase 2. Vor der Auswahl des Nutzers wird nichts umgebaut.

## Phase 2: Analysieren

Lies den Code und beurteile ihn mit dem Katalog `../../shared/code-smells.md` (relativ zu diesem Skillordner). Prüfe pro Kandidat Build, Tests und Aufrufer: Testabdeckung und Anzahl der Aufrufer bestimmen das Risiko.

Stelle eine Liste vor, sortiert nach Nutzen zu Risiko. Oben stehen Einträge mit hohem Effekt und niedrigem Risiko (gute Tests, wenige Aufrufer). Pro Eintrag:

- Code Smell und Stelle (Datei, Methode)
- Zielform
- Aufwand
- Risiko und Begründung

Der Nutzer wählt die Einträge aus. Nur diese werden umgebaut.

## Phase 3: Verhalten festpinnen

Kein Umbau ohne Sicherheitsnetz. Prüfe pro gewähltem Eintrag, ob das betroffene Verhalten getestet ist. Wenn nicht, schreibe zuerst Charakterisierungstests, die das heutige Verhalten festhalten, auch wenn es falsch aussieht.

- Gefundene Fehler kommen auf eine Fehlerliste (Stelle, beobachtetes Verhalten, erwartetes Verhalten). Diese Fehler behebst du nicht. Das Verhalten bleibt gleich.
- Ein Test, der eindeutig falsches Verhalten festhält, bekommt einen Kommentar mit Verweis auf seinen Eintrag auf der Fehlerliste.
- Charakterisierungstests bleiben dauerhaft im Repo.
- Fehlt ein Seam für einen Test (z. B. statischer Datenbankzugriff in der Methode), pinne von außen als Golden Master fest. Speichere Ausgabe, HTTP-Antwort oder Datenbankzustand vorher und vergleiche nachher.
- Funktioniert keines von beidem: stoppe und frage den Nutzer im Fließtext, mit einem Vorschlag.

Committe die Tests als eigenen Schritt. Lass sie auf dem unveränderten Code laufen und sieh sie grün, bevor Phase 4 beginnt.

## Phase 4: Kleine Schritte

Zerlege jeden Eintrag in Schritte, die für sich bauen und grün sind. Pro Schritt:

1. Lege die Vorgabe fest: genaue Stellen, Zielform und das Kriterium für fertig "Build und alle Tests grün, Tests unverändert".
2. Prüfe Diff, Build und Tests selbst.
3. Ein Commit pro Schritt.

Ein roter Schritt wird komplett zurückgesetzt und kleiner geschnitten, nicht repariert. Tests, die an Interna gekoppelt sind (z. B. ein Mock einer eigenen Klasse), dürfen nur in einem eigenen Schritt angepasst werden, den du dem Nutzer vorher ankündigst.

### Viele Aufrufer

Expand and Contract: Baue die neue Form neben der alten, ziehe die Aufrufer in Paketen um und entferne die alte Form am Ende. Die Pakete laufen nacheinander, nicht parallel. Jedes Paket endet grün.

## Phase 5: Review

Führe den Skill `evidence-code-review` über den ganzen Branch aus. Fehler daraus kommen auf die Fehlerliste. Code Smells daraus werden nach dem OK des Nutzers zu weiteren Schritten, mit den Regeln aus Phase 4.

## Phase 6: Abschluss

- [ ] Alle gewählten Einträge sind umgesetzt, Build und Tests grün
- [ ] Charakterisierungstests committet, Tests mit falschem Verhalten verweisen auf die Fehlerliste
- [ ] Review erledigt, Befunde auf Fehlerliste und weitere Schritte verteilt
- [ ] Fehlerliste als Ergebnis an den Nutzer übergeben
- [ ] Push und Pull Request (PR) erst nach dem OK des Nutzers
- [ ] Lesson mit `memory_save` gespeichert (`type` = `fact`, `concepts` enthält `lesson`, `project` = `$AGENTMEMORY_PROJECT_NAME` oder Ordnername), Text beginnt mit „Refactoring: “
