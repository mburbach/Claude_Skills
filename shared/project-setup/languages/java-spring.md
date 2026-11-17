# Java mit Spring Boot

## Erkennen

`pom.xml` oder `build.gradle.kts` bzw. `build.gradle` im Projektstamm, `mvnw` oder `gradlew`, Spring-Boot-Parent oder -Plugin in der Build-Datei. Ohne Spring-Boot-Parent oder -Plugin gilt der Abschnitt Bestand.

## Bestand

Java ohne Spring (Teilübereinstimmung):

- Es entfallen der Startbefehl und Spring Modulith. Modulgrenzen prüft ArchUnit (Regel pro Feature-Paket: keine Zugriffe auf `internal` fremder Pakete, keine Zyklen).
- Vor dem Plan `./mvnw test` bzw. `mvn verify` als Ausgangslage laufen lassen. Scheitern alte Plugin-Versionen an der aktuellen Java-Version (zum Beispiel JaCoCo mit `Unsupported class file major version`), ist das Anheben eine Planzeile `Änderung an Bestand`.
- Es gelten Werkzeuge, Befehle, Sprachregeln, Teststil, Pre-commit und Sicherheit dieser Datei.
- Plugins kommen nur nach Bestätigung im Plan in die vorhandene Build-Datei.
- Spotless mit `ratchetFrom` auf den lokalen Hauptzweig (nur geänderte Dateien), ohne Commits mit `excludes` (siehe `java-spring-pom.md`). Keine Massenformatierung.
- Ist der vorhandene Java-Code mit 4 Leerzeichen eingerückt, bekommt `.editorconfig` für `*.java` `indent_size = 4`. Spotless nutzt google-java-format im AOSP-Stil (Android Open Source Project): `<style>AOSP</style>` in Maven, `googleJavaFormat().aosp()` in Gradle. So passen neue und alte Dateien zusammen.
- Checkstyle: Einträge für Altdateien mit Verstößen (zum Beispiel AvoidStarImport, LineLength) in `config/checkstyle/suppressions.xml` eintragen, nicht umschreiben. Jeder Eintrag steht als eigene Zeile im Plan.
- ArchUnit als normale Testmethode, nicht als `@ArchTest static final` (kollidiert mit `ConstantName`):

```java
@Test
void features_areFreeOfCycles() {
  var classes = new ClassFileImporter().importPackages("{{PACKAGE}}");
  slices().matching("{{PACKAGE}}.(*)..").should().beFreeOfCycles().check(classes);
}
```

- Die ArchUnit-Testklasse heißt `ModularityTest`, nicht `ModulithTest` (diesen Namen trägt nur der Test bei Spring Modulith).
- Fehlt der Maven-Wrapper: `mvn wrapper:wrapper`.
- Java-Version aus dem bestehenden Build übernehmen.
- Ordnerstruktur nur als Empfehlung.

## Fragen für ein neues Projekt

- Build-Werkzeug: Maven mit Wrapper (Standard) oder Gradle mit Kotlin DSL.
- `groupId`, `artifactId`, Paketname (Standard: groupId plus artifactId ohne Bindestriche).
- Java-Version (aktuelle LTS) und Spring-Boot-Version (aktuelle stabile).
- Abhängigkeiten der Startseite, zum Beispiel Web, Persistenz, Validierung, Actuator, Datenbanktreiber, Testcontainers, Modulith. `modulith` kommt immer dazu, ohne Frage. Die IDs stammen aus den Metadaten von start.spring.io, Starter-Namen ändern sich zwischen Hauptversionen und werden nie aus dieser Datei übernommen.
- Datenbank für Treiber und Testcontainers, oder keine.

## Startbefehl

Metadaten mit gültigen Werten: `curl -sS -H 'Accept: application/json' https://start.spring.io`.

```bash
curl -sS https://start.spring.io/starter.zip \
  -d type={{maven-project|gradle-project-kotlin}} -d language=java \
  -d groupId={{GROUP_ID}} -d artifactId={{ARTIFACT_ID}} -d name={{ARTIFACT_ID}} \
  -d packageName={{PACKAGE}} -d javaVersion={{JAVA_VERSION}} \
  -d bootVersion={{BOOT_VERSION}} -d description='{{BESCHREIBUNG}}' \
  -d dependencies=modulith,{{DEP1,DEP2}} \
  -o /tmp/starter.zip
unzip -n /tmp/starter.zip -d {{PROJEKTORDNER}}
```

Nach dem Start:

1. `bootVersion` nur aus stabilen Versionen wählen (kein RC, M, SNAPSHOT). Liefern die Metadaten eine Endung `.RELEASE`, die Endung entfernen. Im generierten Build prüfen, dass der Parent auf Maven Central auflöst (`./mvnw -q validate` bzw. `./gradlew help`).
2. Die Hauptklasse heißt `<Projekt>Application`, nicht `Application`. Der `contextLoads`-Test des Starters bleibt.
3. Nach den Plugin-Ergänzungen einmal `{{CMD_FORMAT}}` ausführen, der Starter-Code entspricht nicht google-java-format.

## Werkzeuge

| Zweck | Wahl | Begründung |
|---|---|---|
| Format | Spotless mit google-java-format | Feste Formatierung ohne Diskussion, Plugin für Maven und Gradle. |
| Stil | Checkstyle (`vorlagen/java/checkstyle.xml` nach `config/checkstyle/checkstyle.xml`) | Namens-, Import- und Größenregeln aus einer Datei. |
| Fehlermuster | Error Prone im Compiler | Läuft beim Kompilieren mit. SpotBugs und PMD fehlen bewusst, um Doppelmeldungen zu vermeiden. |
| Modulgrenzen | Spring Modulith, im Bestand ohne Spring ArchUnit | Modulith passt zu Spring Boot und package by feature und prüft Zyklen und interne Zugriffe. |
| Tests | JUnit 5, AssertJ, Mockito, Testcontainers | Standard im Spring-Boot-Umfeld, Datenbanktests gegen echte Datenbank. |
| Abhängigkeitsprüfung | OSV-Scanner | Läuft ohne Schlüssel und schnell. OWASP Dependency-Check braucht einen NVD-Schlüssel (National Vulnerability Database) und ist langsam. |
| Secrets | gitleaks | Pre-commit und CI. |

Pom- und Gradle-Ausschnitte stehen in `java-spring-pom.md`. Zielpfade: `.mvn/jvm.config`, `config/checkstyle/checkstyle.xml` und `config/checkstyle/suppressions.xml` (aus `vorlagen/java/`, im Neuprojekt bleibt die Suppressions-Datei leer). Läuft Error Prone mit der Java-Version nicht, weglassen und im Bericht nennen.

## Befehle

| Platzhalter | Maven | Gradle |
|---|---|---|
| `{{CMD_BUILD}}` | `./mvnw -B package -DskipTests` | `./gradlew assemble` |
| `{{CMD_TEST}}` | `./mvnw -B test` | `./gradlew test` |
| `{{CMD_LINT}}` | `./mvnw -B checkstyle:check` | `./gradlew checkstyleMain checkstyleTest` |
| `{{CMD_FORMAT}}` | `./mvnw -B spotless:apply` | `./gradlew spotlessApply` |
| `{{CMD_CHECK}}` | `./mvnw -B spotless:check verify` | `./gradlew spotlessCheck check` |
| `{{CMD_PRECOMMIT}}` | `./mvnw -q -B spotless:check checkstyle:check` | `./gradlew -q spotlessCheck checkstyleMain` |

Bei Maven läuft Checkstyle über die Ausführung in `verify`, deshalb steht es nicht extra in `{{CMD_CHECK}}`.

## Sprachregeln für CODING_STANDARDS.md

```markdown
- Format: google-java-format über Spotless. `format` ausführen, nie von Hand formatieren.
- Stil und Fehlermuster: Checkstyle und Error Prone. Unterdrückung nur mit Begründung im Kommentar.
- Struktur: package by feature. Jedes Feature ist ein Modul, Zugriff nur über das Paket des Moduls. Die Modulprüfung (`ApplicationModules.verify()` bzw. ArchUnit) muss grün sein.
- Fachbegriffe deutsch, Bezeichner englisch (`AntragService.loadAntraegeByMandanten`).
- Tests: JUnit 5 und AssertJ. Mockito nur an Systemgrenzen. Erwartete Werte aus unabhängiger Quelle, nicht aus dem getesteten Code. Datenbanken mit Testcontainers.
- Konstruktor-Injektion, keine Feld-Injektion.
```

## Ordnerstruktur

Package by feature unter dem Basispaket. Jedes Unterpaket des Basispakets ist ein Modul. Ein Modul nie genauso nennen wie das Basispaket (sonst `bestellung.bestellung`).

```text
src/main/java/{{PACKAGE_PFAD}}/
  <Projekt>Application.java
  antrag/              # Modul, öffentliche API im Paketstamm
    AntragService.java
    AntragRepository.java
    internal/          # nur innerhalb des Moduls
  mandant/
src/test/java/{{PACKAGE_PFAD}}/
  antrag/AntragServiceTest.java
  ModulithTest.java
```

Bei Bestand nur als Empfehlung ausgeben, nichts verschieben.

## Testgerüst und erster Test

1. `ModulithTest`: `ApplicationModules.of(<Projekt>Application.class).verify();`
2. Fachtest für eine kleine, echte Regel des Projekts. Rot laufen lassen (Klasse fehlt oder Ergebnis falsch), mit dem kleinsten Code grün machen. Nicht nur `contextLoads`.

```java
class AntragServiceTest {
  @Test
  void loadAntraegeByMandanten_returnsOnlyAntraegeOfGivenMandanten() {
    var repo = new InMemoryAntragRepository(new Antrag("A1", "M1"), new Antrag("A2", "M2"));
    var service = new AntragService(repo);

    assertThat(service.loadAntraegeByMandanten(List.of("M1")))
        .extracting(Antrag::id)
        .containsExactly("A1");
  }
}
```

Der erwartete Wert steht fest im Test. Fehlt ein Fachbezug, eine kleine Berechnung oder Validierung aus der Anforderung des Nutzers wählen.

## Basisdateien

- `.gitignore`: `curl -sS https://www.toptal.com/developers/gitignore/api/java,maven,intellij,visualstudiocode` (bei Gradle `gradle` statt `maven`). Bei vorhandener `.gitignore` zuerst sicherstellen, dass sie mit Zeilenumbruch endet: `[ -n "$(tail -c1 .gitignore)" ] && echo >> .gitignore`. Dann nur fehlende Zeilen anhängen: neue Datei erzeugen, dann `grep -vxFf .gitignore neu.txt >> .gitignore`. `HELP.md` des Starters löschen, sie steht schon in der Starter-`.gitignore` und ist nur Werbetext.
- `.editorconfig`-Ergänzung. Im Bestand `indent_size` aus dem vorhandenen Java-Code übernehmen (zum Beispiel 4), die 2 gilt nur im Neuprojekt:

```ini
[*.java]
indent_style = space
indent_size = 2
max_line_length = 100

[*.{xml,yml,yaml,kts}]
indent_style = space
indent_size = 2
```

## Voraussetzungen

Text für `{{VORAUSSETZUNGEN}}`: `JDK {{JAVA_VERSION}}` (Maven-Wrapper bzw. Gradle-Wrapper liegt im Projekt) und `Docker` nur bei Testcontainers.

## Pre-commit

Der Hook kommt aus `vorlagen/githooks-pre-commit` nach `.githooks/pre-commit`. Die Sprachdatei liefert nur `{{CMD_PRECOMMIT}}` (Tabelle Befehle). Aktivierung mit `make hooks`.

## Abhängigkeiten und Sicherheit

- Abhängigkeitsprüfung: `osv-scanner scan source -r .` (Syntax der V2-Doku von google.github.io/osv-scanner/usage). Läuft in CI (siehe CI-Datei), lokal optional. Treffer melden, nicht unterdrücken.
- Updates: Dependabot (GitHub) oder Renovate (andere Plattformen), Ökosystem `maven` bzw. `gradle`.
- Keine Secrets in `application*.yml`, Werte über Umgebungsvariablen.

## Zu recherchieren beim Lauf

- Java-LTS-Version, Spring-Boot-Version (stabil, ohne `.RELEASE`), gültige `dependencies`-IDs und Starter-Namen aus den Metadaten von start.spring.io
- Version des maven-compiler-plugin: Mit Spring-Boot-Parent verwaltet der Parent die Version, dann nicht pinnen. Nur ohne Parent oder wenn die Version für Error Prone zu alt ist, eine Version setzen (Error Prone braucht eine aktuelle).
- Version des maven-wrapper-plugin für `mvn wrapper:wrapper` im Bestand, Aufruf voll qualifiziert: `mvn org.apache.maven.plugins:maven-wrapper-plugin:<Version>:wrapper`
- Versionen von Spotless, google-java-format, maven-checkstyle-plugin, Checkstyle, Error Prone und dem Gradle-Plugin `net.ltgt.errorprone`
- Aktuelle Error-Prone-Installationsseite (errorprone.info/docs/installation) zu Compilerargumenten und JVM-Optionen für die gewählte Java-Version
- Spring-Modulith-Version (vom Spring-Boot-BOM verwaltet, sonst eigene), ArchUnit-Version im Bestand
- Testcontainers-Version und Modulname (BOM)
- OSV-Scanner: aktuelle Version
- `latest` und `release` in `maven-metadata.xml` können Betas sein. Dann die höchste stabile Version aus der Versionsliste nehmen.
