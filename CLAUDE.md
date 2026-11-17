# Claude_Skills

Skills für Claude Code (`claude-skills/`) und Codex (`codex-skills/`), gemeinsame Dateien in `shared/<skill>/`.

Vor einer Änderung an einem Skill in `.out-of-scope/` nachsehen, ob die Idee schon einmal abgelehnt wurde. Lehnt Martin eine Idee ab, dort eine kurze Datei nach dem Aufbau in `.out-of-scope/README.md` anlegen.

Für einen Codex-Zwilling gehört der Abschnitt „Claude and Codex pair“ aus `claude-skills/writing-for-agents/SKILL-MECHANICS.md` in jeden Auftrag. Deutschen Skilltext prüft `shared/scripts/stilpruefung.sh`, als pre-commit-Hook einmal pro Klon mit `git config core.hooksPath .githooks` aktivieren.
