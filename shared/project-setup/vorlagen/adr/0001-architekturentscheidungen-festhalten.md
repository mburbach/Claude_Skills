<!-- project-setup Vorlage v{{VORLAGENVERSION}} -->
# 0001: Architekturentscheidungen festhalten

- Status: akzeptiert
- Datum: {{DATUM}}

## Kontext und Problemstellung

Architekturentscheidungen gehen ohne Festhaltung verloren. Spätere Sitzungen und Mitarbeitende finden nur den Code, nicht den Grund.

## Entscheidung

Wir halten Architekturentscheidungen als ADR (Architecture Decision Record) im MADR-Format unter `docs/adr/` fest.

Bei einem bestehenden Projekt dokumentiert eine ADR mit Status `vorgeschlagen`, wo das Projekt vom Standard abweicht und ob der Standard das Ziel ist.

## Konsequenzen

- Gut: Entscheidungen sind nachvollziehbar und lassen sich begründet ändern.
- Schlecht: Jede Entscheidung braucht einen kurzen Eintrag.
