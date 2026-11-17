---
name: retro
description: Rückblick auf eine Coding-Sitzung, der Vorschläge zur Umgebung des Agenten macht, nicht zum Code. Startet nur auf ausdrücklichen Aufruf durch den Nutzer.
---

# Retro für Codex

Schlage Verbesserungen an der **Umgebung** des Agenten vor, damit der nächste Lauf besser wird. Angepasst nach Matt Pococks Skill (github.com/mattpocock/skills). Alles, was dem Nutzer gezeigt wird, ist deutsch, ohne Gedankenstriche als Satzzeichen und ohne Semikola.

Retro ist kein Gedächtnis. Es ändert die Umgebung, damit ein Fehler nicht noch einmal passieren kann. Es schlägt nur vor. Nichts ändert sich, bis der Nutzer auswählt.

## Schritte

1. Lies die Sitzung. Standard ist die aktuelle. Für eine frühere findest du die Sitzungszusammenfassungen über agentmemory (`am-search`). Logs von Claude Code: `~/.claude/projects/<Projektpfad mit Schrägstrichen durch Bindestriche ersetzt>/*.jsonl`. Logs von Codex: `~/.codex/sessions/`. Für ein langes Log gilt die Regel unter „Logs lesen“ weiter unten.
2. Suche in agentmemory nach Lessons zu diesen harten Momenten: `am-search "<Begriff>"` und `am-search -p global "<Begriff>"`, mehrere kurze Begriffe. Lessons erscheinen unter „Lessons“. Eine Lesson, die wiederkehrt oder in dieser Sitzung erneut verletzt wurde, ist ein Kandidat für eine dauerhafte Lösung.
3. Sammle Kandidaten aus den Kategorien unten. Jeder braucht einen nachprüfbaren Moment in der Sitzung. Ohne Moment kein Kandidat. Eine reibungslose Sitzung hat wenig zu lehren. Sag das und hör dann auf.
4. Lade `writing-for-agents` erst, wenn ein Kandidat Steuertext schreibt.
5. Stelle die Kandidaten vor und warte auf die Auswahl.
6. Setze die gewählten um. Subagenten nutzt du nur, wenn der Nutzer Delegation ausdrücklich verlangt.

## Logs lesen

Ein langes Log liest du in Teilen. Mit `rg` suchst du nach Fehlern, Wiederholungen (Retries) und Korrekturen des Nutzers. Du meldest nur die harten Momente, jeweils mit Zeitstempel und einem kurzen Zitat. Das ganze Log gibst du nie aus.

## Kategorien

- **Navigation**: Der Agent brauchte lange, um eine Datei oder einen Fakt zu finden. Lösung: ein **Navigationszeiger** aus einer Datei, die der Agent ohnehin liest. _Gilt, wenn_ die Sitzung lange gebraucht hat, um eine Information zu finden.
- **Automatische Prüfungen**: Eine Lint-Regel, Typprüfung, ein Test, Hook oder Continuous-Integration-Job (CI) hätte den Fehler finden können. Lies zuerst den Prüfbefehl und die CI des Repos, damit eine vorhandene, aber nicht verdrahtete oder kaputte Prüfung der Fund ist. Ein fehlender Schutz (kein Pre-Commit-Hook und keine CI mit Lint, Typprüfung und Tests) ist nur ein Fund, wenn die Sitzung zeigt, dass eine solche Prüfung den Fehler gefangen hätte. _Gilt, wenn_ der Agent einen Fehler gemacht hat, den eine automatische Prüfung hätte finden können.
- **Coding-Standards**: Der Reviewer hat etwas übersehen. Zuerst einordnen. Ein **mechanischer** Verstoß (festes Muster, verbotene API, Import-Form, Dateiort) bekommt eine deterministische Prüfung, keine Regel. Ein **Ermessensfall** (Konsistenz über Dateien hinweg, passender Stil zur Umgebung) wird eine Regel in `CODING_STANDARDS.md`. _Gilt, wenn_ der Reviewer einen Fehler nicht gefangen hat.
- **Globale AGENTS.md**: Steuertext, der in Coding-Standards oder Prüfungen gehört. _Gilt, wenn_ eine AGENTS.md groß ist, im Projekt oder global.
- **Werkzeugökonomie**: Teure Werkzeugaufrufe, token-hungrige Kommandozeilenprogramme oder Model Context Protocol (MCP)-Server. _Gilt, wenn_ der Agent einen teuren Werkzeugaufruf gemacht hat.
- **Leerlauf**: Steuerzeilen, die kein Verhalten ändern. _Gilt, wenn_ Steuerdateien groß und unhandlich sind.
- **Informationszugang**: Logs, Lesezugriff auf Dienste. _Gilt, wenn_ eine wichtige Information nicht verfügbar war.
- **Modellwahl und Kosten**: falsches Modell, zu viele Subagenten. Ziel ist meist die Delegationsregel in der AGENTS.md.
- **Gedächtnis**: Hat der Agent vor dem Start gesucht? Hat er etwas wiederholt oder erneut gefragt, das schon gespeichert war?
- **Freigabe-Abfragen**: viele Freigaben. Ziel ist `~/.codex/config.toml`.

## Ebenen

Wähle die niedrigste passende Ebene. Eine Prüfung, die fehlschlägt, ist besser als ein Satz in einer Datei.

1. **Projekt**: die `AGENTS.md` des Projekts (nur Navigationszeiger), Prüfungen, Hooks, Doku, `CODING_STANDARDS.md`.
2. **Global**: `~/.codex/AGENTS.md`, `~/.codex/config.toml`. Für Claude Code gelten `~/.claude/CLAUDE.md` und `~/.claude/settings.json`.
3. **Unsere Skills**: Repo `Claude_Skills`.
4. **Gedächtnis**: letzter Ausweg. Eine neue Lesson nur vorschlagen, wenn keine Umgebungsänderung passt.

## Ausgabe

Kandidaten K1, K2, ... Sortiert nach Häufigkeit (in der Sitzung und in Lessons), dann nach Schaden (ein falsches Ergebnis vor Zeit und Tokens, Zeit und Tokens vor Komfort). Jeder Kandidat auf Deutsch mit: Stelle in der Session, Ebene, Zieldatei, Änderung, Begründung für den Rang. Ersetzt eine Änderung eine Lesson, löst derselbe Kandidat sie ab. Dann wählt der Nutzer, zum Beispiel „K1 und K3“.

## Umsetzen

- **Standards gehören zum Reviewer.** Der umsetzende Agent steht am stärksten unter Kontextdruck, der Reviewer bekommt einen Diff. `CODING_STANDARDS.md` ist pro Projekt und wird erst angelegt, wenn die erste Reviewer-Regel existiert. Der Skill `evidence-code-review` liest sie, wenn sie vorhanden ist. Die Projekt-AGENTS.md lädt jede Sitzung, deshalb enthält sie nur Navigationszeiger.
- **Ebene 1**: Ändere die Projektdateien.
- **Ebene 2, Codex**: `~/.codex/AGENTS.md` und `~/.codex/config.toml` sind noch nicht versioniert. Lege vor jeder Änderung eine datierte Sicherungskopie neben die Datei an, `<datei>.bak-JJJJ-MM-TT`, zum Beispiel `cp ~/.codex/AGENTS.md ~/.codex/AGENTS.md.bak-JJJJ-MM-TT`. Dann die Entscheidung mit `memory_save` speichern, `type` = `decision`, `project` = `global`.
- **Ebene 2, Claude Code**: `~/.claude` ist ein privates Git-Repo (`claude-global`, nur freigegebene Dateien werden verfolgt). Ändere die Datei, dann `git -C ~/.claude commit` direkt auf main mit einer Nachricht, die Was, Warum und Herkunft (Projekt und Sitzung) nennt, danach `git -C ~/.claude push`. Außerdem `memory_save` mit `type` = `decision`, `project` = `global`. Ein Pre-Commit-Hook prüft auf Secrets. Blockiert er, stoppe und sag es dem Nutzer.
- **Ebene 3**: Prüfe im Repo `Claude_Skills` zuerst `.out-of-scope/`, ändere den Skill auf einem Branch und öffne einen Pull Request (PR). Außerhalb des Repos ändere keine Skills. Ein Ticket legst du mit `../../shared/retro/scripts/vikunja-ticket.sh` an (relativ zu diesem Skill-Ordner, separat angelegt). Führe zuerst `find TERM` aus (offene Tickets: id, identifier, title). Bei einem Treffer nimm `comment TASK_ID FILE` statt eines Dubletts. Sonst `create TITLE FILE` (Markdown-Datei oder `-` für stdin, Projekt „Claude Skills“, Label `retro`). `done TASK_ID` schließt ein Ticket. Ticketinhalt: Projektordner, Moment in der Sitzung, Zieldatei, vorgeschlagene Änderung, Begründung.
- **Lesson ablösen**: agentmemory kennt kein Löschen. Speichere eine Notiz mit `memory_save`, `type` = `fact`, `concepts` mit `abgelöst`, und nenne die ID der Lesson und die Änderung, die sie ersetzt. Die alte Lesson verblasst dann.
