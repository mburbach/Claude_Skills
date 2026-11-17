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

- The Codex twin is written in German and uses no subagents unless the user asks for delegation. It leaves out Claude-only tools (Agent, agentmemory, model choice).
- After changing one twin, check whether the other needs the same change.
