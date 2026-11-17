---
name: writing-for-agents
description: Writing guide for documents an agent reads. Use when creating, editing or reviewing a skill, a CLAUDE.md or AGENTS.md, or a doc that one of them points to.
---

# Writing for Agents

Reference for any document an agent consumes: a skill, a `CLAUDE.md` or `AGENTS.md`, a doc reached by a pointer. Adapted from Matt Pocock's skill (github.com/mattpocock/skills). The goal is a predictable **process**: the agent takes the same path every run.

When the document is a skill, also read `SKILL-MECHANICS.md` in this folder (frontmatter, invocation, the Claude and Codex pair).

## Two loads

- **Context load**: always-loaded material (a skill description, every `CLAUDE.md` line) costs tokens and attention on every turn, whether it fires or not.
- **Cognitive load**: the human has to remember which documents exist and when to reach for them. Spend it where human judgement matters.

Measure before and after a change: `wc -c SKILL.md` and the length of the `description` line.

## Pointers

A **pointer** names out-of-context material and the condition for reaching it. A skill description is one, so is a `CLAUDE.md` line naming a doc. Its wording decides when the agent reaches the material. Sharpen a weak pointer before inlining its target.

- **Front-load the leading word.** The first words do the triggering.
- **One trigger per branch.** A branch is a distinct case the document handles. Phrases that rename one branch are one trigger. Keep a second phrasing only when the user really writes both, for example a German and an English one.
- **Cut identity the body already carries.**

## Hierarchy

Rank every piece by how immediately the agent needs it:

1. **Steps** in the main file: what the agent does, in order.
2. **Reference** in the main file: rules and facts consulted on demand.
3. **Disclosed reference** in a separate file behind a pointer, loaded only when the pointer fires.

**Branching test:** inline what every branch needs, disclose what only some branches reach. **Co-location:** keep a concept's definition, rules and caveats under one heading. **Sprawl** is the failure mode: a file so long that attention thins, even when every line is live. The cure is disclosure and splitting by branch.

## Steps and completion criteria

Every step ends on a **completion criterion** the agent can check. A vague bound ("understanding reached") invites **premature completion**, because the steps still ahead pull attention to being done. Sharpen the bound first. Only if it stays fuzzy and you see the rush, move the later steps behind a real context boundary (a subagent or a hand-off). Demanding criteria ("every modified model accounted for") drive legwork that "produce a change list" does not. The strongest criteria are checkable and exhaustive.

Split a document by sequence only when later steps tempt the agent to rush the current one.

## Leading words

A **leading word** is a compact concept the model already knows (_red_, _tight_, _tracer bullet_, _lesson_). Repeated as a token, it anchors a whole region of behaviour in few tokens. Collapse a triad or a gesturing sentence into one: "fast, deterministic, low-overhead" becomes a _tight_ loop. Prefer an existing word to a coined one.

**Positive over negative.** A prohibition puts the forbidden behaviour into context. State the target behaviour instead ("write one-line comments"). Keep a prohibition only as a hard guardrail, for example against live-system changes, and pair it with the positive target.

## Pruning

Hunt sentence by sentence:

- **Single source of truth.** Each meaning lives in one place. A Claude skill and its Codex twin share files through `shared/<skill>/` instead of copies.
- **Cache.** A line that restates config, `--help` output or the directory layout goes stale. Keep only what looking cannot find: the unwritten convention, the reason behind a choice, the gotcha.
- **No-op.** A sentence the model obeys by default changes nothing. Delete the whole sentence. A leading word too weak to beat the default (_be thorough_) needs a stronger word (_relentless_).
- **Sediment.** Delete lines that went stale or never bore on the task.

Texts the agent writes in Martin's name follow his style: no dashes as sentence separators, no semicolons, abbreviations spelled out once.
