# Skill-Mechanik

Der Skill-Zweig von `writing-for-agents`. Alles Weitere zum Schreiben steht in `SKILL.md`.

## Aufruf

- **Model-invoked** (vom Modell ausgelöst, Standard): Die `description` bleibt in jeder Sitzung geladen, damit der Agent und andere Skills den Skill erreichen. Der Nutzer kann weiterhin `/name` tippen. Schreibe die Beschreibung als Verweis mit einem Trigger pro Zweig.
- **User-invoked** (vom Nutzer ausgelöst): Nur der Nutzer startet ihn. Keine Context load, aber der Nutzer muss wissen, dass es ihn gibt. Claude: `disable-model-invocation: true` im Frontmatter, die Beschreibung als einzeilige menschliche Zusammenfassung. Codex: `agents/openai.yaml` mit `policy: allow_implicit_invocation: false`.

Wähle model-invoked nur, wenn der Agent oder ein anderer Skill den Skill von allein erreichen muss. Unsere Grundlagen-Skills bleiben model-invoked (siehe `.out-of-scope/` im Repo Claude_Skills).

## Nach Aufruf aufteilen

Teile einen model-invoked Skill nur auf, wenn ein eigenes Leitwort ihn allein auslösen soll oder wenn ein anderer Skill ihn erreichen muss. Jede neue Beschreibung ist dauerhafte Context load.

## Claude und Codex als Paar

Skills liegen im Repo Claude_Skills: `claude-skills/<skill>/`, `codex-skills/<skill>/`, gemeinsame Dateien in `shared/<skill>/`. `~/.claude/skills/` und `~/.codex/skills/` enthalten Symlinks auf sie, ein neuer Skill braucht je einen.

Ein Codex-Zwilling weicht vom Claude-Skill in diesen Punkten ab. Prüfe jeden einzeln:

- **Sprache und Stil**: Deutsch. Keine Gedankenstriche als Satzzeichen, keine Semikola, Abkürzungen einmal ausschreiben.
- **Aufruf**: Claude nutzt `disable-model-invocation: true` im Frontmatter. Codex kennt diesen Schlüssel nicht. Ein vom Nutzer ausgelöster Zwilling bekommt `agents/openai.yaml` mit `policy: allow_implicit_invocation: false` und `interface` (`display_name`, `short_description`).
- **Fragen an den Nutzer**: kein `AskUserQuestion`. Frage im Klartext, Runden wie im Zwilling von grilling.
- **Subagenten und Modellwahl**: kein `Agent`, keine Modellwahl. Delegiere nur, wenn der Nutzer es verlangt.
- **Gedächtnis**: Codex hat den agentmemory-MCP-Server und den Shell-Befehl `am-search`. Nutze `memory_save` und `am-search` wie im Claude-Skill, mit denselben `project`-Werten. Codex lädt den Werkzeugsatz `core`: `memory_save`, `memory_recall`, `memory_smart_search` und `memory_sessions` gibt es, `memory_lesson_save` nicht. Eine Lesson schreibst du dort als `memory_save` mit `type` = `fact` und `lesson` in `concepts`.
- **Pfade**: `~/.codex/skills`, `~/.codex/sessions`, `~/.codex/config.toml`, `~/.codex/AGENTS.md` statt der `~/.claude`-Entsprechungen. Nenne beide Seiten, wenn der Skill Logs beider Werkzeuge liest.
- **Gemeinsame Dateien**: verweise relativ zum Skill-Ordner als `../../shared/<skill>/`.
- **Selbstprüfung**: suche im Zwilling mit grep nach Claude-only-Namen (`AskUserQuestion`, `Agent`, `disable-model-invocation`, `~/.claude`) und führe `shared/scripts/stilpruefung.sh` für Gedankenstriche und Semikola aus.
- Prüfe nach einer Änderung an einem Zwilling, ob der andere dieselbe Änderung braucht.
