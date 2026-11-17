# Zweitprüfung und Prüfung einzelner Findings

Gehört zu Schritt 6 von `SKILL.md`. Auslöser und Prüferwahl stehen dort. Hier steht das Wie, lesen sobald eine Zweitprüfung startet oder der Nutzer einzelne Findings nachprüfen lässt.

Bei Ausfall von Codex (nicht installiert, nicht angemeldet, Abbruch, Zeitgrenze) prüft Sonnet nur das betroffene Finding, vermerkt im Bericht als "Codex nicht erreichbar, geprüft durch Sonnet".

Prompt: `../../shared/evidence-code-review/references/verifier-prompt.md`. Er ist bewusst neutral formuliert: Der Prüfer bekommt die Behauptung und die Stelle, aber nicht die eigene Einschätzung, und soll aktiv versuchen, das Finding zu widerlegen.

## Codex

Prompt in eine Datei im Scratchpad schreiben, dann
```bash
timeout 900 codex exec -s read-only --ephemeral --skip-git-repo-check \
  -C "<repo des Findings>" \
  -o "<scratchpad>/codex-F3.md" - < "<scratchpad>/prompt-F3.md" \
  > "<scratchpad>/codex-F3.log" 2>&1
```
immer mit `run_in_background: true`. `-s read-only` ist Pflicht. `-C` zeigt auf das Repository, in dem die markierte Stelle liegt, nicht auf ein Oberverzeichnis mit mehreren Repositories. `--skip-git-repo-check` steht immer dabei. Betrifft ein Finding mehrere Repositories, nennt der Prompt alle absoluten Pfade. Lesen darf Codex im Modus `read-only` auch außerhalb von `-C`.

**Erfolg nicht am Exit-Code ablesen.** Codex beendet sich auch bei Fehlern wie einem fehlenden Git-Verzeichnis mit Exit-Code 0. Ein Lauf gilt nur als erfolgreich, wenn die `-o`-Datei existiert und eine Zeile `URTEIL:` enthält. Sonst die `.log`-Datei lesen, die Ursache beheben und einmal neu starten. Scheitert auch der zweite Lauf, prüft Sonnet dieses Finding.

**Ein Lauf dauert oft mehrere Minuten:**

- **Früh starten.** Einen Kandidaten an Codex geben, sobald die eigene Gegenprobe Zweifel lässt, nicht erst, wenn alle Kandidaten durch sind. Währenddessen mit den übrigen Kandidaten, /code-review und dem Entwurf des Berichts weitermachen.
- **Bündeln.** Kandidaten, die dieselbe Datei oder denselben Aufrufpfad betreffen, in einen Prompt packen.
- **Begrenzt parallel.** Höchstens vier Läufe gleichzeitig. Weitere erst starten, wenn einer fertig ist.
- **Nicht pollen.** Kein `sleep`, keine Schleife. Die Benachrichtigung über das Ende abwarten.
- **Nutzer informieren.** Einmal kurz im Chat sagen, wie viele Codex-Prüfungen laufen und dass das einige Minuten dauert.
- **Zeitgrenze.** `timeout 900` beendet nach 15 Minuten. Exit-Code 124 bedeutet Zeitüberschreitung, dann für dieses Finding Sonnet als Ersatz starten.
- Der Bericht wird erst fertiggestellt, wenn alle gestarteten Prüfungen beendet oder ersetzt sind.

## Sonnet

```
Agent(subagent_type: "general-purpose", model: "sonnet",
      description: "Finding F3 unabhängig prüfen",
      prompt: <ausgefüllter Prompt aus ../../shared/evidence-code-review/references/verifier-prompt.md>)
```
Mehrere Sonnet-Prüfungen parallel in einer einzigen Nachricht starten.

## Urteile zusammenführen

- Eigene Prüfung und Zweitprüfer sagen zutreffend: `bestaetigt`, Prüfer im Feld `durch` eintragen.
- Prüfer widerlegt mit Beleg (Datei und Zeile der Absicherung): selbst nachlesen. Hält der Beleg, `verworfen`. Hält er nicht, bleibt das Finding, und die Gegenposition steht im Feld `notiz`.
- Prüfer ist unentschieden oder die Positionen bleiben widersprüchlich: Finding als [Frage] formulieren und beide Sichtweisen nennen. Nie still fallen lassen.

## Einzelne Findings auf Zuruf prüfen

Sagt der Nutzer nach dem Bericht "prüf F3 nochmal" (dann Codex), "prüf F3 mit Codex" oder "lass F2 und F5 von Sonnet gegenprüfen", genau diesen Ablauf für die genannten IDs ausführen, den Bericht aktualisieren und das Ergebnis in zwei, drei Sätzen im Chat nennen. Beim Artifact dieselbe Datei neu veröffentlichen, damit die URL und der Prüfstatus erhalten bleiben. IDs bleiben stabil.
