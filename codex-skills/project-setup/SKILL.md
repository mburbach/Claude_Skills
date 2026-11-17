---
name: project-setup
description: Richtet ein neues oder bestehendes Projekt nach Martins Standards ein (Coding-Standards, Doku, Architekturentscheidungen, Prüfungen, Continuous Integration, Commit-Format). Startet nur auf ausdrücklichen Aufruf durch den Nutzer.
---

# Project-Setup für Codex

Richte das Projekt so ein, dass jede spätere Sitzung dieselben Standards vorfindet: testgetriebene Entwicklung (Test-driven Development, TDD), sauberer Code, Benennung, Doku, modularer Aufbau, ein einziger Prüfbefehl, Architekturentscheidungen (Architecture Decision Record, ADR), Continuous Integration (CI) und Commit-Format. Der Skill funktioniert für ein neues und für ein bestehendes Projekt. Alles, was dem Nutzer gezeigt wird, und jede Datei, die ins Projekt geschrieben wird, ist deutsch, ohne Gedankenstriche als Satzzeichen und ohne Semikola.

Gemeinsame Dateien liegen relativ zu diesem Skill-Ordner in `../../shared/project-setup/`. Die Vorlagenversion steht in `VERSION` dort.

## Regeln für jeden Lauf

- **Nichts wird überschrieben.** Eine bestehende Datei bleibt, wie sie ist. Jede Änderung an einer bestehenden Datei (ein Plugin in der Build-Datei, eine Verweiszeile in `CLAUDE.md` oder `AGENTS.md`, fehlende Zeilen in `.gitignore`) steht als eigene Zeile im Plan und passiert erst nach der Bestätigung. Es wird nur ergänzt, was fehlt, nichts doppelt.
- **Der bestehende Zustand gewinnt.** Jede Abweichung vom Standard (anderes Build-Werkzeug, anderer Aufbau, anderer Commit-Stil, kein Spring) steht im Plan als `Abweichung, bleibt`. Nur wenn der Nutzer den Standard als Ziel will, wird daraus eine Architekturentscheidung mit Status `vorgeschlagen` in `docs/adr/`, nummeriert nach der höchsten vorhandenen. Kein Massenumbau: kein Verschieben von Paketen, keine Neuformatierung von bestehendem Code. Formatierer laufen nur auf geänderten Dateien, siehe Sprachdatei.
- **Regeln werden kopiert, nicht verlinkt.** Das Projekt bekommt eigene Kopien mit der Markierung `<!-- project-setup Vorlage vN -->` (oder `# project-setup Vorlage vN`) in der ersten Zeile, damit es auch ohne dieses Repo funktioniert.
- **Keine Versionen aus dem Gedächtnis.** Die Sprachdateien enthalten nur Konventionen. Versionen von Frameworks, Werkzeugen und CI-Aktionen recherchierst du beim Lauf selbst (Schritt 3).
- **Die Umgebung des Nutzers bleibt unberührt.** Kann der Build sein Repository nicht erreichen (zum Beispiel ein Spiegelserver in `~/.m2/settings.xml`), meldest du das und führst den Check mit einer temporären Überschreibung aus. Die Einstellungen des Nutzers änderst du nie.
- **Du arbeitest selbst.** Bestandsaufnahme, Versionsrecherche und Anlegen machst du in dieser Sitzung. Subagenten startest du nur, wenn der Nutzer sie ausdrücklich verlangt.

## Schritte

1. **Erkennen.** Lies `.project-setup.yml` im Projektordner. Ist sie vorhanden, ist es ein zweiter Lauf, dann gehst du zu „Zweiter Lauf“. Sonst listest du auf, was schon da ist: Sprach- und Build-Dateien, Build-Hülle (Gradle-Wrapper, Maven-Wrapper oder ähnlich), CI (`.github/workflows`, `.gitlab-ci.yml`, `.forgejo/workflows`), `CLAUDE.md` und `AGENTS.md` (beide sind Projektdateien und zählen gleich), `CODING_STANDARDS.md`, `docs/`, Architekturentscheidungen, Hooks (`.githooks`, `.pre-commit-config.yaml`, `core.hooksPath`), Makefile oder justfile, Renovate oder Dependabot, `.editorconfig`, `.gitignore`, README, Testordner, den Commit-Stil der letzten 20 Commits (ohne Commits: `nicht erkennbar`) und den Hauptzweig (Remote-HEAD, sonst der aktuelle Zweig, sonst `main`). In einem bestehenden Projekt führst du Build und Tests einmal als Ausgangslauf aus. Ein Fehler dort wird gemeldet, und seine Behebung wird eine Zeile im Plan. Du behebst ihn nicht stillschweigend. Ein leerer oder fehlender Ordner bedeutet ein neues Projekt. Bei einem großen bestehenden Projekt liest du die Liste selbst, Bereich für Bereich mit `rg` und `find`, und hältst dich an dieses Berichtsformat.
2. **Fragen in Klartext.** Stelle die Fragen in Runden, höchstens vier pro Runde. Jede Frage nummeriert ihre Optionen und markiert eine Option mit `➡️ Empfehlung:` und einem kurzen Grund. Bei Mehrfachauswahl nennt der Nutzer die Nummern, zum Beispiel „1, 3 und 5“. Jede Frage nimmt auch eine eigene Antwort an („andere“). Frage nur, was die Erkennung nicht als vollständig gefunden hat. Die Fragen:
   - Sprache und CI-Plattform. Nur Sprachen mit einer Datei in `languages/` und Plattformen mit einer Datei in `ci/` sind verfügbar. Nenne die fehlenden, statt etwas zu improvisieren. Passt ein Projekt nur teilweise zu einer Sprachdatei (Java ohne Spring), gilt der Abschnitt `Bestand` dieser Datei.
   - Bausteine (Mehrfachauswahl, auf zwei oder drei Fragen verteilt): `CODING_STANDARDS.md`, Definition of Done, Verweiszeilen in `CLAUDE.md` oder `AGENTS.md`, arc42, Architekturentscheidungen, Commit-Standard, Grunddateien (`.editorconfig`, `.gitignore`, README), einheitliche Befehle (`check`, `test`, `lint`, `format`, `build`), Testgerüst, modularer Aufbau, Pre-Commit-Hook, CI, Abhängigkeitsupdates, Sicherheit (gitleaks, Abhängigkeitsprüfung in der CI) und abschließende Prüfung. Sicherheit und abschließende Prüfung empfiehlst du, die übrigen passen zu dem, was fehlt.
   - Commit-Standard: Kombination (empfohlen, siehe `vorlagen/commit-standards.md`), reine Conventional Commits oder Martins Format ohne Typ. Ticket-Präfix (zum Beispiel `CBD`) und Hinweis auf KI-Unterstützung im Commit: mit Name des Werkzeugs oder keiner.
   - Einheitliche Befehle: justfile, wenn `just` installiert ist und der Nutzer es will, sonst Makefile.
   - Projektname und eine Beschreibung in einem Satz (`{{PROJEKTNAME}}`, `{{BESCHREIBUNG}}`). Bei einem bestehenden Projekt schlägst du beides aus README und Code vor.
   - Fragen aus der Sprachdatei (bei einem neuen Projekt Build-Werkzeug, Gruppe und Paketname) und aus der CI-Datei (zum Beispiel Dependency Review in einem privaten Repository).
3. **Versionen recherchieren.** Für alles, was der Plan installiert oder festlegt, suchst du die Version selbst in der Quelle (Maven Central, GitHub-Releases, Registry oder Dokumentation). Nur stabile Releases, keine Betas, Release Candidates, Milestones oder Snapshots, auch wenn eine Registry sie als `latest` führt. Prüfe, dass jede Version an der Stelle auflöst, an der sie verwendet wird. Gib pro Version eine Zeile aus: `Name | Version | Quelle (URL)`. Findest du keine Quelle, steht `unbelegt`, nie eine geratene Version.
4. **Plan zeigen.** Als Tabelle mit den Spalten Datei oder Schritt, Zielpfad und Status. Der Status ist `neu`, `vorhanden, bleibt`, `Änderung an Bestand` oder `Abweichung, bleibt`. Bei einer Abweichung, die zum Ziel werden soll, verweist die Zeile auf die Architekturentscheidung. Warte auf die Bestätigung. Änderungen am Plan gehen zurück zu Schritt 2.
5. **Anlegen.**
   - Neues Projekt: zuerst der Startbefehl und die Folgeschritte aus der Sprachdatei, einschließlich eines Formatierungslaufs.
   - Bestehendes Projekt: die Schritte des Abschnitts `Bestand` in der Sprachdatei, zum Beispiel eine fehlende Build-Hülle nachrüsten.
   - Vorlagen aus `vorlagen/` an die Zielpfade unten, jeder Platzhalter gefüllt. Beispielzeilen mit den Fachbegriffen `Antrag` und `Mandant` (Glossar in `architektur.md`) ersetzt du durch Begriffe des Projekts. Die Benennungsbeispiele in `CODING_STANDARDS.md` bleiben, sie erklären die Regel. Ein Platzhalter ohne Wert ist eine Frage an den Nutzer, kein leerer Text. Sprachteile kommen aus der Sprachdatei, die CI aus `ci/<Plattform>.md`.
   - `commit-standards.md` wird nicht kopiert: Die gewählte Variante kommt ohne ihre Überschrift in `{{COMMIT_STANDARD}}`, mit dem Ticket-Präfix auch im Beispiel (`CBD` ist dort nur ein Beispiel). Der Abschnitt zum Hinweis auf KI-Unterstützung wird nur angehängt, wenn der Hinweis nicht „keiner“ ist.
   - Hook aktivieren (`make hooks` oder `just hooks`). Der Hook braucht `gitleaks`. Fehlt es, nennst du das im Bericht.
   - `.project-setup.yml` schreiben, mit jeder aus einer Vorlage erzeugten Datei und ihrer Version.
6. **Prüfen.** `check` läuft grün. Dann der erste Test aus der Sprachdatei: schreiben, rot laufen lassen und mit dem kleinsten Code grün machen. Bei einem bestehenden Projekt fragst du nach einem kleinen Verhalten, das so getestet wird. Nennt der Nutzer keins, meldest du, dass die bestehenden Tests grün laufen, und der rote Schritt entfällt. Melde jeden Lauf mit Befehl und Ergebniszeile. Ein fehlschlagender Check wird behoben oder gemeldet, nie übersprungen.
7. **Bericht** auf Deutsch: angelegte Dateien, geänderte Bestandsdateien, behaltene Bestandsdateien, Abweichungen und Architekturentscheidungen, Versionen mit Quelle, fehlende Werkzeuge wie `gitleaks`, offene Punkte. Committe nicht, außer der Nutzer bittet darum. Biete den Commit mit dem gewählten Commit-Standard an.

## Zweiter Lauf

Vergleiche die Projektkopien mit den Vorlagen der aktuellen `VERSION`. Zeige pro Datei einen von drei Fällen: unverändert, vom Projekt geändert (bleibt, das Projekt gewinnt) oder Vorlage ist neuer (zeige den Diff der Vorlagenänderung und biete das Übernehmen an). Biete Bausteine an, die beim ersten Lauf nicht gewählt wurden. Danach machst du mit Schritt 4 weiter. Die Version in `.project-setup.yml` ändert sich nur für übernommene Dateien.

## Dateien und Zielpfade

- `languages/<Sprache>.md`: Erkennung, Fragen, Startbefehl, Bestand, Werkzeuge, Befehle, Regeln, Aufbau, erster Test.
- `ci/<Plattform>.md`: Pipeline, Sicherheitsjobs, Abhängigkeitsupdates.
- `vorlagen/` in das Projekt:

| Vorlage | Ziel |
| --- | --- |
| `CODING_STANDARDS.md`, `CLAUDE.md`, `AGENTS.md`, `README.md`, `Makefile` oder `justfile` | Projektwurzel, gleicher Name |
| `definition-of-done.md`, `architektur.md` | `docs/` |
| `adr/*` | `docs/adr/` |
| `editorconfig` | `.editorconfig` |
| `githooks-pre-commit` | `.githooks/pre-commit`, ausführbar |
| `project-setup.yml` | `.project-setup.yml` |
| `<Sprache>/*`, zum Beispiel `java/checkstyle.xml` | wie in der Sprachdatei benannt, zum Beispiel `config/checkstyle/checkstyle.xml` |

Nicht aus dem Dialog gefüllte Platzhalter: `{{VORLAGENVERSION}}` aus `VERSION`, `{{DATUM}}` mit dem heutigen Datum, `{{CMD_*}}`, `{{SPRACHREGELN}}` und `{{VORAUSSETZUNGEN}}` aus der Sprachdatei. `{{SPRACHE}}` und `{{CI_PLATTFORM}}` sind die Dateinamen ohne `.md`, zum Beispiel `java-spring` und `github-actions`. `{{COMMIT_VARIANTE}}` ist `kombination`, `conventional` oder `ohne_typ`.

`{{BAUSTEINE}}` ist eine YAML-Liste (YAML Ain't Markup Language) mit genau diesen Namen: `coding_standards`, `definition_of_done`, `agent_zeiger`, `arc42`, `adr`, `commit_standard`, `basisdateien`, `befehle`, `testgeruest`, `modulstruktur`, `pre_commit`, `ci`, `abhaengigkeiten`, `sicherheit`, `abschlusspruefung`. Die Namen ändern sich nicht. `{{DATEIEN}}` ordnet jeden Zielpfad, der aus einer Vorlage oder einer Referenzdatei entsteht, seiner Version zu, zum Beispiel `.github/workflows/check.yml: 1` für eine Datei aus `ci/github-actions.md`. Geänderte Bestandsdateien und frei geschriebene Dateien (Tests, weitere Architekturentscheidungen) stehen nicht darin.
