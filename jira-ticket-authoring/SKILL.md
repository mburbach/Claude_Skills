---
name: jira-ticket-authoring
description: Draft, review and create Jira issues (Epics, Tasks, Stories, Sub-Tasks) using a consistent internal template (Ziel/Kontext/Aufgaben/Akzeptanzkriterien/Technische Hinweise), a plain writing style without dashes or semicolons, a structured review pass (Schnitt, Vollständigkeit, Subtasks) and a strict draft-then-confirm workflow. Use this whenever the user asks to create, draft, plan, restructure, review or break down Jira tickets, tasks, user stories, subtasks, or epics, including requests like "leg dafür ein Jira-Ticket an", "wie bilden wir das in Jira ab", "erstelle Subtasks für X", "schau dir das Ticket nochmal an" oder "das sollten wir als Epic anlegen", even if they don't mention this skill by name. Always use this instead of calling Jira create/edit tools directly.
---

# Jira Ticket Authoring

A repeatable workflow for turning a plan, discussion, or feature description into well-formed Jira issues. It combines a fixed description template, a plain writing style, a mandatory review pass over the draft, and a hard rule that nothing gets written to Jira before the user has seen and approved the exact content.

## Why this exists

Failure modes this skill exists to prevent, all observed in practice:

1. **Silent ticket creation.** Creating or editing issues is a visible, shared-system action. Once created, other people may see it, get notified, or start planning around it. Drafting first and confirming avoids surprising the user with tickets they didn't expect, wrongly scoped tickets, or tickets under the wrong Epic.
2. **Broken formatting.** Passing a description as a single-line string with literal `\n` characters instead of real line breaks renders as visible backslash-n text in Jira. See "Formatting gotcha" below.
3. **Machine-sounding text.** Tickets that read like generated text stand out in a backlog written by humans. See "Writing style" below.
4. **Tickets that are too coarse or incomplete.** A ticket that bundles three independent deliverables blocks the board for weeks, and a ticket that quietly drops half of what was discussed causes rework. The review pass in step 4 catches both before anything is created.

## Workflow

**1. Establish the target.** Confirm (or recall from memory/context) the Jira site (cloud ID), project key, and board. Don't re-ask if this is already established for the current project or session.

**2. Research before drafting.**
- Search for existing related or duplicate issues, so nothing already present gets recreated. Offer to update the existing issue instead.
- Identify the right parent. For a Task, check whether an Epic already fits by searching or inspecting parents of sibling tickets in the same area. For Sub-Tasks, the exact parent issue key is required.
- Look up the project's **actual** issue type names before creating anything, for example via the Jira "get project issue types" capability. The subtask type is not reliably called "Sub-Task" everywhere. It can be localized, for example "Unteraufgabe", or renamed. Never assume, verify per project.

**3. Draft, don't create.** Write out every issue you intend to create: summary, issue type, parent/epic, labels, and the full description using the template below. Do this as a normal chat message, not as a tool call.

**4. Review the draft.** Run the review pass described in "Review pass" over the complete draft before showing it. Present the draft and the review findings together in one message.

**5. Present and wait for explicit confirmation.** Show the user the drafted list before calling any create/edit tool. This applies to *every* batch of tickets, not just once per conversation. Agreeing to a plan is not the same as approving the exact tickets that implement it. If the user asks for an Epic and none of the existing ones fit, propose a concrete name and description and get a decision before creating it. Don't default to creating one silently, and don't default to reusing an ill-fitting existing Epic either.

**6. Create in dependency order.** Epic before its children. Parent Task before its Sub-Tasks, because Sub-Tasks require an existing parent key at creation time. If several issues reference each other, for example "siehe CD-83", create the referenced one first so you can link by key.

**7. Report back.** After creation, map every created key to its title and role so the user can cross-reference against the draft they approved, for example a small table with key, summary, type and parent.

## Writing style

These rules apply to everything that ends up in Jira: summaries, descriptions, comments, and acceptance criteria. The goal is text that reads like a colleague wrote it quickly and precisely.

**Hard rules:**

- **No dashes as punctuation.** No em dash, no en dash, and no hyphen used as a sentence break. Split the sentence, use a comma, or use parentheses instead. Hyphens inside compound words stay, so "Multi-Repo" and "E-Mail" are fine, but "Der Import läuft nachts - danach folgt der Export" is not.
- **No semicolons.** Use a period or a comma.
- **No colon inside a running sentence** to introduce an aside. A colon before a list or before an enumeration is fine.
- Write plain declarative sentences. Short is better than balanced.
- No filler openers such as "Im Rahmen dieses Tickets", "Ziel dieses Tickets ist es", "Es gilt zu beachten". Say the thing directly.
- No marketing adjectives ("robust", "nahtlos", "umfassend", "effizient") unless they carry a measurable meaning in context.
- No rhetorical tricolons or "nicht nur X, sondern auch Y" constructions.
- Use the team's vocabulary from existing tickets and from the codebase, not generic synonyms.
- Active voice with a clear actor where an actor exists. Passive is fine for system behavior.

**Language:** match whatever language the project and user already use for tickets. Don't default to English if the team writes in German, or the other way round. Check a couple of existing issues in the project if unsure.

**Self-check before presenting:** scan the drafted text for the characters `—`, `–`, ` - ` and `;`. If any appear outside a compound word, rewrite that sentence. Do not just swap the character for a comma when the sentence was only holding together because of it, restructure it.

## Ticket description template

Structure every description with these sections, in this order, using real Markdown headers or bold. Omit a section entirely when it doesn't apply, don't write an empty placeholder.

- **Ziel** is one or two sentences on what this achieves and why it is being done, not just what it contains.
- **Kontext** is the background needed to understand the why: constraints, related tickets, prior decisions, risks that motivate this work. Skip it if the Ziel already says everything necessary.
- **Aufgaben** are the concrete work items as a bullet list. If the ticket spans clearly separate areas, for example backend and frontend or two independent components, split into labeled sub-lists (**Aufgaben Backend** / **Aufgaben Frontend**) instead of one flat list. Only do this when the split is real, don't force it for a single-area ticket.
- **Akzeptanzkriterien** are observable, checkable conditions for "fertig". Prefer specific and testable phrasing over vague wording. "Test X ist grün" beats "funktioniert".
- **Technische Hinweise** are implementation pointers worth preserving, such as class or file names, patterns to follow, things to explicitly avoid. Only include this section if there is something concrete to say. It is the first section to drop if the ticket is straightforward.

## Review pass

Run this over the finished draft, before the user sees it. Run it again on request for tickets that already exist in Jira, in that case fetch the issue first and report findings as suggested edits.

Review each drafted issue against the four checks below, then report. The review reports and proposes, it never silently rewrites an approved draft or creates additional issues on its own.

### Check 1: Schnitt

Ask whether this ticket should be more than one ticket. Concrete split signals:

- The summary needs an "und" or a comma to describe the work.
- Two or more Akzeptanzkriterien can be met, tested and shipped independently of each other.
- The Aufgaben list covers areas that different people would work on in parallel without talking to each other.
- Parts of the ticket are blocked by different prerequisites, so one half could start today and the other only in three weeks.
- The Aufgaben list is longer than roughly eight items, or the work is clearly more than a few days.
- The ticket mixes a functional change with an unrelated refactoring, cleanup or upgrade.

If a split is warranted, propose the concrete new tickets with their summaries and a one-line scope each, plus which existing draft content moves where. Also name the sequencing between them.

Counter-check before proposing: a split is wrong when the parts cannot be released or tested separately, when it produces a ticket that only makes sense together with its sibling, or when it just mirrors the technical layers of a single small change.

### Check 2: Vollständigkeit

Go back to the source material, the conversation, the spec, the Confluence page, the code that was looked at, and compare it against the draft. Report anything discussed or implied that has no home in any ticket.

Aspects that are typically forgotten, check each one and only report the ones that actually apply:

- Tests, both new tests and existing tests that need adjustment
- Datenmigration or backfill for existing records
- Konfiguration, feature flags, environment variables, secrets
- Berechtigungen and roles
- Fehlerbehandlung and the behavior in the failure case
- Logging, monitoring, alerting
- Dokumentation, both internal and user-facing
- Abwärtskompatibilität, API versioning, other consumers of the changed component
- Rollout, deployment order, downtime, rollback
- Übersetzungen and texts in the UI
- Löschfristen, retention, data protection where personal data is touched

Also check the inverse direction: does the draft contain Aufgaben that nobody asked for, and does every Akzeptanzkriterium have a matching Aufgabe and the other way round.

### Check 3: Subtasks

Propose Sub-Tasks when the ticket stays one deliverable but has internal structure worth tracking:

- There is a required order inside the ticket, so one part cannot start before another is done.
- Several people can work on parts of it in parallel and want their own item.
- The ticket runs long enough that a single "In Arbeit" status hides all progress.
- A part of the work has its own review or handover, for example a schema change that another team has to approve.

Do not propose Sub-Tasks when they would only mirror the Aufgaben list one to one, when the ticket is done in a day, or when each subtask would be a single commit. In those cases the Aufgaben bullets already do the job.

For every proposed Sub-Task give a summary and one line of scope, so the user can approve them directly into step 6.

### Check 4: Konsistenz und Stil

- Ziel, Aufgaben and Akzeptanzkriterien describe the same piece of work, without one of them being wider than the others.
- The summary matches what the description actually asks for.
- Parent, issue type and labels fit the content.
- Every reference to another ticket uses a real key that exists.
- The writing style rules hold, in particular no dashes and no semicolons.

### Review output format

Report compactly after the draft, in the language of the conversation. Skip a check completely when it found nothing, and write one line saying the review found nothing when all four are clean.

```
## Review

**Schnitt:** <finding and concrete proposal, or omit>
**Vollständigkeit:** <what is missing, or omit>
**Subtasks:** <proposed subtasks with scope, or omit>
**Konsistenz:** <finding, or omit>

**Offene Entscheidungen:** <numbered list of the decisions the user has to make before creation>
```

Keep the open decisions to real forks, so the user can answer them in one message. Everything you can decide yourself, decide and mention it in one line instead of asking.

## Formatting gotcha (read before calling the create/edit tool)

When composing the description parameter for a tool call, write it as genuine multi-paragraph text with real line breaks between sections and bullet points, the same way you'd write a normal chat message. Do **not** build the string by concatenating literal `\n` or `\n\n` characters into what is otherwise a single-line value. Several Jira tool integrations render that literally instead of interpreting it as a line break, which produces descriptions with visible `\n\n` in them. If you are unsure whether your call will render correctly, create or edit one issue first and read back its rendered description before doing the rest of the batch.

## Issue type & hierarchy notes

- **Epic** is a durable theme or area, not a single deliverable. Only propose creating one when the work doesn't fit any existing Epic, and check first.
- **Story** is user-facing functionality framed around a user goal. Use it when the project distinguishes Story from Task, which not all projects do. Check the project's configured issue types.
- **Task** is a scoped, well-defined piece of work that is neither a user story nor a bug.
- **Bug** tracks incorrect existing behavior, not new work.
- **Sub-Task** is a smaller piece of a single parent Task or Story. It always needs a `parent` field set to that parent's key, and its issue type name must be looked up per project, see step 2.

When a body of work is large enough to need internal sequencing, for example "this can't start until that other part is done", prefer modeling that as Sub-Tasks under one parent Task rather than several same-level Tasks. That keeps the dependency visible in Jira's hierarchy instead of only in a description.
