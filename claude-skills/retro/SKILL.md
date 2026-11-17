---
name: retro
description: Retrospective on a coding session that proposes fixes to the agent's environment, not the code. Started only by the user with /retro.
disable-model-invocation: true
---

# Retro

Suggest improvements to the agent's **environment** so the next run goes better. Adapted from Matt Pocock's skill (github.com/mattpocock/skills). Everything shown to the user is German, written without dashes as punctuation and without semicolons.

Retro is not a memory. It changes the environment so a mistake cannot happen again. It only proposes. Nothing changes until the user picks.

## Steps

1. Load `subagent-model-choice` before any subagent. It owns the model rules.
2. Read the session. Default is the current one. For an earlier one, find it through the agentmemory session summaries (`am-search`). Claude logs: `~/.claude/projects/<project path with slashes replaced by dashes>/*.jsonl`. Codex logs: `~/.codex/sessions/`. A long log goes to a subagent that reports only the hard moments, each with timestamp and a short quote, never the log.
3. Search agentmemory for lessons on those hard moments: `am-search "<term>"` and `am-search -p global "<term>"`, several short terms. Lessons appear under "Lessons". A lesson that recurs, or was violated again in this session, is a candidate for a permanent fix.
4. Collect candidates from the categories below. Each needs a traceable moment in the session. No moment, no candidate. A smooth session has little to teach: say so and stop.
5. Load `writing-for-agents` only when a candidate will write steering text.
6. Present the candidates and wait for the pick.
7. Implement the picked ones as orchestrator through subagents.

## Categories

- **Navigation**: the agent needed long to find a file or fact. Fix: a **navigation pointer** from a file it already reads. _Use when_ the session took a long time to find a piece of information.
- **Automated checks**: a lint rule, type, test, hook or CI job could have caught the mistake. Read the repo's own check command and CI first, so an existing but unwired or broken check is the finding. A missing guardrail (no pre-commit hook and no CI running lint, typecheck, tests) is a finding only when the session shows a mistake such a check would have caught. _Use when_ the agent made a mistake an automated check could have caught.
- **Coding standards**: the reviewer missed something. Classify first. A **mechanical** violation (fixed pattern, banned API, import shape, file location) gets a deterministic check, not a rule. A **judgement call** (cross-file consistency, matching the surrounding style) becomes a rule in `CODING_STANDARDS.md`. _Use when_ the reviewer failed to catch a mistake.
- **Global CLAUDE.md**: steering that belongs in coding standards or checks. _Use when_ a CLAUDE.md is large, in the project or in the global scope.
- **Tool economy**: expensive tool calls, token-hungry CLIs or MCP servers. _Use when_ the agent made an expensive tool call.
- **No-ops**: steering lines that change no behavior. _Use when_ steering files are large and unwieldy.
- **Information access**: logs, read-only access to services. _Use when_ a crucial piece of information was not available.
- **Model choice and cost**: wrong model, too many subagents. Target is usually the skill `subagent-model-choice`.
- **Memory**: did the agent search before starting, did it redo or re-ask something already stored.
- **Permission prompts**: many approvals. Target is `settings.json`. The built-in `/fewer-permission-prompts` helps.

## Levels

Prefer the lowest level that fits, and a check that fails over a sentence in a file.

1. **Project**: the project's `CLAUDE.md` (navigation pointers only), checks, hooks, docs, `CODING_STANDARDS.md`.
2. **Global**: `~/.claude/CLAUDE.md`, `~/.claude/settings.json`.
3. **Our skills**: repo `Claude_Skills`.
4. **Memory**: last resort. Propose a new lesson only when no environment change fits.

## Output

Candidates K1, K2, ... sorted by frequency (in the session and in lessons), then by damage (a wrong result before time and tokens before comfort). Each in German with: Stelle in der Session, Ebene, Zieldatei, Änderung, Begründung für den Rang. When a fix replaces a lesson, the same candidate retires it. Then the user picks, for example "K1 und K3".

## Implementing

- **Standards live with the reviewer.** The implementing agent carries the most context pressure, the reviewer gets a diff. `CODING_STANDARDS.md` is per project. In a project without `/project-setup` (no `.project-setup.yml`) it is created only when the first reviewer rule exists. The skill `evidence-code-review` reads it when present. Project `CLAUDE.md` loads every session, so it holds navigation pointers only.
- **Level 1**: edit the project files.
- **Level 2**: `~/.claude` is a private git repo (`claude-global`, only whitelisted files tracked). Edit the file, then `git -C ~/.claude commit` directly on main with a message stating what, why and origin (project and session), then `git -C ~/.claude push`. Also `memory_save` with `type` = `decision`, `project` = `global`. A pre-commit hook checks for secrets. If it blocks, stop and tell the user.
- **Level 3**: inside the repo `Claude_Skills`, check `.out-of-scope/`, change the skill on a branch and open a PR. Anywhere else, do not edit skills. File a ticket with `../../shared/retro/scripts/vikunja-ticket.sh` (resolved from this skill directory, created separately). Run `find TERM` first (open tickets: id, identifier, title) and `comment TASK_ID FILE` on a match instead of a duplicate. Otherwise `create TITLE FILE` (Markdown file or `-` for stdin, project "Claude Skills", label `retro`). `done TASK_ID` closes a ticket. Ticket body: project folder, moment in the session, target file, proposed change, reason.
- **Retiring a lesson**: agentmemory has no delete. Save a `memory_save` note with `type` = `fact` and `concepts` including `abgelöst`, naming the lesson id and the fix that replaces it. The old lesson then decays.
