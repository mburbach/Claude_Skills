---
name: jira-ticket-authoring
description: Draft, review, extend and create Jira issues (Epics, Tasks, Stories, Sub-Tasks, Bugs) using a consistent internal template (Ziel/Kontext/Aufgaben/Akzeptanzkriterien/Technische Hinweise, plus a separate structure for bug reports), a plain writing style without dashes or semicolons, a structured review pass (Schnitt, Vollständigkeit, Subtasks) and a strict draft-then-confirm workflow where nothing reaches Jira unconfirmed. Use this whenever the user asks to create, draft, plan, restructure, review, break down or extend Jira tickets, tasks, user stories, subtasks, bugs or epics, including requests like "leg dafür ein Jira-Ticket an", "wie bilden wir das in Jira ab", "erstelle Subtasks für X", "schau dir das Ticket nochmal an", "ergänze CD-83 um ..." oder "das sollten wir als Epic anlegen", even if they don't mention this skill by name. Always use this instead of calling Jira create/edit tools directly.
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

Once confirmed, write these coordinates into the project memory: site and cloud ID, project key, board, the actual name of the subtask type in that project, the language the team writes tickets in, and any team convention on ticket size or summary format. They are stable per project, and looking them up again costs a round trip in every new session. Update the memory entry when something changes instead of adding a second one.

**2. Research before drafting.**
- Search for existing related or duplicate issues, so nothing already present gets recreated. Offer to update the existing issue instead.
- Identify the right parent. For a Task, check whether an Epic already fits by searching or inspecting parents of sibling tickets in the same area. For Sub-Tasks, the exact parent issue key is required.
- Look up the project's **actual** issue type names before creating anything, for example via the Jira "get project issue types" capability. The subtask type is not reliably called "Sub-Task" everywhere. It can be localized, for example "Unteraufgabe", or renamed. Never assume, verify per project.

**3. Draft, don't create.** Write out every issue you intend to create: summary, issue type, parent/epic, labels, and the full description using the template below. Do this as a normal chat message, not as a tool call.

**4. Review the draft.** Run the review pass described in "Review pass" over the complete draft before showing it. Present the draft and the review findings together in one message.

**5. Present and wait for explicit confirmation.** Show the user the drafted list before calling any create/edit tool. This applies to *every* batch of tickets, not just once per conversation. Agreeing to a plan is not the same as approving the exact tickets that implement it.

Nothing reaches the target system without a confirmation for exactly that content. This covers creating issues, editing existing ones, comments, issue links, labels and status transitions. If the user changes something after seeing the draft, show the changed items again in their final form and wait again. A change request is an instruction, not an approval of the result. When only part of the batch changed, re-show only that part and state plainly that the rest is unchanged. If the user asks for an Epic and none of the existing ones fit, propose a concrete name and description and get a decision before creating it. Don't default to creating one silently, and don't default to reusing an ill-fitting existing Epic either.

**6. Create in dependency order.** Epic before its children. Parent Task before its Sub-Tasks, because Sub-Tasks require an existing parent key at creation time. If several issues reference each other, for example "siehe CD-83", create the referenced one first so you can link by key. Set the issue links afterwards, see "Verlinkung".

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
- **Spell out technical abbreviations once per ticket**, at the first occurrence, with the long form in parentheses right after it, for example "SSO (Single Sign-on)" or "JPA (Java Persistence API)". Use the short form for the rest of the ticket. Skip this only for abbreviations the whole team reads every day, such as API or URL. The test is whether someone who joined the team this month would have to look it up. Domain and project abbreviations count too, not just technical ones.

**Language:** match whatever language the project and user already use for tickets. Don't default to English if the team writes in German, or the other way round. Check a couple of existing issues in the project if unsure.

**Self-check before presenting:** scan the drafted text for the characters `—`, `–`, ` - ` and `;`. If any appear outside a compound word, rewrite that sentence. Do not just swap the character for a comma when the sentence was only holding together because of it, restructure it.

## Summaries

The summary is the one line that shows up on the board, in the backlog, in every filter and in every notification. Most people never open the description, so the summary has to carry the ticket on its own.

The form follows the issue type, because the types are different kinds of thing. An Epic is a theme, a Task is an assignment, a Bug is an observation.

- **Epic: nominal.** "Mandantenfähigkeit der Beihilfeberechnung", not "Beihilfeberechnung mandantenfähig machen". An Epic runs for months and describes an area, so a verb makes it sound like a single step.
- **Story, Task and Sub-Task: verb in the infinitive at the end, object first.** "Löschfristenjob auf Mandantentrennung umstellen", "JWTUtil threadsicher machen". Putting the object first keeps the distinguishing noun in the leftmost column of the backlog, where a nominal summary would show "Umstellung" or "Anpassung" for the twentieth time in a row.
- **Bug: a declarative sentence in the present tense** that states the wrong behavior. "Beihilfeberechnung rundet Teilbeträge kaufmännisch statt ab". Never name the suspected fix, because at the time of writing nobody knows whether it is the cause. "Rundung korrigieren" claims a solution the ticket has not earned yet.

The infinitive is not just a style choice. A nominalization hides missing precision, so "Anpassung des Löschfristenjobs" looks like a finished summary while saying nothing. The infinitive forces a real verb, and an empty one like "anpassen" is then obvious at a glance.

Further rules, independent of type:

- One line, aim for under roughly 70 characters so it is not cut off in board and backlog views. German nominalizations blow through this quickly through genitive chains, which is another reason the infinitive wins for work items.
- Name the outcome, not the activity.
- No issue type in the text ("Task: ...", "Bug: ..."), the type is its own field.
- No filler openers such as "Anpassung von", "Überarbeitung der", "Konzept für".
- A Story keeps the user role out of the summary and puts it into the Ziel, otherwise the sentence gets long. "Massenfreigabe von Anträgen ermöglichen" instead of "Sachbearbeitern die Massenfreigabe von Anträgen ermöglichen".
- A Sub-Task does not repeat its parent's summary. It names only its own part, and it may drop the verb when the parent already supplies the context, for example "Migrationsskript für Bestandsanträge".
- Component prefixes in brackets only if the project already uses them. Check a handful of existing tickets before introducing a pattern of your own.
- The abbreviation rule from "Writing style" does not apply here. There is no room for it in one line, so the long form goes into the Ziel.

## Ticket description template

Structure every description with these sections, in this order, using real Markdown headers or bold. Omit a section entirely when it doesn't apply, don't write an empty placeholder.

- **Ziel** is one or two sentences on what this achieves and why it is being done, not just what it contains.
- **Kontext** is the background needed to understand the why: constraints, related tickets, prior decisions, risks that motivate this work. Skip it if the Ziel already says everything necessary.
- **Aufgaben** are the concrete work items as a bullet list. If the ticket spans clearly separate areas, for example backend and frontend or two independent components, split into labeled sub-lists (**Aufgaben Backend** / **Aufgaben Frontend**) instead of one flat list. Only do this when the split is real, don't force it for a single-area ticket.
- **Akzeptanzkriterien** are observable, checkable conditions for "fertig". Prefer specific and testable phrasing over vague wording. "Test X ist grün" beats "funktioniert".
- **Technische Hinweise** are implementation pointers worth preserving, such as class or file names, patterns to follow, things to explicitly avoid. Only include this section if there is something concrete to say. It is the first section to drop if the ticket is straightforward.

## Bug-Tickets

A bug report answers different questions than a piece of planned work, so it gets its own structure. Use these sections instead of Ziel/Kontext/Aufgaben.

- **Beobachtetes Verhalten** is what the system actually does, described precisely and without interpretation. Quote the exact message, value or state.
- **Erwartetes Verhalten** is what it should do instead, plus where that expectation comes from: a spec, a ticket, a legal rule, or the behavior before a change.
- **Reproduktion** is a numbered list of steps with concrete test data, followed by how reliably it reproduces (immer, sporadisch, nur mit bestimmten Daten). If it is not reproducible yet, write that down explicitly instead of dropping the section.
- **Umgebung** is whatever is relevant to narrow it down: version or build, stage, browser, database, tenant, user role, time of occurrence.
- **Auswirkung** is who is affected, how often, and what the damage is (falsche Auszahlung, blockierter Prozess, kosmetisch). This is what drives priority, so it is not optional.
- **Analyse** is optional and holds what is already known about the cause: a stack trace excerpt, a suspected code location, a related change. Only write it when there is something concrete.
- **Akzeptanzkriterien** work as usual. For a bug the first one is normally that the reproduction steps no longer produce the wrong behavior, plus a regression test that fails without the fix.

Rules for bug tickets:

- Don't write a solution into the ticket before the cause is understood. If the fix is already clear and agreed, it belongs under Analyse, and the ticket stays a bug instead of turning into a task.
- Missing functionality is not a bug. If nothing ever worked differently, it is a Task or a Story. Decide this before drafting, because it changes the template.
- Several separate defects in the same area are separate tickets, even when they were found in one session. Bundle them only when they share one cause and one fix.

## Bestehende Tickets ändern

Someone else may have written the ticket, and other people may already have read it and planned around it. Editing is additive by default.

- Read the current issue before touching it. Never send a description that was composed without seeing what is in the field right now.
- Add to what is there instead of replacing it. Keep the original wording even when your own phrasing would be tighter. Rewriting a ticket wholesale destroys the record of who meant what, and it makes the change unreviewable for the person who wrote it.
- A full replacement needs an explicit instruction from the user for that specific ticket.
- Show what will change before writing: which section, the current text, the new text. A short before and after is enough, and the confirmation rule from step 5 applies unchanged.
- When the addition is a contribution to the discussion rather than a change to the specification, for example a finding from the review pass on a ticket that belongs to someone else, write a comment instead of editing the description.
- Keep the section order of the template when you add a section that was missing.
- Every edit notifies the watchers. Collect several changes to the same issue into one edit instead of a series of small ones.

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

These signals are heuristics, not thresholds. If the team has its own convention for how big a ticket may be, for example that it has to fit into one sprint or into a fixed number of days, that convention wins over the numbers above. Ask once per project and record the answer in the project memory instead of guessing again every time.

If a split is warranted, propose the concrete new tickets with their summaries and a one-line scope each, plus which existing draft content moves where. Also name the sequencing between them.

For bugs the check runs the other way round. Separate defects stay separate tickets even when they were found together, and only a shared cause justifies one ticket.

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
- The writing style rules hold, in particular no dashes, no semicolons, and every abbreviation that needs it is spelled out once.
- The summary follows the rules in "Summaries" and matches what a reader would expect to find in the description.

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

## Verlinkung

A dependency that lives only in a sentence in a description is invisible on the board, in filters and in every planning view. Real relations belong into issue links.

- Look up which link types the project actually offers before using one, they are configured per site and are often renamed.
- Choose the type by what the relation really is instead of defaulting to "hängt zusammen mit" for everything:
  - **blockiert / wird blockiert von** for a hard order, where one ticket cannot start or cannot finish before the other is done. This is the type to use for the pieces that come out of a split in Check 1.
  - **hängt zusammen mit** for context that is worth knowing without implying an order.
  - **dupliziert** when the same work is already tracked elsewhere. Prefer closing one of the two over keeping both alive and linked.
  - **verursacht** between a change and the bug it produced.
- Parent and child is hierarchy, not a link. Don't model a Sub-Task relation as a "hängt zusammen mit" link on top of it.
- If two tickets could be worked on at the same time by two people, the relation is "hängt zusammen mit", not "blockiert". Blocking claims something stronger than most relations deserve.
- Propose the links in the draft together with the tickets so they are covered by the same confirmation, then create them once the issues exist.
