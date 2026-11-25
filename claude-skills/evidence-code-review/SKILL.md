---
name: evidence-code-review
description: Full code review of a merge request, pull request, branch or diff in Martin's own review routine (Kontext, Überblick mit Build und Tests, Diff von außen nach innen, Checkliste, [Blocker]/[Sollte]/[Nit]/[Frage]). Uses the built-in /code-review skill (medium or high) as an additional finding source and verifies every finding against the code to rule out false alarms, with a second opinion from Codex (Sonnet subagent only on request or as fallback). Each finding has file and line, code excerpt, mechanism, counter-check and suggestion. Reports whether the application builds and runs. Output in the terminal or as Artifact with checkboxes. Use this whenever the user asks for a review of a branch, MR, PR or diff, e.g. "mach ein Code Review", "reviewe den MR", "review PR 12", "schau dir den Branch an", "prüf die Änderungen gegen develop", "Review mit Belegen", or to re-check single findings ("prüf Finding F3 nochmal mit Codex"). Prefer this over calling /code-review directly unless the user explicitly wants only the bare /code-review output.
---

# Evidence Code Review

Ein Review nach Martins eigenem Ablauf. Das Ergebnis muss sich nachprüfen lassen. Jedes Finding bringt deshalb den Code mit, auf den es sich bezieht, erklärt den Mechanismus und sagt, was getan wurde, um einen Fehlalarm auszuschließen. Ein Finding, das der Leser erst selbst im Repository suchen muss, um es zu verstehen, ist nicht fertig.

## Wozu es diesen Skill gibt

1. **Fehlalarme.** Automatische Reviews melden Dinge, die an anderer Stelle längst abgefangen werden. Jeder Kandidat durchläuft deshalb eine Gegenprobe, und im Zweifel prüft ein zweites Modell unabhängig nach.
2. **Nicht nachvollziehbare Findings.** "Möglicher NPE (NullPointerException) in Zeile 212" hilft niemandem. Gebraucht werden der Code, der Pfad dorthin und ein konkretes Szenario.
3. **Grüne Tests als falsche Sicherheit.** Alle Tests grün sagt nichts über neuen Code, der gar nicht getestet wird.
4. **Stille Annahmen über Lauffähigkeit.** Wenn Build oder Tests nicht laufen, steht das im Bericht, mit Ursache und dem Weg, wie es läuft.

## Grundregeln

- **Nur lesen.** Der Skill ändert keine Dateien im Repository, committet nicht und pusht nicht. Fixes nur, wenn der Nutzer das nach dem Bericht ausdrücklich will.
- **Nichts nach außen ohne Bestätigung.** Kommentare im MR, Jira-Kommentare oder Statuswechsel erst nach Freigabe genau dieses Inhalts.
- **Ein Finding erst nach echter Code-Lektüre.** Nie aufgrund von Dateinamen, Methodennamen oder Vermutungen.
- **Bewusste Entscheidungen sind kein Finding.** Weicht der Code erkennbar mit Absicht von einer Best Practice ab (Kommentar, Doku, einheitlich im ganzen Projekt), ist das höchstens eine [Frage].
- **Den Code kritisieren, nicht die Person.** "Hier wird X nie aufgerufen, weil ..." statt "Du hast vergessen ...".
- **Fragen statt behaupten, wenn unsicher.** Besonders bei fremdem Code und Fachlogik.
- **Schreibstil.** Deutsch, auch in Statusmeldungen während des Laufs. Keine Gedankenstriche als Satzzeichen, keine Semikola, in **jeder** Ausgabe (Chat, Bericht, Kommentarvorschläge). Vor jeder Meldung auf `—`, `–`, ` - ` und `;` prüfen und den Satz umbauen, statt nur das Zeichen zu tauschen: "Ich starte den Socket. Das lässt sich rückgängig machen". Fachliche und technische Abkürzungen bei der ersten Nennung einmal ausschreiben, zum Beispiel "DSGVO (Datenschutz-Grundverordnung)". Gängige Kürzel wie API oder URL ausgenommen.

## Schritt 0: Parameter klären

| Parameter | Werte | Erkennbar an |
|---|---|---|
| Stufe für /code-review | `medium`, `high` | "medium", "high", "gründlich" (= high), "schnell" (= medium) |
| Ausgabe | `artifact`, `terminal` | "Artifact", "als Seite", "mit Checkboxen", "hier", "im Terminal" |

Was im Aufruf nicht eindeutig steht, fragt der Skill **gesammelt in einem einzigen AskUserQuestion-Aufruf** ab (eine oder zwei Fragen, nie zwei Runden). Was angegeben ist, wird nicht gefragt.

- Stufe: Option "high (Empfohlen)" mit dem Hinweis, dass high mehr unsichere Kandidaten liefert, die in der Verifikation aussortiert werden. Option "medium" für wenige, sichere Findings.
- Ausgabe: "Artifact mit Checkboxen" und "Hier im Terminal".

Optional im Aufruf, ohne Rückfrage:

- **Zweitprüfer:** "mit Sonnet", "beide", "ohne Zweitprüfung". Ohne Angabe prüft Codex.
- **Basis-Branch:** "gegen main". Ohne Angabe `develop`, falls vorhanden, sonst der Default-Branch des Remotes (`git symbolic-ref refs/remotes/origin/HEAD`). Nur wenn beides nicht ermittelbar ist, fragen.
- **Ziel:** MR-Nummer, Branch oder Pfad. Ohne Angabe der aktuelle Branch.

Fertig, wenn Stufe, Ausgabe, Basis und Ziel feststehen.

## Schritt 1: Kontext klären

Ohne Ziel lässt sich nur Stil prüfen, keine Korrektheit. Zuerst verstehen, was die Änderung bewirken soll.

1. **Ticket.** Jira-Key aus Branchname, Commit-Nachrichten oder MR-Titel ziehen (Muster `[A-Z][A-Z0-9]+-\d+`) und über das Atlassian-MCP vollständig lesen:
   - Beschreibung, Akzeptanzkriterien und verlinkte Tickets,
   - **alle Kommentare**, denn dort stehen oft spätere Entscheidungen, die die Beschreibung überholen,
   - **Anhänge und eingebettete Bilder**, besonders Schaubilder zu Abläufen, Architektur oder Oberflächen. Bilder herunterladen und ansehen, nicht nur den Dateinamen notieren,
   - verlinkte Confluence-Seiten, soweit sie den geänderten Bereich betreffen.

   Widersprechen sich Beschreibung, Kommentare und Schaubilder, gilt der neueste Stand. Der Widerspruch gehört als Hinweis in den Kontext des Berichts. Weicht der Code von einem Schaubild ab, ist das ein Kandidat der Kategorie Architektur oder Korrektheit.
2. **MR-Beschreibung.** GitLab: `glab mr view <nr>` oder `glab mr view` für den aktuellen Branch. GitHub: `gh pr view`. Ist kein CLI eingerichtet, weitermachen und im Bericht vermerken, dass die Beschreibung fehlte.
3. **Projektdoku.** README, CLAUDE.md, AGENTS.md, CONTRIBUTING.md, CODING_STANDARDS.md (wenn vorhanden, immer), `docs/` und ADRs (Architecture Decision Records), soweit sie den geänderten Bereich betreffen.
4. **Umfang.** `git fetch` ist erlaubt, es ändert nur Remote-Referenzen. Ist der Feature-Branch schon in einen anderen Branch gemergt (etwa `test`), als Basis den Abzweigpunkt nehmen (`git merge-base`), damit genau die Commits der Story im Diff stehen, und das im Kontext des Berichts vermerken. Dann:
   ```bash
   git diff <basis>...HEAD --stat
   git diff <basis>...HEAD --shortstat
   git log --oneline <basis>..HEAD
   ```
   Anzahl Dateien, hinzugefügte und entfernte Zeilen stehen später im Kopf des Berichts. Lässt sich die Basis nicht auflösen oder ist der Diff leer, hier abbrechen und nachfragen, bevor Build, /code-review oder Prüfer starten.
5. **Mehrere Repositories.** Liegt das Arbeitsverzeichnis über mehreren Git-Repositories (etwa Hauptanwendung und Microservices), alle suchen, in denen der Feature-Branch existiert (`git -C <repo> rev-parse --verify <branch>`), und den Diff je Repository einzeln ermitteln. Der Basis-Branch kann je Repository verschieden sein. Der Bericht nennt Umfang und Lauffähigkeit je Repository, und jeder Ort beginnt mit dem Repository-Namen, zum Beispiel `beihilfeapigateway/src/main/java/.../JwtFilter.java:42`. Auf Brüche zwischen den Repositories achten: ein entfernter Endpunkt, den ein anderes Repository noch aufruft, oder eine Prüfung, die beim Verschieben von einem Dienst in den anderen verloren geht.

**Zweitprüfer-Verfügbarkeit.** Gleich zu Beginn, parallel zu Schritt 1, einmal prüfen: `codex --version && codex login status`. Schlägt das fehl, steht von Anfang an fest, dass Sonnet einspringt.

Kann das Ziel der Änderung nicht ermittelt werden, das offen im Bericht sagen und Korrektheitsaussagen, die vom Ziel abhängen, als [Frage] formulieren.

Fertig, wenn Basis und Diff-Umfang je Repository feststehen und das Ziel der Änderung ermittelt oder als unbekannt vermerkt ist.

## Schritt 2: Überblick und Lauffähigkeit

**Struktur lesen:** Build-Datei (`pom.xml`, `build.gradle`, `package.json`, `pyproject.toml` ...), Konfiguration (`application*.yml`, `.env.example`), Deployment (`Dockerfile`, `docker-compose*.yml`, CI-Datei wie `.gitlab-ci.yml`).

**Bauen und testen.** Den Checkout des Nutzers nicht wechseln. Steht das Repository auf einem anderen Branch, den zu prüfenden Stand ins Scratchpad holen, per `git worktree add <scratchpad>/<repo> <branch>` oder `git archive <branch> | tar -x -C <scratchpad>/<repo>`, und dort bauen. Ein angelegter Worktree wird am Ende mit `git worktree remove` entfernt. Nichts ins lokale Maven-Repository installieren, was der Review nicht braucht (`mvn test` statt `mvn install`, wo das reicht).

Den Befehl aus README oder CI übernehmen, nicht raten. Typisch:

| Build | Befehl |
|---|---|
| Maven | `mvn -B -q verify` (Wrapper `./mvnw` bevorzugen) |
| Gradle | `./gradlew build` |
| npm | `npm ci && npm test` |
| Python | `pytest` im vorhandenen venv |

Lange Läufe mit `run_in_background` starten und währenddessen mit Schritt 3 weitermachen. Keine systemweiten Installationen, keine Änderungen an Dateien im Repository, keine Secrets erfinden. Braucht der Build Zugangsdaten oder externe Dienste, nicht improvisieren, sondern als Befund aufnehmen.

**Container-Laufzeit.** Brauchen Tests Docker oder Podman, lies `container-runtime.md` (Start ohne Rückfrage erlaubt, mit Pflichten).

**Java- und Laufzeitversionen abgleichen.** `java.version`, `maven.compiler.source/target/release`, die Konfiguration des Compiler-Plugins, das Basis-Image im `Dockerfile` und die JDK-Version in der CI müssen zusammenpassen, auch zwischen den Repositories einer Story. Eine neue Abweichung im Diff ist ein Kandidat, meist als [Frage] zur tatsächlichen Laufzeit in Produktion.

**Ergebnis einordnen:**

- `lauffaehig`: Build und Tests grün.
- `eingeschraenkt`: Build grün, aber Tests übersprungen, Integrationstests nicht ausführbar oder nur mit Workaround.
- `nicht_lauffaehig`: Build oder Tests schlagen fehl.

Bei `eingeschraenkt` und `nicht_lauffaehig` gehört in den Bericht:

- der exakte Befehl und die entscheidenden Zeilen der Fehlermeldung,
- die Ursache, eingeordnet als Umgebung (JDK-Version, fehlender Docker für Testcontainers, fehlende Umgebungsvariable, Zugriff auf ein privates Artefakt-Repository) oder als Code (Kompilierfehler, roter Test),
- konkrete Schritte, wie es lauffähig wird, zum Beispiel "JDK 21 statt 17 aktivieren, siehe `maven.compiler.release` in `pom.xml:34`" oder "`SPRING_DATASOURCE_URL` setzen, Vorlage in `.env.example`".

Liegt die Ursache im geänderten Code, ist das zusätzlich ein eigenes Finding, meist [Blocker].

**Tests einordnen.** Für jede neue oder wesentlich geänderte Klasse prüfen, ob ein Test sie ausführt. Ist ein Coverage-Werkzeug konfiguriert (JaCoCo, Istanbul, coverage.py), den Bericht dafür nutzen, sonst per Suche nach Klassen- und Methodennamen in den Testverzeichnissen.

**Deaktivierte Tests suchen.** In allen betroffenen Repositories gezielt suchen, nicht nur im Diff:

| Sprache | Muster |
|---|---|
| Java | `@Disabled`, `@DisabledIf...`, `@Ignore`, `Assumptions.assume...`, `assumeTrue` |
| Maven/Gradle | `<skipTests>`, `<skip>true`, `maven.test.skip`, `<excludes>` im Surefire- oder Failsafe-Plugin, `test { exclude ... }`, `-DskipTests` in CI-Dateien |
| JavaScript/TypeScript | `it.skip`, `describe.skip`, `xit`, `xdescribe`, `test.todo` |
| Python | `@pytest.mark.skip`, `skipif`, `@unittest.skip` |

Jeder Fund in der Nähe des geänderten Codes wird ein eigenes Finding der Kategorie Tests: welcher Test, seit wann abgeschaltet (`git log -S "@Disabled" -- <datei>`), mit welcher Begründung, und was er abdecken würde. Deckt der abgeschaltete Test genau den Bereich eines anderen Findings ab, beide Findings aufeinander verweisen lassen. Mindestens [Sollte], wenn er im Diff abgeschaltet wurde oder einen Sicherheitsbereich betrifft.

Fertig, wenn pro Repository ein Zustand feststeht, bei Abweichungen Befehl, Ursache und Schritte notiert sind, jede neue oder wesentlich geänderte Klasse auf Testabdeckung geprüft ist und die Zahl der übersprungenen Tests im Ergebnis steht, auch wenn sie null ist.

## Schritt 3: Diff lesen, von außen nach innen

In dieser Reihenfolge, jeweils mit `git diff <basis>...HEAD -- <pfad>` und dem Lesen der ganzen Datei, wo der Kontext es verlangt:

1. **Konfiguration und Abhängigkeiten.** Was ist neu? Neue Bibliotheken (Version, Lizenz, bekannte Schwachstellen), geänderte Properties, neue Profile, Feature-Flags, Rechte im Container.
2. **Einstiegspunkte.** Wer ruft den neuen Code auf? Controller, Scheduler, Listener, Batch-Jobs, REST-Endpunkte. Wird er überhaupt aufgerufen? Toter neuer Code ist ein Finding.
3. **Kernlogik Zeile für Zeile.** Randfälle, `null`, leere Listen, Fehlerpfade, Transaktionsgrenzen, Nebenläufigkeit, Zeitzonen und Datumsgrenzen.
4. **Tests.** Decken sie die neue Logik ab? Würden sie einen Fehler finden? Ein Test, der nur prüft, dass keine Exception fliegt, deckt fachlich nichts ab. Probe: Schlägt ein Test fehl, wenn man die zentrale Bedingung umdreht?

Beim Lesen die Checkliste aus Schritt 4 anwenden und Kandidaten sofort mit Datei und Zeile notieren.

Fertig, wenn alle vier Ebenen durchlaufen sind.

## Schritt 4: Checkliste nach Priorität

| Prio | Kategorie | Frage |
|---|---|---|
| 🔴 | Sicherheit | Secrets im Code? Sensible Daten in Logs? Eingaben validiert? |
| 🔴 | Korrektheit | Tut der Code, was er soll? Randfälle, `null`, Fehlerpfade, Nebenläufigkeit? |
| 🟠 | Tests | Ist die neue Logik getestet? Würden die Tests einen Fehler finden? |
| 🟠 | Architektur | Passt es zum bestehenden Design? Widerspricht es der Doku? |
| 🟡 | Wartbarkeit | Toter Code, Hardcoding, Duplikate, lange Methoden, lange Parameterlisten, Feature-Neid (Methode arbeitet vor allem mit Daten einer fremden Klasse), Datenklumpen (immer dieselben Werte zusammen übergeben), primitive Typen statt kleiner Werttypen, Schrotflinten-Änderung (eine Änderung zwingt zu Edits an vielen Stellen), Reinvented Wheel (selbst gebauter Code, den eine schon eingebundene Bibliothek oder die Standardbibliothek abdeckt, Build-Datei prüfen). Erkennungszeichen und Zielform: `../../shared/code-smells.md`. Code Smells sind Urteile, höchstens [Sollte], meist [Nit] oder [Frage], immer mit konkretem Umbauvorschlag |
| ⚪ | Stil | Tippfehler, Formatierung, Methodennamen. Tippfehler und Formatierung sollte ein Linter übernehmen, kein Mensch |

Stil-Findings nur bündeln und knapp halten. Gleichartige Kleinigkeiten werden ein einziges [Nit] mit allen Fundstellen.

**Methodennamen.** Jede neue oder umbenannte Methode im Diff wird von Hand geprüft (Kategorie Stil), weil ein Linter nur die Konvention erkennt. Zwei Fragen:

1. **Konvention der Sprache und des Projekts.** Weicht das Projekt bewusst und einheitlich ab, gilt die Projektkonvention (an benachbartem Code prüfen). Die Konventionen je Sprache stehen in `method-naming.md`, bei Bedarf dort nachschlagen.
2. **Name passt zum Verhalten.** Rumpf und Aufrufer lesen. Mängel: verschwiegene Nebenwirkung (`getUser` legt an, `validate` speichert), anderes Versprechen als Verhalten (`isValid` wirft statt `false`), zu allgemein (`process`, `handle`, `doIt`, `manage`, `helper`), mehrere Dinge unter einem Namen (`saveAndNotify` hinter `save`), nach einer Änderung veraltet.

Reiner Konventionsverstoß: [Nit], gleichartige gebündelt. Irreführender Name (verschwiegene Nebenwirkung, Gegenteil versprochen): [Sollte], Szenario ist der Aufruf, bei dem ein Entwickler dem Namen vertraut. Jedes Benennungs-Finding hat die Kategorie Stil und einen Namensvorschlag. Ein nur ungewohnter, aber korrekter Name ist kein Finding. Ausgenommen sind durch Framework oder Schnittstelle vorgegebene Namen (`@Override`, Lifecycle, generierter Code).

**Überladungen.** Enthält der Diff neue oder geänderte Überladungen, die an derselben Parameterposition verschiedene funktionale Interfaces erwarten, lies den Abschnitt dazu in `method-naming.md`.

Fertig, wenn jede Kategorie auf den Diff angewendet ist und alle Kandidaten Datei und Zeile tragen.

## Schritt 5: /code-review als zweite Quelle

**Früh starten, spät lesen.** /code-review läuft einige Minuten im Hintergrund. Starten, sobald Ziel, Basis und Umfang aus Schritt 1 feststehen, parallel zu Build und Diff-Lektüre. Die Ergebnisse erst lesen, wenn der eigene Durchgang aus Schritt 3 und 4 abgeschlossen ist. So bleiben beide Quellen unabhängig. Die Benachrichtigung über das Ende bis dahin liegen lassen.

```
Skill: code-review
args: "<stufe> <ziel>"
```

`<stufe>` ist `medium` oder `high` aus Schritt 0. `<ziel>` ist die MR/PR-Nummer oder der Branch, damit derselbe Diff geprüft wird. Der Skill meldet seine Findings über das ReportFindings-Tool an die Oberfläche. Das ist in Ordnung, aber nicht das Ergebnis dieses Reviews. Seine Findings sind **Kandidaten** und laufen durch dieselbe Verifikation wie die eigenen.

Kandidaten beider Quellen zusammenführen. Dubletten (gleiche Stelle, gleicher Mechanismus) zu einem Kandidaten verschmelzen und beide Quellen vermerken. Findet /code-review etwas, das der eigene Durchgang übersehen hat, die Stelle trotzdem selbst lesen, bevor der Kandidat weitergeht.

Ist der Skill nicht verfügbar oder bricht ab, im Bericht vermerken und ohne ihn weitermachen.

Fertig, wenn die Kandidatenliste beider Quellen ohne Dubletten steht (oder der Ausfall vermerkt ist).

## Schritt 6: Jedes Finding verifizieren

Das ist der Kern des Skills. Für jeden Kandidaten:

1. **Stelle erneut lesen**, mit genug Kontext, nicht nur die Diff-Zeilen.
2. **Pfad verfolgen.** Aufrufer und Aufgerufene lesen. Kann der problematische Zustand dort überhaupt ankommen?
3. **Gegenprobe.** Aktiv nach dem suchen, was das Finding widerlegen würde: eine Prüfung im Aufrufer, eine Validierung per Annotation (`@NotNull`, `@Valid`), ein Default in der Konfiguration, ein Framework-Verhalten, ein Test, der genau diesen Fall abdeckt, ein Kommentar, der die Entscheidung begründet.
4. **Szenario formulieren.** Konkrete Eingabe oder konkreter Zustand, der zum falschen Verhalten führt. Wer keines formulieren kann, hat kein Finding, sondern höchstens eine [Frage].
5. **Status vergeben:**
   - `bestaetigt`: Code gelesen, Pfad erreichbar, Gegenprobe ohne Treffer, Szenario konkret.
   - `nachgewiesen`: wie `bestaetigt`, und zusätzlich am laufenden System reproduziert.
   - `plausibel`: Mechanismus stimmt, aber etwas bleibt offen (Laufzeitverhalten, Framework-Semantik, Daten aus Produktion).
   - `verworfen`: Gegenprobe hat eine Absicherung gefunden. Kommt mit Grund in einem Satz in die Liste der verworfenen Kandidaten, damit der Leser sieht, was aussortiert wurde.

Hängt ein Finding an Laufzeitverhalten (Security-Filter, Autokonfiguration, HTTP-Status, Serialisierung), lies `live-system.md` (lokaler Nachweis, Status `nachgewiesen`).

**Zweitprüfung.** Proaktiv, ohne zu fragen, wenn mindestens eins zutrifft:

- Status nach der eigenen Gegenprobe ist `plausibel`.
- Schweregrad wäre [Blocker], und das Finding hängt an mehr als einer einzelnen, offensichtlichen Zeile.
- Das Finding stammt nur aus /code-review und der eigene Durchgang hatte es nicht.
- Das Finding hängt an Framework- oder Bibliotheksverhalten, das nicht im Repository nachlesbar ist.

Prüfer ist Codex, Sonnet nur auf Wunsch ("mit Sonnet", "beide") oder als Ersatz, wenn Codex nicht erreichbar ist. "Ohne Zweitprüfung" schaltet beides ab, unsichere Findings werden dann als [Frage] formuliert. Aufruf, Zeitverhalten und Zusammenführen der Urteile stehen in `second-opinion.md`, lies sie, sobald eine Zweitprüfung startet.

Fertig, wenn jeder Kandidat einen Status hat. Der Entwurf des Berichts darf parallel zu laufenden Zweitprüfungen entstehen, fertiggestellt wird er erst, wenn alle gestarteten Prüfungen beendet oder ersetzt sind.

## Schritt 7: Findings formulieren

| Marke | Bedeutung |
|---|---|
| [Blocker] | Muss vor dem Merge behoben werden. Falsches Verhalten, Sicherheitslücke, Datenverlust, Build kaputt |
| [Sollte] | Sollte behoben werden, blockiert aber nicht. Fehlende Tests für neue Logik, Architekturbruch, riskantes Hardcoding, irreführende Methodennamen |
| [Nit] | Kleinigkeit. Verstöße gegen Namenskonventionen, toter Code, Stil |
| [Frage] | Unklar, ob es ein Problem ist. Wird als Frage an den Autor formuliert |

Jedes Finding enthält:

- **ID** `F1`, `F2` ... sortiert nach Schweregrad, dann Kategorie-Priorität.
- **Titel**, ein Satz, der den Mangel benennt, nicht den Bereich. "Austrittsdatum wird bei Zeitzone UTC um einen Tag verschoben", nicht "Datumsbehandlung".
- **Ort** `pfad/Datei.java:zeile`.
- **Belege.** Jedes Finding braucht einen Beleg, den der Leser ohne Suche nachvollziehen kann:
  - Lässt sich das Finding am Code erklären, sind **Code-Auszüge** Pflicht.
  - Hat es eine andere Ursache, genügen **sonstige Belege** im Feld `belege`: ein Zitat aus dem Ticket (etwa die Definition of Done, die Releasenotes verlangt), die Ausgabe eines Befehls, ein Dateilisting, eine Zeile aus der CI-Konfiguration oder ein Hinweis auf eine Datei, die fehlt. Ein erfundener oder gezwungener Code-Auszug ist schlechter als keiner.
  - Beides zusammen, wenn es beides gibt.
- **Code-Auszüge.** Der tatsächliche Code mit Zeilennummern, drei bis fünf Zeilen Kontext davor und danach, die entscheidenden Zeilen markiert. Entsteht das Problem aus dem Zusammenspiel (Aufrufer ohne Prüfung, Aufgerufener ohne Absicherung), beide Stellen als eigene Auszüge. Aus der Datei kopieren, nie aus dem Gedächtnis rekonstruieren, auch keine Kürzungen mit "...", die die Aussage verändern.
- **Warum ist das ein Problem.** Der Mechanismus in zwei bis fünf Sätzen, so erklärt, dass jemand, der den Code nicht kennt, es mit dem Auszug allein nachvollziehen kann.
- **Szenario.** Konkrete Eingabe oder konkreter Zustand, dann das falsche Ergebnis.
- **Gegenprobe.** Was geprüft wurde, um einen Fehlalarm auszuschließen, und was herauskam. Zum Beispiel "Einziger Aufrufer `AustrittController:88` reicht den Wert ungeprüft durch, keine Validierung am DTO, kein Test mit leerem Datum."
- **Prüfstatus** `nachgewiesen`, `bestaetigt` oder `plausibel`, und wer geprüft hat (`selbst`, `sonnet`, `codex`).
- **Vorschlag**, konkret. Bei Bedarf als kurzer Code-Schnipsel.
- **Quelle** `eigene Prüfung`, `/code-review` oder beide.

Die Datenstruktur für den Bericht steht in `../../shared/evidence-code-review/references/report-schema.md`.

**Auch Gutes erwähnen.** Zwei bis fünf konkrete Punkte, was gut gelöst ist, mit Ort. Zum Beispiel datenschutzbewusste Log-Einstellungen, `read_only` im Container, gezielte Tests für einen heiklen Service. Kein Pflichtlob, nur was wirklich auffällt.

Fertig, wenn jedes verifizierte Finding alle Felder trägt (Belege je nach Ursache als Code-Auszug oder sonstiger Beleg) und die Positives stehen.

## Schritt 8: Abschluss

Der Bericht endet mit:

- **Gesamturteil:** `Freigeben`, `Freigeben mit Anmerkungen` oder `Überarbeiten`. Ein offener [Blocker] bedeutet immer `Überarbeiten`.
- **Zusammenfassung** in zwei bis vier Sätzen: Was die Änderung tut, ob sie das Ziel erreicht, was vor dem Merge passieren muss.
- **Zahlen:** Findings je Schweregrad, verworfene Kandidaten, Zweitprüfungen.
- **Nächste Schritte.** Angebot, einzelne Findings gezielt nachprüfen zu lassen, und Angebot, die Findings als Kommentare in den MR zu übernehmen. Letzteres erst nach Freigabe des genauen Textes.

## Schritt 9: Ausgabe

**Artifact:** lies `artifact-output.md`. Dort steht auch, wie die Collection `pruefung` gelesen wird, wenn der Nutzer später fragt, welche Findings er abgehakt oder als Fehlalarm markiert hat. Im Chat danach nur Link, Gesamturteil und Zahlen je Schweregrad nennen, nicht den ganzen Bericht wiederholen.

**Terminal:** Markdown in dieser Reihenfolge: Kopf (Repository, Branch gegen Basis, Datum, Stufe, Umfang), Gesamturteil und Zusammenfassung, Kontext, Lauffähigkeit, Findings, Positives, verworfene Kandidaten, Abschluss.

Pro Finding:

````markdown
### F3 [Blocker] Austrittsdatum wird bei Zeitzone UTC um einen Tag verschoben
🔴 Korrektheit · `src/main/java/.../AustrittMapper.java:57` · bestätigt (selbst, codex) · Quelle: eigene Prüfung

```java
55  public Austritt map(LogaRecord r) {
56      Austritt a = new Austritt();
57 >    a.setDatum(r.getTimestamp().toLocalDate());
58      return a;
59  }
```

**Warum ist das ein Problem:** ...
**Szenario:** ...
**Gegenprobe:** ...
**Vorschlag:** ...
````

Die Zeile mit `>` ist die markierte. Die Sprache im Codeblock passend zur Datei setzen.

## Einzelne Findings nachprüfen

Sagt der Nutzer nach dem Bericht "prüf F3 nochmal" (dann Codex), "prüf F3 mit Codex" oder "lass F2 und F5 von Sonnet gegenprüfen", den Ablauf aus `second-opinion.md` (Abschnitt "Einzelne Findings auf Zuruf prüfen") für die genannten IDs ausführen.
