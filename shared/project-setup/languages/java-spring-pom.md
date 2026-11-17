# Java mit Spring Boot: Maven- und Gradle-Ausschnitte

Alle Versionen sind Platzhalter und werden beim Lauf recherchiert. Eigene Abschnitte in die vorhandene Build-Datei einfügen, nichts ersetzen. Die Einrückung der vorhandenen Datei übernehmen (der Starter nutzt Tabs), die Ausschnitte unten sind nur gegliedert dargestellt.

## Maven

Spotless und Checkstyle unter `<build><plugins>`:

```xml
<plugin>
  <groupId>com.diffplug.spotless</groupId>
  <artifactId>spotless-maven-plugin</artifactId>
  <version>{{SPOTLESS_VERSION}}</version>
  <configuration>
    <!-- Bestand mit Commits: <ratchetFrom>{{HAUPTZWEIG}}</ratchetFrom> -->
    <!-- Bestand ohne Commits: <java><excludes><exclude>src/main/java/de/beispiel/Main.java</exclude><exclude>src/test/java/de/beispiel/MainTest.java</exclude></excludes> ... -->
    <!-- Bestand mit 4 Leerzeichen: <java><googleJavaFormat><style>AOSP</style></googleJavaFormat></java> -->
    <java><googleJavaFormat/></java>
  </configuration>
</plugin>
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-checkstyle-plugin</artifactId>
  <version>{{CHECKSTYLE_PLUGIN_VERSION}}</version>
  <dependencies>
    <dependency>
      <groupId>com.puppycrawl.tools</groupId>
      <artifactId>checkstyle</artifactId>
      <version>{{CHECKSTYLE_VERSION}}</version>
    </dependency>
  </dependencies>
  <configuration>
    <configLocation>config/checkstyle/checkstyle.xml</configLocation>
    <propertyExpansion>checkstyle.suppressions.file=config/checkstyle/suppressions.xml</propertyExpansion>
    <includeTestSourceDirectory>true</includeTestSourceDirectory>
    <violationSeverity>warning</violationSeverity>
    <failOnViolation>true</failOnViolation>
  </configuration>
  <executions>
    <execution>
      <phase>verify</phase>
      <goals><goal>check</goal></goals>
    </execution>
  </executions>
</plugin>
```

Error Prone im `maven-compiler-plugin` (Konfiguration ergänzen, vorhandene `compilerArgs` behalten):

```xml
<configuration>
  <compilerArgs>
    <arg>-XDcompilePolicy=simple</arg>
    <arg>--should-stop=ifError=FLOW</arg>
    <arg>-Xplugin:ErrorProne</arg>
  </compilerArgs>
  <annotationProcessorPaths>
    <path>
      <groupId>com.google.errorprone</groupId>
      <artifactId>error_prone_core</artifactId>
      <version>{{ERRORPRONE_VERSION}}</version>
    </path>
    <!-- weitere Prozessoren des Projekts (zum Beispiel Lombok, MapStruct) hier ergänzen -->
  </annotationProcessorPaths>
</configuration>
```

`.mvn/jvm.config` (Zielpfad genau so, eine Zeile pro Option, Quelle: Installationsseite von Error Prone):

```text
--add-exports jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED
--add-exports jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED
--add-exports jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED
--add-exports jdk.compiler/com.sun.tools.javac.model=ALL-UNNAMED
--add-exports jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED
--add-exports jdk.compiler/com.sun.tools.javac.processing=ALL-UNNAMED
--add-exports jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED
--add-exports jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED
--add-opens jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED
--add-opens jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED
```


## Gradle (Kotlin DSL)

Plugins im Block `plugins`: `checkstyle` (eingebaut), `com.diffplug.spotless`, `net.ltgt.errorprone`. Abhängigkeit `errorprone("com.google.errorprone:error_prone_core:{{ERRORPRONE_VERSION}}")`. Spotless: `spotless { java { googleJavaFormat() } }` (im Bestand mit 4 Leerzeichen `googleJavaFormat().aosp()`), im Bestand mit Commits `ratchetFrom("{{HAUPTZWEIG}}")`. Checkstyle: `checkstyle { configFile = file("config/checkstyle/checkstyle.xml"); configProperties = mapOf("checkstyle.suppressions.file" to "config/checkstyle/suppressions.xml") }`. JVM-Optionen für Java 16 und neuer laut Plugin-Doku: github.com/tbroyer/gradle-errorprone-plugin (nicht geprüft, beim Lauf nachlesen).

## Fallback

Läuft Error Prone mit der gewählten Java-Version nicht, den Abschnitt weglassen und das im Bericht nennen.

## Spotless ohne Commits

`ratchetFrom` scheitert ohne Commit (`No such reference 'HEAD'`) und ohne lokalen Hauptzweig. Dann die vorhandenen Quelldateien einzeln in `excludes` eintragen, je Datei ein `<exclude>`, nie ein Muster wie `src/**/*.java`, sonst wären neue Dateien auch ausgenommen. Im Bericht empfehlen, nach dem ersten Commit auf `ratchetFrom` umzustellen. Kein `origin/` verwenden, es gibt evtl. keinen Remote.
