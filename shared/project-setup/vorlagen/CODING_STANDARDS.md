<!-- project-setup Vorlage v{{VORLAGENVERSION}} -->
# Coding-Standards für {{PROJEKTNAME}}

## Benennung

- Bezeichner sind englisch, Fachbegriffe deutsch.
- Richtig: `loadAntraegeByMandanten`
- Falsch: `loadApplicationsByClients` (Fachbegriff übersetzt)
- Falsch: `ladeAntraegeNachMandanten` (alles deutsch)
- Umlaute in Bezeichnern als ae, oe, ue, ss schreiben.
- Fachbegriffe stehen im Glossar in `docs/architektur.md`, Abschnitt 12.

## Kommentare

- Kommentare sind deutsch.
- Sie erklären das Warum, nicht das Was.

## Tests

- Jede Änderung kommt mit Tests.
- Der Test kommt zuerst (TDD, Test-getriebene Entwicklung): rot sehen, grün machen, dann aufräumen.
- Mocks nur an Systemgrenzen: Datenbank, HTTP (Hypertext Transfer Protocol), Dateisystem, Uhr.
- Erwartete Werte kommen aus einer unabhängigen Quelle, etwa einer von Hand gerechneten Fachvorgabe. Nie mit dem Code unter Test berechnen.

## Commits

{{COMMIT_STANDARD}}

## Sprachspezifisch

{{SPRACHREGELN}}

## Prüfung

- Regeln, die ein Linter prüfen kann, stehen in der Linter-Konfiguration, nicht hier.
- `{{CMD_CHECK}}` muss vor jedem Push grün sein.

## Definition of Done

Es gilt die Checkliste in `docs/definition-of-done.md`.

## Projektspezifische Regeln

Regeln, die im Review auffallen und kein Werkzeug prüfen kann, kommen hierher.
