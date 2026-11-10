---
name: subagent-model-choice
description: Choose the right model (Haiku, Sonnet, Opus or, after asking the user, Fable) and effort for a subagent before delegating, and plan larger coding work as a TDD pipeline where tests are fixed first, Haiku or Sonnet make them green in small slices, and one collected refactor pass runs at the end, after the code review. Also checks whether waits on subagents will exceed the 5 minute prompt cache and weighs raising it to 1 hour. Use this at the start of every coding, fix, research or data task (such as sorting tickets), before writing code, changing files or changing data yourself, since working as orchestrator is the default. Also use it whenever you are about to call the Agent tool with a model choice, split a coding task across several subagents, delegate research or read-only analysis of servers and infrastructure, act as orchestrator for a story or ticket, are about to start multi-step implementation work yourself (refactoring, cleanup, dead code removal, many similar edits), or catch yourself defaulting to Sonnet or Opus "to be safe", including requests like "verteil das auf Subagents", "nimm Haiku dafür", "welches Modell soll das machen", "du bist Orchestrator" or a prompt file that assigns you the orchestrator role.
---

# Subagent Model Choice

Pick the subagent model by the quality of the brief and the cost of checking the result, not by the kind of task. With a good orchestrator brief, Haiku handles a lot of coding well. Its known weakness is clean code, so that weakness is caught in a dedicated refactor pass instead of being a reason to avoid Haiku.

## Why this exists

Failure modes this skill exists to prevent, all observed in practice:

1. **Sonnet or Opus by reflex.** The question "can Haiku do this alone?" is the wrong one. The right question is "can Haiku do this with my brief, and will I notice if it fails?" When the orchestrator has cut the task, named files and fixed the tests, what remains is often plain implementation.
2. **Haiku code that works but is not clean.** Long methods, duplication, vague names, ignored project conventions. Tests are green, the code still needs work.
3. **Refactoring too early.** Refactoring after every slice of a larger task touches the same code several times, and the review afterwards finds things the refactor should have covered. One collected pass at the end is cheaper and sees the whole picture.
4. **Not delegating at all.** The main agent builds tests, fix and debugging itself, or starts mechanical work with many steps (cleanup, dead code, the same fix in many places), without ever thinking of a subagent. The skill then never loads, because no Agent call was planned. Observed twice, both times the user had to ask for orchestration explicitly. Rule: before making more than a few edits yourself, stop and check whether the rest should be delegated. A precise list, for example from `tsc --noUnusedLocals` or a linter, is an ideal Haiku brief.
5. **Loading the skill too late.** The skill was loaded only when a first Agent call came up, after analysis and first changes (labels created, ticket commented) were already done. The timing was chance, not part of the routine. Rule: load the skill as the first step of the task, before the first change, also for data and ticket work, not only for code.

## Orchestrator as default

The user wants the main agent to work as orchestrator in every coding, fix, research or data task (for example sorting tickets), not only when asked. The main agent:

- reads and understands the task, cuts it into pieces,
- writes the briefs and, where useful, the red tests,
- checks every result and talks to the user.

Implementation, fixes, refactors and mechanical changes go to subagents. Exception: tiny changes where the brief would be longer than the change.

What counts as tiny depends on how much the brief has to explain, not only on the line count:

- **Do it yourself:** about one to ten lines in one place, where the brief would have to contain the code anyway. Typical: a one-line fix, a changed constant, a missing import.
- **Delegate:** once red tests exist, even for 20 to 30 lines of logic. The tests are most of the brief, so it stays short ("make `test_board_check_*` green, do not change the tests, follow `foo()`"). Haiku fits well here.
- **In between** (logic without tests, more than a few lines): write the red tests first, then the case above applies.

Reading pre-work with a few commands is the orchestrator's own job when it makes the brief sharper. Example: in a branch triage, `git rev-list`, `git cherry`, `git merge-base --is-ancestor` and `git apply --check` reduced 13 branches to 19 commits that actually needed a look, and only those went into the briefs. Rule of thumb: if the commands are cheaper than writing the brief and their output narrows the task, run them yourself. Delegate once reading and judging the content starts.

Forked skills and agents (for example `/code-review`, or the Agent tool with `subagent_type: "fork"`) inherit the main agent's model, a `model` override is ignored there. Keep that in mind when weighing cost, a review fork from an Opus session runs on Opus.

## Look up earlier lessons first

Before choosing, search the lessons for the task type, for example `am-search -p global "Recherche"` or `am-search -p global "Read-only-Analyse"`. Try two or three short terms. Matches appear in the "Lessons" part of the output, mixed with unrelated lessons from `global`, so pick the lines in the format below. A matching lesson outweighs the general guide below. See [Lessons](#lessons) for the format.

## Decision questions

Ask these for every delegated piece of work. The answers decide the model.

1. **Is the brief clear?** Goal, files, pattern and done criterion are named. If the agent first has to find out *what* to do, go up one level.
2. **Can the result be checked cheaply?** Build, tests, a short diff, the review skill. If yes, a failed Haiku attempt costs little.
3. **How much context is needed at once?** One or two files with a clear interface is Haiku. Several files that interact, side effects, dependencies between modules is Sonnet.
4. **How much judgement is inside?** Trade-offs such as fetch strategy, caching, API design or architecture decisions go to Opus, or are not delegated at all and discussed with the user instead.
5. **What does an unnoticed mistake cost?** If a mistake could slip through checks (migrations, data changes, security, concurrency), go up one level.

## Model guide

**Haiku**
- Simple research: find usages, list files, summarize a known file, collect facts such as versions and features from a fixed list of questions.
- Green step in TDD: tests exist and fail, make them pass without changing the tests.
- Mechanical changes along a given pattern: renames, boilerplate, applying the same fix to a list of places.
- Refactor steps when the orchestrator names the exact places and the target shape.
- Sorting many items by given rules, for example labels for tickets or categories for data rows, with the result as a proposal file (JSON) and not applied. Condition: the rules are written out with one or two examples per class, and there is a class `unklar` instead of guessing. For many items split into batches of about 40 to 60 and run them in parallel. The orchestrator checks a sample per batch and every `unklar`, then applies the changes itself. If the rules need weighing or the classes overlap a lot, use Sonnet.

**Sonnet**
- The task has to be understood before it can be done.
- Research that needs judgement, not just lookup. Example: "is this diff already in the target branch in another form?" The answer is not a text match but a comparison of content, so it is Sonnet even though nothing is changed.
- Writing tests when the behavior is known but the test setup is not trivial.
- Changes across several interacting files.
- Refactor steps that need some design freedom inside a given direction.
- Fallback after Haiku failed twice on the same piece.
- Read-only analysis of a live system with a security angle, for example firewall rules on a production server. Question 5 lifts this above Haiku because a wrong conclusion can lock the user out.

**Not delegated:** changes to production systems. The subagent may analyse and propose, the orchestrator presents the proposal and applies it only after the user agrees.

**Opus**
- Trade-offs, architecture, unclear bug hunts, anything where a wrong decision is expensive.
- Prefer doing this yourself as orchestrator or presenting it to the user with a recommendation. Delegate to Opus only for well-bounded deep work such as an independent analysis.

**Fable** (`model: "fable"`, included in the user's subscription)
- **Only after asking the user.** Before every Fable call, say why Fable and not Opus, what the agent gets and roughly how long it will run, then wait for a yes. This rule holds until the user loosens it. Save a lesson after every Fable run (see Lessons), so the user can later decide on experience.
- **Independent second opinion where a mistake is expensive** (question 5: migrations, security, architecture). Fable checks a proposal from the orchestrator or from Sonnet with fresh context before it is applied. A verifier with fresh context finds more than the author's self-check.
- **Bug hunt where the orchestrator is stuck.** The bug is unclear and two attempts with Opus or Sonnet failed. Fable gets the findings so far and may search the git history.
- Per Anthropic's docs the most capable model, at 2.5 times the token price of Opus. Single runs on hard tasks often take many minutes, so check the prompt cache (see below). Lower effort is often enough.
- **Brief for Fable:** state goal, context and boundaries, not a step list. Over-prescriptive briefs make its results worse, the opposite of Haiku. Name explicitly what it must not do, since it sometimes takes adjacent actions nobody asked for.
- Not for implementation, green steps, refactors or mechanical work. The TDD pipeline with Haiku and Sonnet is cheaper there and easy to check.

**Agent type.** `model` works with every agent type, the type decides the tools. Read-only search and research in the codebase: `Explore` (no file write tools, so for files the read-only boundary is technical, not just a request). It can not write a result file, it returns the result in its report. It locates code and reads excerpts, for a full summary or review of a file use `general-purpose`. The same holds for read-only work that needs whole diffs or files, such as diff comparisons: `general-purpose` with the read-only boundary in the brief (and a separate worktree as reading copy, see Writing a brief). Changes: `general-purpose`. `Explore` still has Bash, so on a live system it is not read-only by itself.

**MCP (Model Context Protocol) tools in subagents.** `general-purpose` and `Explore` both get all MCP tools of the session, including writing ones such as `tasks_update`, `labels_delete` or a generic `do_action`. A read-only boundary in the brief is only a request. Ways to make it technical, best first:

1. **Fetch the data yourself and hand over a file.** The orchestrator reads with the MCP read tools (for example `tasks_list` page by page) into a JSON file in the scratchpad. The subagent gets only the file path and its brief says it needs no MCP tools. Still only a request, but the agent has no reason to touch the system. Often the cheapest way, and the orchestrator reads the data for checking anyway.
2. **Own agent type with a tool allowlist.** A file `.claude/agents/<name>.md` (project) or `~/.claude/agents/<name>.md` (user) with a `tools:` line that lists only the needed tools, for example `tools: Read, Write, mcp__vikunja__tasks_list, mcp__vikunja__tasks_read, mcp__vikunja__labels_list`. Then call it with `subagent_type: "<name>"`, `model` still works. Agent files are read at session start, so a new one may need a restart or creating it via `/agents`. Worth it for tasks that repeat.
3. **Read-only token** for the MCP server, if the service offers one. Ask the user, never create tokens yourself.

Writing back (labels, comments, status) stays with the orchestrator after checking the proposal, same as changes to production systems.

**Effort.** The Agent tool also takes `effort`. Use `lower` for mechanical, self-checking briefs, `higher` for a well-specified piece that needs more reasoning. Sonnet with lower effort and Haiku can both be valid. If unsure, prefer Haiku with a sharper brief.

## Writing a brief

**Every brief** contains:

- **Goal in one sentence** and the done criterion (which tests turn green, which command must pass, which questions are answered).
- **Exact files or systems** to read and to change, and what must not be touched (tests, public interfaces).
- **What to report back:** changed files, test result, anything unclear. No silent guessing.
- **Which checks the agent runs itself.** The fast ones that fit the brief: typecheck, build, the affected tests, linter. The agent fixes failures before reporting. Slow or broad checks stay with the orchestrator after the result is in: full test suite when it is long, visual or snapshot comparison over many outputs, end-to-end runs, anything on a live system. Name both in the brief so the agent does not skip the fast checks or start the slow ones.
- **Current state when handing over mid-work.** If the working copy already has uncommitted changes, say so and name them briefly. Add: do not commit, no git commands that change state (`checkout`, `stash`, `reset`, `commit`), keep the existing changes. If the uncommitted changes belong to someone else and read-only agents only need a clean state, create a separate detached worktree as reading copy (`git worktree add --detach ../repo-lesestand <ref>`), name its path in the brief and remove it afterwards.
- **Boundaries and abort conditions.** Most important for server and infrastructure work, useful everywhere:
  - What is allowed and what is not, with examples. For a live system: only reading commands, for example `nft list ruleset` and `docker ps` are allowed, `nft add`, `systemctl restart` or editing files are not.
  - When to stop instead of retrying. On an authentication error do not try again (fail2ban may ban the host), report it.
  - No secrets, passwords or tokens in the report.
  - The result is a proposal. Nothing is applied, the user decides.

A boundary in the brief is a request, not an enforcement. For live systems add a technical boundary where possible: an SSH (Secure Shell) user without write rights, a read-only API token, or an agent type without write tools.

**For Haiku** the brief is the reason it works. Add:

- **A reference example** from the codebase: "follow the structure of `XyzService`". Small models copy examples far better than they follow abstract rules.
- **Concrete style rules** that can be checked: method length, nesting depth, naming convention with one correct and one wrong example, language of comments. Take them from the project prompt or CLAUDE.md.
- **For research:** a source for every answer and the rule "write `unbelegt` instead of guessing". Haiku keeps to this well and marks gaps honestly.

## Parallel and background agents

Independent pieces, such as a research question and an analysis of another system, start in ONE message with several Agent calls, as background agents (`run_in_background`) if there is other work meanwhile. Check every result yourself before passing it on or acting on it (read the diff or report, then run the slow checks named in the brief), especially a proposal for a live system. There, check the rollback path in particular: in practice a Sonnet proposal was sound except for a rollback that would have flushed the firewall completely instead of restoring the old ruleset.

## Workflow for larger coding tasks

Use this when a task is split across several subagents.

**1. Cut the task.** Split into slices that can be built and tested on their own. Note dependencies, independent slices can run in parallel.

**2. Red: fix the tests first.** Per slice, write the tests yourself or let Sonnet write them from your specification. Check that they fail for the right reason. The understanding of the task lives in these tests.

**3. Green: implement per slice.** Choose the model per slice with the decision questions. Typically Haiku with a full brief. Verify after each slice: build and all tests green, diff matches the brief, tests unchanged.

**4. Escalate on failure.** If a slice fails twice on the same point, sharpen the brief once or move up one model. Fable is the last step and needs the user's yes. Note in a sentence why it failed, this feeds the lessons (see below).

**5. Code review.** When all slices are green, run the review skill the project prescribes (for example `/evidence-code-review`). Confirmed blockers that are bugs are fixed now, by the model that fits the fix.

**6. Collected refactor at the end.** Only now, once for the whole task:
- Go through the diff yourself and list the places that need cleanup: long methods, duplication, unclear names, broken conventions. Add the clean code findings from the review.
- Give each place a concrete target: "extract the loop in `foo()` into `loadAntraegeByMandanten()`", not "make it cleaner".
- Hand the list to Haiku (exact places and target shape) or Sonnet (needs some design freedom). Split by file or area if it is long.
- Tests stay unchanged and must stay green. Check the result yourself.

Small single tasks without a split do not need the full pipeline. Implement, check, then a short refactor list, done.

## Prompt cache

While a subagent runs, the orchestrator cache ages. A wait over its lifetime rewrites the whole orchestrator context at write price. When waits over 5 minutes are expected (long builds, review with second opinion, many slices, the user testing between turns) or the orchestrator context is already large, read `cache.md` in this skill folder before starting. It holds the facts, how to check the configured lifetime and how to weigh 5 minutes against 1 hour. For short delegations skip it.

## Lessons

Save a lesson when a model choice turned out wrong in either direction (Haiku failed, or Sonnet was used where Haiku would have done), and also when a choice worked in a case that was not obvious beforehand. Over time this replaces gut feeling with experience, as long as lessons are looked up before choosing (see above).

Use one line in a fixed format so lessons stay comparable across projects:

`Aufgabentyp | Modell + effort | Ergebnis | was entschied`

Example: `Read-only-Analyse nftables Produktivserver | Sonnet + default | korrekt, nur Rollback fehlerhaft | Aussperr-Risiko (Frage 5)`.

Save it with `memory_lesson_save` in project `global`, since model choice is not tied to one project, and add the project name as a tag.
