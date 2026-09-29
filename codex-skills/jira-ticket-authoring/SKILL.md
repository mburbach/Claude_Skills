---
name: jira-ticket-authoring
description: Draft, review, split, extend, or create Jira epics, tasks, stories, subtasks, and bugs with Martin's internal structure and a strict draft-before-write workflow. Use whenever the user asks to plan, create, revise, or review Jira work, even if Jira or this skill is not named explicitly. Never write to Jira before the user approves the exact proposed content.
---

# Jira Ticket Authoring for Codex

Forme Pläne, Diskussionen und Anforderungen in klar abgegrenzte Jira-Vorgänge um. Entwirf und prüfe den vollständigen Inhalt vor jeder externen Änderung.

## Harte Grenze

Das Erstellen, Ändern, Verlinken und Kommentieren in Jira ist eine sichtbare externe Aktion. Zeige vor jedem Schreibvorgang den exakten Entwurf einschließlich Typ, Parent, Summary, Beschreibung, Labels, Subtasks und Links. Warte auf eine ausdrückliche Freigabe genau dieses Inhalts. Die Zustimmung zu einem allgemeinen Plan ist keine Freigabe der konkreten Tickets.

Ist kein Jira-Connector verfügbar, erstelle und prüfe den Entwurf trotzdem. Behaupte nicht, dass Vorgänge gelesen oder geschrieben wurden.

## Workflow

1. Ermittle Jira-Site, Projekt, Board, Sprache und Teamkonventionen aus Auftrag und Sitzung. Frage nur nach Angaben, die für den konkreten Vorgang fehlen.
2. Recherchiere bei verfügbarem Lesezugriff nach Dubletten, passendem Epic oder Parent, den tatsächlichen Vorgangstypen und den verfügbaren Linktypen. Nimm nicht an, dass ein Subtask überall `Sub-Task` heißt.
3. Entwirf die Vorgänge nach den Vorlagen unten.
4. Prüfe Schnitt, Vollständigkeit, sinnvolle Subtasks sowie Konsistenz und Stil.
5. Zeige Entwurf, Reviewbefunde und echte offene Entscheidungen gesammelt.
6. Schreibe erst nach Freigabe. Lies mindestens den ersten geschriebenen Vorgang zurück und prüfe Formatierung und Felder, bevor du einen größeren Stapel fortsetzt.
7. Melde Schlüssel und Links knapp zurück. Nenne Abweichungen oder Teilerfolge offen.

## Schreibstil

- Schreibe in der Sprache des Teams, sonst in der Sprache des Nutzers.
- Verwende kurze, natürliche Sätze und konkrete Verben.
- Verwende keine Gedankenstriche als Satzzeichen und keine Semikola.
- Vermeide Einleitungen wie "Im Rahmen von" und unnötige Metaerklärungen.
- Schreibe ungebräuchliche Abkürzungen beim ersten Auftreten aus. API und URL müssen nicht erklärt werden.
- Nenne jede Information genau einmal. Aufgaben beschreiben Arbeit, Akzeptanzkriterien beschreiben prüfbare Ergebnisse, technische Hinweise enthalten nur nicht offensichtliche Randbedingungen.
- Schreibe keine Jira-Schlüssel oder Aufforderungen wie "siehe Ticket X" in die Beschreibung. Modelliere Beziehungen als Jira-Links und übernimm nötigen Kontext in den aktuellen Vorgang.

## Summary

Die Summary nennt die konkrete Änderung oder das konkrete Fehlverhalten. Sie ist kein Bereichsname, kein Zieltext und keine Umsetzungsliste. Sie muss allein verständlich sein und darf nicht auf ein anderes Ticket verweisen.

Gute Formen sind zum Beispiel `LOGA-Austritte automatisch verarbeiten`, `Import zeigt bei leerer Datei keinen Fehler` oder `Berechtigungsprüfung für Export ergänzen`.

## Vorlagen

### Task oder Story

```text
Ziel
<Ein bis drei Sätze zum erreichten Zustand und Nutzen>

Kontext
<Nur nötige Ausgangslage und Randbedingungen>

Aufgaben
• <konkrete Arbeit>
• <konkrete Arbeit>

Akzeptanzkriterien
• <beobachtbares Ergebnis>
• <beobachtbares Ergebnis>

Technische Hinweise
• <nur nicht offensichtliche technische Vorgaben>
```

Lasse leere optionale Abschnitte weg. Verwende wenige echte Akzeptanzkriterien, meist zwei bis fünf. Standardarbeit aus der Definition of Done, Umsetzungsschritte und Wiederholungen gehören nicht hinein.

### Bug

```text
Fehlerbild
<Was tatsächlich geschieht>

Erwartetes Verhalten
<Was stattdessen geschehen soll>

Reproduktion
1. <Schritt>
2. <Schritt>

Auswirkung
<Betroffene Nutzer, Daten oder Abläufe>

Technische Hinweise
• <Belege, Logs oder vermutete Stelle, klar als Vermutung markiert>

Akzeptanzkriterien
• <beobachtbarer Nachweis der Korrektur>
```

Erfinde keine Reproduktionsschritte oder technischen Ursachen. Markiere fehlende Angaben als offen.

## Review vor der Freigabe

### Schnitt

Prüfe, ob ein Vorgang mehrere unabhängig lieferbare Ergebnisse bündelt. Ein Split ist sinnvoll, wenn Teile getrennt testbar, ausrollbar oder parallel bearbeitbar sind oder unterschiedliche Verantwortliche und Risiken haben. Splitte nicht nur nach technischen Schichten und nicht, wenn die Teile allein keinen Nutzen haben.

### Vollständigkeit

Vergleiche Entwurf und Ausgangsmaterial. Prüfe nur soweit relevant: Tests, Migration, Konfiguration, Berechtigungen, Fehlerfall, Logging und Monitoring, Dokumentation, Kompatibilität, Rollout und Rollback, Übersetzungen, Löschfristen und Datenschutz. Jede Aufgabe muss zum Ziel gehören. Jedes Akzeptanzkriterium braucht eine passende Aufgabe.

### Subtasks

Schlage Subtasks vor, wenn interne Reihenfolge, parallele Bearbeitung, eigener Review oder ein langer und sonst unsichtbarer Fortschritt es rechtfertigen. Spiegle nicht einfach jede Aufgabenzeile als Subtask. Gib für jeden Vorschlag Summary und einen Satz Umfang an.

### Konsistenz

Prüfe Übereinstimmung von Ziel, Aufgaben, Akzeptanzkriterien, Summary, Typ, Parent und Labels. Mehr als fünf Akzeptanzkriterien ist ein Warnsignal für Wiederholung oder einen zu großen Vorgang. Prüfe, ob Beziehungen besser als Jira-Link statt im Text dargestellt werden.

Zeige nur tatsächliche Befunde:

```text
## Review

**Schnitt:** <Befund und Vorschlag>
**Vollständigkeit:** <fehlender Inhalt>
**Subtasks:** <konkrete Vorschläge>
**Konsistenz:** <Befund>

**Offene Entscheidungen:**
1. <nur echte Entscheidung>
```

Sind alle Prüfungen sauber, sage dies in einem Satz.

## Hierarchie und Links

- Epic: dauerhaftes Thema, kein einzelnes Ergebnis
- Story: nutzerbezogene Funktion, sofern das Projekt diesen Typ verwendet
- Task: klar abgegrenzte Arbeit, die weder Story noch Bug ist
- Bug: fehlerhaftes bestehendes Verhalten
- Subtask: Teil eines Parent-Vorgangs mit dem projektspezifischen Subtask-Typ

Nutze blockierende Links nur bei echter Reihenfolge. Nutze einen allgemeinen Zusammenhang, wenn beide Vorgänge parallel möglich sind. Parent und Child sind Hierarchie und brauchen nicht zusätzlich einen Link.

## Jira-Formatierung

Übermittle Beschreibungen als echten mehrzeiligen Text. Baue keine sichtbaren `\n`-Sequenzen in einen einzeiligen String ein. Prüfe nach dem Schreiben, ob Überschriften, Listen und Absätze korrekt gerendert wurden.
