# Stil: Methodennamen und Überladungen

Gehört zu Schritt 4 von `SKILL.md`. Die Prüfregeln für Methodennamen stehen dort. Hier: Konventionen je Sprache (zum Nachschlagen) und die Überladungsprüfung.

## Konventionen je Sprache

- Java, Kotlin, JavaScript, TypeScript: `lowerCamelCase`, Verb am Anfang (`calculateTotal`, `sendInvoice`). Boolesche Abfragen mit `is`, `has`, `can` (`isExpired`). Getter und Setter nach JavaBeans (`getName`, `setName`).
- C#: `PascalCase` (`CalculateTotal`), asynchrone Methoden mit Endung `Async`.
- Python: `snake_case` nach PEP 8 (`calculate_total`), interne Methoden mit führendem Unterstrich.
- Go: `MixedCaps`, großer Anfangsbuchstabe nur für Exportiertes, Getter ohne `Get` (`Owner()` statt `GetOwner()`).
- Rust: `snake_case`, Umwandlungen nach `as_`, `to_`, `into_`.

Weicht das Projekt bewusst und einheitlich von der Sprachkonvention ab, gilt die Projektkonvention. Das vorher an benachbartem Code prüfen.

## Wartbarkeit: Überladung mit Lambda-Parametern

Neue oder geänderte Überladungen prüfen, die an derselben Parameterposition verschiedene funktionale Interfaces erwarten, etwa `inTransaction(SessionWork<T>)` neben `inTransaction(SessionAction)`. Ein Lambda ohne Typangabe ist dann beim Aufrufer mehrdeutig, sobald sein Rumpf ein einzelner Ausdruck ist (`session -> session.persist(x)`) oder nur mit `throw` endet. Der Aufrufer muss auf Klammern oder ein künstliches `return null` ausweichen, und ein späterer Umbau zum Einzeiler kompiliert nicht mehr (Effective Java, Item 52, `javac -Xlint:overloads` warnt).

**Schweregrad.** [Sollte], Kategorie Wartbarkeit. Vorschlag: die Varianten verschieden benennen, etwa `inTransaction` für den Wert und `runInTransaction` für void. Verifikation: einen Einzeiler-Aufruf gegen beide Überladungen kompilieren. Meldet javac „Referenz ist mehrdeutig“, ist das Finding belegt. Unterscheiden sich die Interfaces in der Parameterzahl, ist es kein Finding.
