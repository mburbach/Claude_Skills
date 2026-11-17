---
name: grilling
description: Hartnäckige Befragung in Runden, die einen Plan, eine Entscheidung oder eine Idee prüft, bis jeder Zweig geklärt ist. Startet nur auf ausdrücklichen Aufruf durch den Nutzer.
---

# Grilling für Codex

Befrage den Nutzer hartnäckig, bis ihr ein gemeinsames Verständnis erreicht habt. Angepasst nach Matt Pococks Skill (github.com/mattpocock/skills).

## Entscheidungsbaum und Front

Bilde den Plan als **Entscheidungsbaum** ab: An jeder Entscheidung hängen die Entscheidungen, die von ihr abhängen.

Arbeite den Baum in **Runden** ab. Die **Front** sind alle Entscheidungen, deren Voraussetzungen geklärt sind, also die Fragen, die du jetzt stellen kannst, ohne Antworten zu erraten. Stelle die ganze Front in einer Runde und warte dann auf die Antworten. Hängt eine Frage von einer anderen offenen Frage derselben Runde ab, gehört sie in eine spätere Runde.

Jede Runde Antworten verändert den Baum. Geklärte Entscheidungen schieben die Front weiter. Berechne sie neu und stelle die nächste Runde.

## Format einer Runde

Schreibe ohne Gedankenstriche und ohne Semikola.

```
❓ **F1: <Titel>**
<Frage, gern über mehrere Absätze, mit Optionen>

➡️ Empfehlung: <deine Empfehlung mit kurzem Grund>

---

❓ **F2: <Titel>**
...
```

Formuliere jede Frage so, dass „ja“ deine Empfehlung annimmt. Dann klärt eine kurze Antwort wie „F1 ja, F2 Option B“ die Runde.

## Fakten und Entscheidungen

**Fakten** findest du selbst heraus. Braucht eine Frage der Front einen Fakt aus Code, Dateien oder Werkzeugen, schlage ihn nach, statt den Nutzer zu fragen. Nutze Subagenten nur, wenn der Nutzer Delegation ausdrücklich verlangt.

**Entscheidungen** gehören dem Nutzer. Lege ihm jede vor und warte.

## Abschluss

Die Front ist leer: Jeder Zweig des Baums ist besucht, nichts ist stillschweigend angenommen. Dann:

1. Schreibe die Entscheidungen als nummerierte Liste, je eine Zeile, dazu Punkte, die der Nutzer bewusst offen gelassen hat.
2. Lass den Nutzer bestätigen, dass das euer gemeinsames Verständnis ist. Korrigiere die Liste, bis er zustimmt.
3. Setze den Plan erst um, wenn der Nutzer es sagt.
