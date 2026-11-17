# Skill mechanics

The skill branch of `writing-for-agents`. Everything else about the writing is in `SKILL.md`.

## Invocation

- **Model-invoked** (default): the `description` stays loaded in every session, so the agent and other skills can reach it. The user can still type `/name`. Write the description as a pointer with one trigger per branch.
- **User-invoked**: only the user starts it. Zero context load, but the user must remember it exists. Claude: `disable-model-invocation: true` in the frontmatter, description as a one-line human summary. Codex: `agents/openai.yaml` with `policy: allow_implicit_invocation: false`.

Pick model-invoked only when the agent or another skill must reach the skill on its own. Our foundational skills stay model-invoked (see `.out-of-scope/` in the Claude_Skills repo).

## Split by invocation

Split off a model-invoked skill only for a distinct leading word that should trigger it on its own, or when another skill must reach it. Each new description is permanent context load.

## Claude and Codex pair

Skills live in the repo Claude_Skills: `claude-skills/<skill>/`, `codex-skills/<skill>/`, shared files in `shared/<skill>/`. `~/.claude/skills/` and `~/.codex/skills/` hold symlinks to them, a new skill needs one in each.

A Codex twin differs from its Claude skill in these points. Check each one:

- **Language and style**: German. No dashes as sentence separators, no semicolons, abbreviations spelled out once.
- **Invocation**: Claude uses `disable-model-invocation: true` in the frontmatter. Codex has no such key. A user-invoked twin gets `agents/openai.yaml` with `policy: allow_implicit_invocation: false` and `interface` (`display_name`, `short_description`).
- **User questions**: no `AskUserQuestion`. Ask in plain text, rounds as in the grilling twin.
- **Subagents and model choice**: no `Agent`, no model choice. Delegate only when the user asks for it.
- **Memory**: Codex has the agentmemory MCP server and the `am-search` shell command. Use `memory_save` and `am-search` as in the Claude skill, with the same `project` values. Codex loads the `core` tool set: `memory_save`, `memory_recall`, `memory_smart_search` and `memory_sessions` exist, `memory_lesson_save` does not. Write a lesson there as `memory_save` with `type` = `fact` and `lesson` in `concepts`.
- **Paths**: `~/.codex/skills`, `~/.codex/sessions`, `~/.codex/config.toml`, `~/.codex/AGENTS.md` instead of the `~/.claude` equivalents. Mention both sides when the skill reads logs of both tools.
- **Shared files**: reference them as `../../shared/<skill>/` relative to the skill folder.
- **Self-check**: grep the twin for Claude-only names (`AskUserQuestion`, `Agent`, `disable-model-invocation`, `~/.claude`) and run `shared/scripts/stilpruefung.sh` for dashes and semicolons.
- After changing one twin, check whether the other needs the same change.
