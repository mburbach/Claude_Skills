<!-- project-setup Vorlage v{{VORLAGENVERSION}} -->
# Commit-Standards

Der Skill setzt den Abschnitt der gewählten Variante ohne Überschrift in `CODING_STANDARDS.md` ein. Der Abschnitt „KI-Hinweis“ betrifft die Kennzeichnung von KI (Künstliche Intelligenz)-Beiträgen und wird an die Variante angehängt.

## Kombination (empfohlen)

Aufbau:

- Betreff: `<typ>({{TICKET_PRAEFIX}}-<nr>): <Satz>`
- Typen wie bei Conventional Commits: feat, fix, refactor, test, docs, build, ci, chore
- Body: eine Zeile je Änderung, beginnend mit `+` (Neu), `~` (Geändert) oder `-` (Entfernt)
- Optional eine Zeile `Messwert: ...`

Beispiel:

```
fix(CBD-557): Mandantenfilter bei leerer Liste ignorieren

~ Antragsliste filtert eine leere Mandantenliste nicht mehr weg
+ Test für leere Mandantenliste
- Alter Sonderfall im Mandantenfilter entfernt
Messwert: Ladezeit Antragsliste 1,8 s auf 0,4 s
```

## Conventional Commits

Aufbau:

- Betreff: `<typ>(<bereich>): <beschreibung>`
- Typen wie bei Conventional Commits: feat, fix, refactor, test, docs, build, ci, chore
- Body frei formuliert
- Footer `BREAKING CHANGE:` bei Änderungen, die bestehende Aufrufer brechen

Beispiel:

```
feat(antrag): Filter nach Mandanten in der Antragsliste

Die Liste lässt sich nach einem oder mehreren Mandanten filtern.

BREAKING CHANGE: Der Parameter `mandant` heißt jetzt `mandanten`.
```

## Ohne Typ

Aufbau:

- Betreff: `{{TICKET_PRAEFIX}}-<nr>: <Satz>`
- Body wie bei der Kombination, mit Zeilen `+`, `~` und `-` und optional einer Messwert-Zeile

Beispiel:

```
CBD-557: Mandantenfilter bei leerer Liste ignorieren

~ Antragsliste filtert eine leere Mandantenliste nicht mehr weg
+ Test für leere Mandantenliste
```

## KI-Hinweis

Aufbau:

- Ist `{{KI_HINWEIS}}` nicht `keiner`, steht als letzte Zeile der Nachricht ein Trailer (Fußzeile der Commit-Nachricht) `Co-Authored-By: <Werkzeug>`. Der Wert von `{{KI_HINWEIS}}` ist das Werkzeug.
- Ist `{{KI_HINWEIS}}` `keiner`, entfällt der Trailer.
- Der Trailer wird an die gewählte Variante angehängt, nach einer Leerzeile.

Beispiel mit Trailer:

```
fix(CBD-557): Mandantenfilter bei leerer Liste ignorieren

~ Antragsliste filtert eine leere Mandantenliste nicht mehr weg

Co-Authored-By: Claude <noreply@anthropic.com>
```
