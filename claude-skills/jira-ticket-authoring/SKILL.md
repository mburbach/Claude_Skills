---
name: jira-ticket-authoring
description: Drafts, reviews, extends and creates Jira tickets (Epics, Tasks, Stories, Sub-Tasks, Bugs) with the internal template and a draft-then-confirm workflow where nothing reaches Jira unconfirmed. Use this whenever the user asks to create, draft, plan, restructure, review, break down or extend Jira tickets, tasks, user stories, subtasks, bugs or epics, including requests like "leg dafür ein Jira-Ticket an", "wie bilden wir das in Jira ab", "erstelle Subtasks für X", "schau dir das Ticket nochmal an", "ergänze CD-83 um ...", or "das sollten wir als Epic anlegen", even if they don't mention this skill by name. Always use this instead of calling Jira create/edit tools directly.
---

# Jira Ticket Authoring

Turns a plan, discussion or feature description into well-formed Jira issues: a fixed description template, a plain writing style, a review pass over the draft, and one hard rule.

**Nothing is written to Jira before the user has seen and approved the exact content.** Creating or editing issues is a visible action in a shared system. Others get notified or plan around the result.

Other failure modes this skill prevents: broken formatting (see "Formatting gotcha"), machine-sounding text (see "Writing style" and "Wie ein Kollege schreibt"), tickets that are too coarse or drop half of what was discussed (review pass), growing Akzeptanzkriterien lists, and keys of other tickets inside descriptions.

## Further files

Read these when the condition applies, they sit next to this file:

- `bug-tickets.md`: when a ticket is a bug report (step 3 and the template).
- `existing-tickets.md`: when changing, extending or commenting on a ticket that already exists in Jira, and when the review pass runs on an existing ticket (suggested edit versus comment on someone else's ticket).
- `linking.md`: when the draft proposes issue links (link type choice) and when creating them.

## Workflow

**1. Establish the target.** Confirm (or recall from memory/context) the Jira site (cloud ID), project key and board. Don't re-ask if already established for the project or session. Once confirmed, write these into the project memory: site and cloud ID, project key, board, the actual name of the subtask type, the language the team writes tickets in, and any team convention on ticket size or summary format. Update the entry when something changes instead of adding a second one.
Done when site, project key and board are known.

**2. Research before drafting.**
- Search for existing related or duplicate issues, and offer to update the existing issue instead of recreating it.
- Identify the right parent. For a Task, check whether an Epic already fits by searching or inspecting parents of sibling tickets. For Sub-Tasks the exact parent issue key is required.
- Look up the project's **actual** issue type names before creating anything, for example with the Atlassian plugin via `executeRead` and `listJiraProjectIssueTypesMetadata`. The subtask type can be localized ("Unteraufgabe") or renamed. Verify per project.
Done when duplicates were searched, the parent is named (or it is stated that no Epic fits) and the type names are verified.

**3. Draft, don't create.** Write out every issue as a normal chat message, not a tool call: summary, issue type, parent/epic, labels, the full description using the template below, and the proposed issue links.
Decide the issue type first:
- **Epic** is a durable theme or area, not a single deliverable. Only propose creating one when the work doesn't fit any existing Epic.
- **Story** is user-facing functionality framed around a user goal. Use it when the project distinguishes Story from Task, which not all projects do.
- **Task** is a scoped, well-defined piece of work that is neither a user story nor a bug.
- **Bug** tracks incorrect existing behavior, not new work. Missing functionality is not a bug: if nothing ever worked differently, it is a Task or a Story. Decide this before drafting, because it changes the template. Before drafting a bug from someone else's report, try to reproduce it from the given steps or check the claim in the code, and say in the draft whether it was confirmed, failed or could not be checked.
- **Sub-Task** is a smaller piece of a single parent Task or Story, always with `parent` set to that parent's key. When a body of work needs internal sequencing, prefer Sub-Tasks under one parent Task over several same-level Tasks.

For bug reports use the structure in `bug-tickets.md` instead of the template below. When the draft proposes issue links, read `linking.md` for the link type choice.
Done when every issue to be created is written out in full.

**4. Review the draft.** Run the "Review pass" below over the complete draft. Present draft and findings together in one message.

**5. Present and wait for explicit confirmation.** Show the drafted list before calling any create/edit tool, for *every* batch, not once per conversation. Agreeing to a plan is not approving the exact tickets.

Nothing reaches the target system without a confirmation for exactly that content. This covers creating issues, editing, comments, issue links, labels and status transitions. If the user changes something after seeing the draft, show the changed items again in their final form and wait again. A change request is an instruction, not an approval of the result. When only part of the batch changed, re-show only that part and state that the rest is unchanged. If an Epic is requested and none of the existing ones fit, propose a concrete name and description and get a decision first. Don't create one silently, and don't reuse an ill-fitting one by default.

**6. Create in dependency order.** Epic before its children, parent Task before its Sub-Tasks (they need an existing parent key). Set the issue links once all issues of the batch exist, following `linking.md`.

**7. Report back.** Map every created key to its title and role, for example a small table with key, summary, type and parent, so the user can cross-reference against the approved draft.

## Writing style

Applies to everything that ends up in Jira: summaries, descriptions, comments, acceptance criteria. The text reads like a colleague wrote it quickly and precisely.

- **No dashes as punctuation.** No em dash, no en dash, no hyphen as a sentence break. Split the sentence, use a comma or parentheses. Hyphens inside compound words stay ("Multi-Repo", "E-Mail"), but "Der Import läuft nachts - danach folgt der Export" is not allowed.
- **No semicolons.** Use a period or a comma.
- **No colon inside a running sentence** to introduce an aside. A colon before a list or enumeration is fine.
- Plain declarative sentences, short over balanced.
- No filler openers ("Im Rahmen dieses Tickets", "Ziel dieses Tickets ist es", "Es gilt zu beachten").
- No marketing adjectives ("robust", "nahtlos", "umfassend", "effizient") unless they carry a measurable meaning.
- No rhetorical tricolons or "nicht nur X, sondern auch Y".
- Use the team's vocabulary from existing tickets and the codebase.
- Active voice with a clear actor where one exists. Passive is fine for system behavior.
- **Spell out technical abbreviations once per ticket** at the first occurrence, long form in parentheses right after it, for example "SSO (Single Sign-on)" or "JPA (Java Persistence API)". Skip it only for abbreviations the whole team reads every day, such as API or URL. Test: would someone who joined this month have to look it up? Domain and project abbreviations count too.

**Language:** match the language the project and user already use for tickets. Check a couple of existing issues if unsure.

**Self-check before presenting:** scan the draft for `—`, `–`, ` - ` and `;`. If any appear outside a compound word, rewrite the sentence. Where the sentence only held together because of the character, restructure it instead of swapping in a comma.

## Summaries

The summary shows on the board, in the backlog, in filters and in notifications. Most people never open the description, so it carries the ticket on its own.

**Knapp und trotzdem passend.** The summary names what is inside this ticket, not the category it belongs to. Both failure directions are common:

- Too vague. "Löschfristen anpassen" or "Refactoring Antragsservice" could sit on fifteen different tickets. If another ticket in the same area could carry the same summary word for word, it is not a summary yet, it is a label for the area.
- Too full. The whole description squeezed into one line. If the summary needs a subordinate clause or an "und" to stay accurate, the detail belongs into the Ziel, or the ticket needs a split (Check 1).

Aim for the shortest wording that still says what is inside. Cut whatever the reader already gets from project, component, Epic or parent, and keep exactly what distinguishes this ticket from the ones next to it.

Test before presenting: read the summary on its own, without the description. Someone who knows the project has to be able to say what will be different once the ticket is done. If they can only name the area it touches, the summary is still a category and needs another pass. This applies to Epics, Stories and Tasks alike, only the grammatical form differs.

The form follows the issue type, because the types are different kinds of thing. An Epic is a theme, a Task is an assignment, a Bug is an observation.

- **Epic: nominal.** "Mandantenfähigkeit der Beihilfeberechnung", not "Beihilfeberechnung mandantenfähig machen". An Epic runs for months and describes an area, so a verb makes it sound like a single step.
- **Story, Task and Sub-Task: verb in the infinitive at the end, object first.** "Löschfristenjob auf Mandantentrennung umstellen", "JWTUtil threadsicher machen". Putting the object first keeps the distinguishing noun in the leftmost column of the backlog, where a nominal summary would show "Umstellung" or "Anpassung" for the twentieth time in a row.
- **Bug: a declarative sentence in the present tense** that states the wrong behavior. "Beihilfeberechnung rundet Teilbeträge kaufmännisch statt ab". Never name the suspected fix, because at the time of writing nobody knows whether it is the cause. "Rundung korrigieren" claims a solution the ticket has not earned yet.

Further rules, independent of type:

- One line, aim for under roughly 70 characters so it is not cut off in board and backlog views.
- Name the outcome, not the activity.
- No issue type in the text ("Task: ...", "Bug: ..."), the type is its own field.
- No filler openers such as "Anpassung von", "Überarbeitung der", "Konzept für".
- A Story keeps the user role out of the summary and puts it into the Ziel, otherwise the sentence gets long. "Massenfreigabe von Anträgen ermöglichen" instead of "Sachbearbeitern die Massenfreigabe von Anträgen ermöglichen".
- A Sub-Task does not repeat its parent's summary. It names only its own part, and it may drop the verb when the parent already supplies the context, for example "Migrationsskript für Bestandsanträge".
- Component prefixes in brackets only if the project already uses them. Check a handful of existing tickets before introducing a pattern of your own.
- The abbreviation rule from "Writing style" does not apply here. There is no room for it in one line, so the long form goes into the Ziel.

## Ticket description template

For bug reports use the structure in `bug-tickets.md` instead of this template.

Structure every description with these sections, in this order, using real Markdown headers or bold. Omit a section entirely when it doesn't apply, don't write an empty placeholder.

- **Ziel** is one or two sentences on what this achieves and why it is being done, not just what it contains.
- **Kontext** is the background needed to understand the why: constraints, prior decisions, risks that motivate this work. Write it as two or three plain sentences, not as a bullet list. Skip it if the Ziel already says everything necessary. If the ticket changes existing behavior, state the current behavior (Ist) and the target behavior (Soll) in one sentence each.
- **Aufgaben** are the concrete work items as a bullet list, written like short working notes a colleague would jot down. If the ticket spans clearly separate areas, for example backend and frontend or two independent components, split into labeled sub-lists (**Aufgaben Backend** / **Aufgaben Frontend**) instead of one flat list. Only do this when the split is real, don't force it for a single-area ticket.
- **Akzeptanzkriterien** are the few observable conditions that decide whether the ticket is done. Specific and testable beats vague, so "Test X ist grün" beats "funktioniert". Keep the list short, see "Akzeptanzkriterien kurz halten".
- **Nicht im Umfang** lists what a reader might expect here but is deliberately left out, one line each, with the ticket or reason if there is one. Only include it when a real boundary is unclear, it prevents scope creep in implementation and review.
- **Technische Hinweise** are implementation pointers worth preserving, such as class or file names, patterns to follow, things to explicitly avoid. Name them without explaining around them. Only include this section if there is something concrete to say. It is the first section to drop if the ticket is straightforward.

## Wie ein Kollege schreibt

The writing style rules work on the sentence level. Generated text is often recognizable by its structure instead, even when every single sentence is clean. Watch for these patterns in Kontext, Aufgaben, Akzeptanzkriterien and Technische Hinweise:

- Every bullet has the same length and the same build, often with a bold keyword and a colon at the start. Real notes are uneven, some bullets are three words and some are a full sentence.
- Aufgaben start with the same stereotyped phrase, such as "Sicherstellen, dass …", "Implementierung von …" or "Anpassung der …". Write what is done: "Rundung in BeihilfeRechner auf abrunden umstellen".
- Hedges without a real condition, such as "gegebenenfalls", "bei Bedarf" or "falls erforderlich". Either the condition is known and gets named, or the item is in scope, or it goes.
- Explanations of things the team already knows, for example what a feature flag is.
- Headings or bold labels inside a section that has only three lines.

Test: would a developer in the team have written this ticket in this form in five minutes? If the text looks more polished than the tickets around it in the backlog, it is too polished.

## Jede Information einmal

Every piece of information appears once in the ticket, in the section where it belongs. A reader who finds it twice looks for the difference.

Typical duplicates:

- The Kontext restates the Ziel in other words. Keep it in the Ziel and let the Kontext carry only the background.
- The Technische Hinweise repeat Aufgaben with class names added. Put the class name into the Aufgabe and drop the hint.
- Akzeptanzkriterien restate Aufgaben, see "Akzeptanzkriterien kurz halten".

Hints that would fit any ticket carry no information and get deleted, for example "bestehende Funktionalität darf nicht beeinträchtigt werden", "Clean Code beachten", "Tests schreiben" or "mit dem Team abstimmen". The same goes for a hint that only repeats a team convention everybody follows anyway. Only write down what is specific to this ticket.

## Keine Verweise auf andere Tickets

Descriptions contain no references to other tickets, neither as a key nor as a paraphrase like "siehe die Story zur Oberfläche". There is no exception to this rule, for no issue type.

A reference suggests that part of the work is hidden in the other ticket. Tickets have to be understandable on their own.

- Relations between tickets go into issue links, see "Verlinkung" in `linking.md`. The board and the filters show them there, and they don't pretend to be part of the description.
- If something from another ticket is needed to understand this one, for example a decision made there, take over the content and summarize it in one sentence in the Kontext, without the key.
- State the scope boundary as a fact about this ticket. "Die Oberfläche bleibt unverändert" instead of "Oberfläche siehe CD-91". The reader learns what is out of scope without being sent somewhere else.
- The same applies to Epics, Sub-Tasks and bug reports. A Sub-Task does not point to its siblings, and a bug names the causing change in the Analyse by content, while the relation itself becomes a "verursacht" link.

## Akzeptanzkriterien kurz halten

Long criteria lists are the most common defect in our tickets. Every line has to be checked at acceptance, discussed in refinement and kept in sync, and a ticket with twelve criteria gets skimmed.

**Target three criteria, five is the ceiling.** For a Sub-Task one is often enough. If you cannot get under six, that is a finding, not a formatting problem. Either the ticket is too big and Check 1 applies, or most of the lines are not acceptance criteria at all.

What earns a line:

- The condition can be checked from the outside, by looking at the running system, a test result or an artefact. Not by reading the diff.
- It could plausibly fail. A criterion nobody would ever mark as not met carries no information.
- It is what the reviewer would actually look at first when the ticket lands in review.

What does not earn a line, and where it goes instead:

- A restatement of an Aufgabe. If the criterion is the task written in the perfect tense, delete it. The Aufgaben list already says the work has to happen.
- Standard practice the team applies to every ticket anyway, for example "Code ist reviewed", "Build läuft durch", "keine neuen Warnungen". That belongs into the Definition of Done, not into the ticket. Only write it down when this ticket needs something the Definition of Done does not cover.
- Implementation detail, for example which class holds the new method. That is a Technischer Hinweis.
- A wish that is not part of this ticket, for example performance targets nobody measured. Either it is in scope and gets an Aufgabe, or it is out of scope and gets its own ticket.

Merge before you cut. Criteria that always pass together or fail together are one criterion, so three lines about the same import run become "Der Import verarbeitet die Bestandsdatei ohne Fehler und protokolliert die Anzahl der übernommenen Sätze". Cutting a real condition to hit the number is worse than five good lines.

Tests are covered by one line, not by one line per test. "Die Regressionstests für die Rundung sind grün" is enough, the test names belong into the Aufgaben or into Technische Hinweise.

## Review pass

Run this over the finished draft before the user sees it. Run it again on request for tickets that already exist in Jira, in that case fetch the issue first and report findings as suggested edits.

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

Prefer vertical cuts, where each piece delivers something that can be shown or tested end to end on its own. For a broad refactoring across many places, cut along expand and contract: introduce the new form next to the old, move the callers in batches, then remove the old form.

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

Completeness is not a reason to add criteria. Something that is missing gets an Aufgabe, and only the few conditions from "Akzeptanzkriterien kurz halten" become criteria.

### Check 3: Subtasks

Propose Sub-Tasks when the ticket stays one deliverable but has internal structure worth tracking:

- There is a required order inside the ticket, so one part cannot start before another is done.
- Several people can work on parts of it in parallel and want their own item.
- The ticket runs long enough that a single "In Arbeit" status hides all progress.
- A part of the work has its own review or handover, for example a schema change that another team has to approve.

Do not propose Sub-Tasks when they would only mirror the Aufgaben list one to one, when the ticket is done in a day, or when each subtask would be a single commit. In those cases the Aufgaben bullets already do the job.

For every proposed Sub-Task give a summary and one line of scope, so the user can approve them directly into step 6.

### Check 4: Konsistenz und Stil

- Ziel, Aufgaben and Akzeptanzkriterien describe the same piece of work, none wider than the others. The summary matches what the description asks for.
- Parent, issue type and labels fit the content.
- Acceptance criteria: more than five is a finding. Report which lines are restated Aufgaben, Definition of Done practice or implementation detail, and propose the shortened list. If nothing can go, the ticket is too big, hand it to Check 1.
- Every reference to another ticket is a finding, with the replacing link and, where needed, the sentence that takes over its content. On an existing ticket written by someone else, report it as a suggested edit.
- The sections "Writing style" (no dashes, no semicolons, abbreviations spelled out once), "Summaries" (run the standalone test: does the summary alone say what changes, and could a neighbouring ticket carry the same line?), "Wie ein Kollege schreibt" and "Jede Information einmal" hold.

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

Write the description parameter as genuine multi-paragraph text with real line breaks between sections and bullets, like a normal chat message. Do **not** build the string by concatenating literal `\n` or `\n\n` into a single-line value. Several Jira tool integrations render that literally, leaving visible `\n\n` in the description. If unsure, create or edit one issue first and read back its rendered description before doing the rest of the batch.
