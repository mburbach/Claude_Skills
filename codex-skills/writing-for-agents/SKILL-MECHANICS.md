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

- Der Claude-Zwilling ist englisch und nutzt Subagenten, Modellwahl und agentmemory. Dieser Codex-Zwilling ist deutsch und nutzt Subagenten nur, wenn der Nutzer Delegation ausdrücklich verlangt. Er lässt Claude-only-Werkzeuge weg (Agent, agentmemory, Modellwahl).
- Prüfe nach einer Änderung an einem Zwilling, ob der andere dieselbe Änderung braucht.
