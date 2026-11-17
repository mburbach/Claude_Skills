# GitHub Actions

## Erkennen

Ordner `.github/workflows/` mit `*.yml`, `.github/dependabot.yml`, Remote auf github.com.

## Ablage im Projekt

- `.github/workflows/check.yml`
- `.github/workflows/security.yml`
- `.github/dependabot.yml`

Vorhandene Dateien bleiben unverändert. Fehlende Teile ergänzen.

## Workflow check

Auslöser: `push` auf den Hauptzweig und `pull_request`. Der Workflow ruft nur den einheitlichen Befehl auf (`make check` oder `just check`). Sprachspezifisches (Java-Einrichtung, Cache) kommt aus der Sprachdatei.

```yaml
name: check
on:
  push:
    branches: [{{HAUPTZWEIG}}]
  pull_request:
permissions:
  contents: read
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@{{vN}}
      - uses: actions/setup-java@{{vN}}
        with:
          distribution: {{JAVA_DISTRIBUTION}}
          java-version: {{JAVA_VERSION}}
          cache: {{maven|gradle}}
      - uses: extractions/setup-just@{{vN}}   # nur bei justfile
      - run: {{make check|just check}}
```

Werte und Herkunft:

- `@{{vN}}`: beim Lauf die aktuelle Hauptversion jeder Action recherchieren und als `@vN` eintragen.
- `{{HAUPTZWEIG}}`: `git symbolic-ref --short refs/remotes/origin/HEAD` (ohne `origin/`), sonst `git branch --show-current`, sonst `main`.
- Java-Version in `setup-java`: die Version aus dem Build (im Neuprojekt die gewählte). `{{JAVA_DISTRIBUTION}}`: eine von `setup-java` unterstützte Distribution, Standard `temurin`.
- Den `setup-just`-Schritt nur bei einem justfile einbauen.

Docker ist auf `ubuntu-latest` vorhanden, Testcontainers laufen ohne Zusatz. Die Actions auf Commit-Hashes festlegen, wenn der Nutzer das wünscht (Dependabot pflegt sie).

## Sicherheit

`.github/workflows/security.yml` mit diesem Kopf und den Jobs aus diesem Abschnitt. Auslöser: `push` auf `{{HAUPTZWEIG}}`, `pull_request` und wöchentlich `schedule`, weil neue Schwachstellen auch ohne Commit auftauchen.

```yaml
name: security
on:
  push:
    branches: [{{HAUPTZWEIG}}]
  pull_request:
  schedule:
    - cron: '17 3 * * 1'
jobs:
```

gitleaks, CLI-Weg (ohne Lizenz): Die Action `gitleaks/gitleaks-action` verlangt für Organisationen einen Lizenzschlüssel. Standard daher die CLI:

```yaml
  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@{{vN}}
        with:
          fetch-depth: 0
      - name: gitleaks installieren und prüfen
        run: |
          curl -sSfL https://github.com/gitleaks/gitleaks/releases/download/v{{GITLEAKS_VERSION}}/gitleaks_{{GITLEAKS_VERSION}}_linux_x64.tar.gz | tar -xz gitleaks
          ./gitleaks git --no-banner --redact
```

Die Action als Alternative nur anbieten, wenn das Repository einem Privatkonto gehört, und die Lizenzfrage nennen.

OSV-Scanner, CLI-Weg (Abhängigkeitsprüfung aus der Sprachdatei):

```yaml
  osv-scanner:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@{{vN}}
      - name: osv-scanner installieren und prüfen
        run: |
          curl -sSfL -o osv-scanner https://github.com/google/osv-scanner/releases/download/v{{OSV_VERSION}}/osv-scanner_linux_amd64
          chmod +x osv-scanner
          ./osv-scanner scan source -r .
```

Dateiname des Release-Artefakts beim Lauf gegen die Releaseseite prüfen.

Dependency Review bei Pull Requests (nur `pull_request`):

```yaml
  dependency-review:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@{{vN}}
      - uses: actions/dependency-review-action@{{vN}}
```

Bei privaten Repositories braucht der Job GitHub Advanced Security. Im Dialog fragen: „Ist das Repository öffentlich oder hat es GitHub Advanced Security?“ Bei Nein entfällt der Job, der OSV-Scanner-Job deckt die Prüfung ab.

## Abhängigkeits-Updates

Standard Dependabot (`.github/dependabot.yml`), Renovate (`renovate.json`) nur auf Wunsch.

```yaml
version: 2
updates:
  - package-ecosystem: {{maven|gradle}}
    directory: /
    schedule:
      interval: weekly
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

Renovate-Alternative: `{ "extends": ["config:recommended"] }` in `renovate.json`, setzt die Renovate-GitHub-App am Repository voraus.

## Zu recherchieren beim Lauf

- Hauptversionen von `actions/checkout`, `actions/setup-java`, `actions/dependency-review-action` und, nur bei justfile, `extractions/setup-just`
- Unterstützte Distributionen von `setup-java`
- gitleaks- und OSV-Scanner-Release-Version mit genauem Dateinamen des Linux-Artefakts
- Aktuelle Lizenzbedingungen von `gitleaks-action`
- Verfügbarkeit von Dependency Review für das Repository (öffentlich oder Advanced Security)
