---
name: jira-ticket-authoring
description: Draft and create Jira issues (Epics, Tasks, Stories, Sub-Tasks) using a consistent internal template (Ziel/Kontext/Aufgaben/Akzeptanzkriterien/Technische Hinweise) and a strict draft-then-confirm workflow. Use this whenever the user asks to create, draft, plan, restructure, or break down Jira tickets, tasks, user stories, subtasks, or epics — including requests like "leg dafür ein Jira-Ticket an", "wie bilden wir das in Jira ab", "erstelle Subtasks für X", or "das sollten wir als Epic anlegen" — even if they don't mention this skill by name. Always use this instead of calling Jira create/edit tools directly.
---

# Jira Ticket Authoring

A repeatable workflow for turning a plan, discussion, or feature description into well-formed Jira issues — with a fixed description template and a hard rule that nothing gets written to Jira before the user has seen and approved the exact content.

## Why this exists

Two failure modes this skill exists to prevent, both observed in practice:

1. **Silent ticket creation.** Creating or editing issues is a visible, shared-system action — once created, other people may see it, get notified, or start planning around it. Drafting first and confirming avoids surprising the user with tickets they didn't expect, wrongly scoped tickets, or tickets under the wrong Epic.
2. **Broken formatting.** Passing a description as a single-line string with literal `\n` characters (instead of real line breaks) renders as visible backslash-n text in Jira instead of paragraphs — see "Formatting gotcha" below. This is an easy mistake to make when a tool call is composed as one long string.

## Workflow

**1. Establish the target.** Confirm (or recall from memory/context) the Jira site (cloud ID), project key, and board. Don't re-ask if this is already established for the current project/session.

**2. Research before drafting.**
- Search for existing related or duplicate issues (avoid recreating something that already exists — offer to update it instead).
- Identify the right parent: for a Task, check whether an Epic already fits (search/inspect parents of sibling tickets in the same area). For Sub-Tasks, you need the exact parent issue key.
- Look up the project's **actual** issue type names before creating anything (e.g. via the Jira "get project issue types" capability) — the subtask type is not reliably called "Sub-Task" everywhere (it can be localized, e.g. "Unteraufgabe", or renamed). Never assume; verify per project.

**3. Draft, don't create.** Write out every issue you intend to create: summary, issue type, parent/epic, labels, and the full description using the template below. Do this as a normal chat message — not as a tool call.

**4. Present and wait for explicit confirmation.** Show the user the drafted list before calling any create/edit tool. This applies to *every* batch of tickets, not just once per conversation — agreeing to a plan is not the same as approving the exact tickets that implement it. If the user asks for an Epic and none of the existing ones fit, propose a concrete name + description and get a decision before creating it — don't default to creating one silently, and don't default to reusing an ill-fitting existing Epic either.

**5. Create in dependency order.** Epic before its children. Parent Task before its Sub-Tasks (Sub-Tasks require an existing parent key at creation time). If several issues reference each other (e.g. "see CD-83"), create the referenced one first so you can link by key.

**6. Report back.** After creation, map every created key to its title/role so the user can cross-reference against the draft they approved (e.g. a small table: key → summary → type → parent).

## Ticket description template

Structure every description with these sections, in this order, using real Markdown headers/bold — omit a section entirely (don't write an empty placeholder) when it doesn't apply:

- **Ziel** — one or two sentences: what this achieves and why it's being done, not just what it contains.
- **Kontext** — background needed to understand the *why*: constraints, related tickets, prior decisions, risks that motivate this work. Skip if the Ziel already says everything necessary.
- **Aufgaben** — the concrete work items, as a bullet list. If the ticket spans clearly separate areas (e.g. backend and frontend, or two independent components), split into labeled sub-lists (**Aufgaben Backend** / **Aufgaben Frontend**) instead of one flat list — but only when the split is real; don't force it for a single-area ticket.
- **Akzeptanzkriterien** — observable, checkable conditions for "done." Prefer specific/testable phrasing over vague ones ("Test X ist grün" beats "funktioniert").
- **Technische Hinweise** — implementation pointers worth preserving (class/file names, patterns to follow, things to explicitly avoid) — only include this section if there's something concrete to say; it's the first section to drop if the ticket is straightforward.

Match whatever language the project/user already uses for tickets (don't default to English if the team writes in German, or vice versa) — check a couple of existing issues in the project if unsure.

## Formatting gotcha (read before calling the create/edit tool)

When composing the description parameter for a tool call, write it as genuine multi-paragraph text with real line breaks between sections and bullet points — the same way you'd write a normal chat message. Do **not** build the string by concatenating literal `\n` / `\n\n` characters into what is otherwise a single-line value; several Jira tool integrations render that literally instead of interpreting it as a line break, producing descriptions with visible `\n\n` in them. If you're unsure whether your call will render correctly, create or edit one issue first and read back its rendered description before doing the rest of the batch.

## Issue type & hierarchy notes

- **Epic** — a durable theme/area, not a single deliverable. Only propose creating one when the work doesn't fit any existing Epic; check first.
- **Story** — user-facing functionality framed around a user goal. Use when the project distinguishes Story from Task (not all do — check the project's configured issue types).
- **Task** — a scoped, well-defined piece of work that isn't a user story or a bug.
- **Bug** — an issue tracking incorrect existing behavior, not new work.
- **Sub-Task** — a smaller piece of a single parent Task/Story; always needs a `parent` field set to that parent's key, and its issue type name must be looked up per project (see step 2).

When a body of work is large enough to need internal sequencing (e.g. "this can't start until that other part is done"), prefer modeling that as Sub-Tasks under one parent Task rather than several same-level Tasks — it keeps the dependency visible in Jira's hierarchy instead of only in a description.
