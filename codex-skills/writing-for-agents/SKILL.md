---
name: writing-for-agents
description: Schreibanleitung für Dokumente, die ein Agent liest. Nutzen beim Anlegen, Ändern oder Prüfen eines Skills, einer CLAUDE.md oder AGENTS.md oder einer Doku, auf die eine dieser Dateien verweist.
---

# Schreiben für Agenten

Referenz für jedes Dokument, das ein Agent verbraucht: ein Skill, eine `CLAUDE.md` oder `AGENTS.md`, eine Doku, die über einen Verweis erreicht wird. Angepasst nach Matt Pococks Skill (github.com/mattpocock/skills). Ziel ist ein vorhersagbarer **Prozess**: Der Agent geht bei jedem Lauf denselben Weg.

Ist das Dokument ein Skill, lies zusätzlich `SKILL-MECHANICS.md` in diesem Ordner (Frontmatter, Aufruf, das Claude-Codex-Paar).

## Zwei Lasten

- **Context load** (Kosten im Kontextfenster): Immer geladenes Material, etwa eine Skill-Beschreibung oder jede Zeile einer `CLAUDE.md`, kostet bei jedem Zug Tokens und Aufmerksamkeit, ob es greift oder nicht.
- **Cognitive load** (kognitive Last): Der Mensch muss sich merken, welche Dokumente es gibt und wann man sie braucht. Investiere diese Last dort, wo menschliches Urteil zählt.

Miss vor und nach jeder Änderung: `wc -c SKILL.md` und die Länge der `description`-Zeile.

## Verweise

Ein **Pointer** (Verweis) nennt Material außerhalb des Kontexts und die Bedingung, unter der man es lädt. Eine Skill-Beschreibung ist einer, eine `CLAUDE.md`-Zeile, die ein Dokument nennt, ebenso. Sein Wortlaut entscheidet, wann der Agent das Material erreicht. Schärfe einen schwachen Verweis, bevor du sein Ziel einbettest.

- **Leitwort nach vorn.** Die ersten Wörter lösen den Trigger aus.
- **Ein Trigger pro Zweig.** Ein Zweig ist ein eigener Fall, den das Dokument behandelt. Formulierungen, die denselben Zweig nur umbenennen, sind ein Trigger. Eine zweite Formulierung behältst du nur, wenn der Nutzer wirklich beide schreibt, etwa eine deutsche und eine englische.
- **Streiche Identität, die der Rumpf ohnehin trägt.**

## Hierarchie

Ordne jedes Stück danach, wie dringend der Agent es sofort braucht:

1. **Schritte** im Hauptdokument: was der Agent in welcher Reihenfolge tut.
2. **Referenz** im Hauptdokument: Regeln und Fakten, die bei Bedarf nachgeschlagen werden.
3. **Ausgelagerte Referenz** in einer eigenen Datei hinter einem Verweis, geladen nur, wenn der Verweis greift.

**Branching test** (Verzweigungstest): Was jeder Zweig braucht, steht inline. Was nur manche Zweige brauchen, lagert man aus. **Co-location** (Zusammenlegung): Definition, Regeln und Vorbehalte eines Konzepts stehen unter einer Überschrift. **Sprawl** (Wildwuchs) ist der Fehlerfall: eine Datei so lang, dass die Aufmerksamkeit dünn wird, auch wenn jede Zeile gilt. Abhilfe schaffen Auslagern und Aufteilen nach Zweig.

## Schritte und Abschlusskriterien

Jeder Schritt endet mit einem **Completion criterion** (Abschlusskriterium), das der Agent prüfen kann. Eine vage Grenze ("Verständnis erreicht") lädt zu einem **Premature completion** (vorzeitigen Abschluss) ein, weil die verbleibenden Schritte die Aufmerksamkeit aufs Fertigwerden ziehen. Schärfe zuerst die Grenze. Nur wenn sie unscharf bleibt und du die Hetze siehst, stellst du die späteren Schritte hinter eine echte Kontextgrenze, etwa einen Subagenten oder eine Übergabe. Fordernde Kriterien ("jedes geänderte Modell ist erfasst") treiben die Kleinarbeit an, die "erstelle eine Änderungsliste" nicht anstößt. Die stärksten Kriterien sind prüfbar und vollständig.

Teile ein Dokument nach Abfolge nur, wenn spätere Schritte den Agenten verleiten, den aktuellen zu überhasten.

## Leitwörter

Ein **Leading word** (Leitwort) ist ein knapper Begriff, den das Modell schon kennt (_red_, _tight_, _tracer bullet_, _lesson_). Wiederholt als Token verankert er ein ganzes Verhaltensfeld mit wenigen Tokens. Verdichte einen Dreiklang oder einen umschreibenden Satz zu einem Leitwort: "schnell, deterministisch, wenig Overhead" wird zu einer _tight_-Schleife. Ziehe ein vorhandenes Wort einem neu erfundenen vor.

**Positiv vor negativ.** Ein Verbot bringt das verbotene Verhalten in den Kontext. Nenne das Zielverhalten ("schreibe Kommentare in einer Zeile"). Behalte ein Verbot nur als harte Leitplanke, etwa gegen Änderungen an Live-Systemen, und stelle ihm das positive Ziel zur Seite.

## Entrümpeln

Gehe Satz für Satz durch:

- **Single source of truth** (eine Wahrheitsquelle). Jede Bedeutung lebt an einer Stelle. Ein Claude-Skill und sein Codex-Zwilling teilen Dateien über `shared/<skill>/`, statt Kopien zu führen.
- **Cache** (Kopie, die veralten kann). Eine Zeile, die Konfiguration, `--help`-Ausgabe oder das Verzeichnislayout wiederholt, veraltet. Behalte nur, was Nachschauen nicht findet: die ungeschriebene Konvention, den Grund einer Wahl, die Falle.
- **No-op** (Leerlauf). Ein Satz, den das Modell ohnehin befolgt, ändert nichts. Streiche den ganzen Satz. Ein Leitwort, das zu schwach ist, den Standard zu schlagen (_be thorough_), braucht ein stärkeres Wort (_relentless_).
- **Sediment** (Ablagerung). Streiche Zeilen, die veraltet sind oder nie zur Aufgabe gehörten.

Texte, die der Agent in Martins Namen schreibt, folgen seinem Stil: keine Gedankenstriche als Satztrenner, keine Semikola, Abkürzungen einmal ausgeschrieben.
