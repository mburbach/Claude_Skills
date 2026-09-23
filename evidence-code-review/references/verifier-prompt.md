# Prompt für die Zweitprüfung eines Findings

Gilt für den Sonnet-Subagenten und für Codex gleichermaßen. Platzhalter in spitzen Klammern ausfüllen, sonst nichts ändern. Die eigene Einschätzung (Status, Schweregrad, bisherige Gegenprobe) wird bewusst **nicht** mitgegeben, damit der Prüfer unabhängig urteilt.

Mehrere Findings, die dieselbe Stelle betreffen, dürfen in einen Prompt. Sonst ein Prompt je Finding.

---

Du prüfst eine Behauptung aus einem Code Review unabhängig nach. Du arbeitest nur lesend. Ändere keine Dateien, führe keine Git-Befehle aus, die etwas verändern, und installiere nichts.

Repository: <absoluter Pfad>
Geprüfter Diff: `git diff <basis>...HEAD`
Ziel der Änderung laut Ticket oder MR: <ein bis zwei Sätze, oder "unbekannt">

Behauptung (<Finding-ID>):
<Titel des Findings>

Ort: <pfad:zeile>
Behaupteter Mechanismus: <zwei bis vier Sätze, rein beschreibend, ohne Wertung>
Behauptetes Szenario: <Eingabe oder Zustand, dann das behauptete falsche Ergebnis>

Deine Aufgabe:

1. Lies die genannte Stelle und so viel Umgebung, wie du brauchst. Verfolge Aufrufer und Aufgerufene.
2. Versuche aktiv, die Behauptung zu widerlegen. Suche nach Prüfungen im Aufrufer, Validierungen, Konfigurationswerten, Framework-Verhalten, Tests für genau diesen Fall oder Kommentaren, die das Verhalten als gewollt begründen.
3. Prüfe, ob das Szenario tatsächlich erreichbar ist.

Antworte auf Deutsch in genau diesem Format und mit nichts davor oder danach:

URTEIL: ZUTREFFEND | WIDERLEGT | UNKLAR
BEGRUENDUNG: <drei bis sechs Sätze>
BELEGE:
- <pfad:zeile> <was dort steht und warum es relevant ist>
- <weitere Belege>
OFFEN: <was du nicht klären konntest, oder "nichts">

Ein WIDERLEGT braucht mindestens einen Beleg mit Datei und Zeile, der die Absicherung zeigt. Ohne einen solchen Beleg lautet das Urteil UNKLAR.
