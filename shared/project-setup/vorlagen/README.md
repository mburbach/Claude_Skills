<!-- project-setup Vorlage v{{VORLAGENVERSION}} -->
# {{PROJEKTNAME}}

{{BESCHREIBUNG}}

## Voraussetzungen

- gitleaks, für den pre-commit-Hook
{{VORAUSSETZUNGEN}}

## Bauen und Testen

| Befehl | Zweck |
|---|---|
| `{{CMD_BUILD}}` | Bauen |
| `{{CMD_TEST}}` | Tests ausführen |
| `{{CMD_LINT}}` | Linter prüfen |
| `{{CMD_FORMAT}}` | Code formatieren |
| `{{CMD_CHECK}}` | Alle Prüfungen, vor jedem Push grün |
| `{{CMD_PRECOMMIT}}` | Prüfungen des pre-commit-Hooks |

## Einmalig nach dem Klonen

```
git config core.hooksPath .githooks
```

Alternativ `make hooks` oder `just hooks`.

## Mitarbeit

Vor jeder Änderung gelten [CODING_STANDARDS.md](CODING_STANDARDS.md) und die [Definition of Done](docs/definition-of-done.md).

## Architektur

Siehe [docs/architektur.md](docs/architektur.md) und die Architekturentscheidungen in [docs/adr/](docs/adr/).
