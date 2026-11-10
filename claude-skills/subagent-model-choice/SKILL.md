---
name: subagent-model-choice
description: Work as orchestrator and choose the model (Haiku, Sonnet, Opus, Fable only after asking the user) and effort for every subagent. Use this as the first step of every coding, fix, research or data task (such as sorting tickets), before changing code, files or data yourself. Also use it before any Agent call with a model choice, when splitting work across subagents, delegating analysis of servers or infrastructure, starting multi-step work yourself (refactoring, cleanup, many similar edits), or defaulting to Sonnet or Opus "to be safe", and for requests like "verteil das auf Subagents", "nimm Haiku dafür", "welches Modell soll das machen", "du bist Orchestrator" or a prompt file that assigns you the orchestrator role.
---

# Subagent Model Choice

Pick the subagent model by the quality of the brief and the cost of checking the result, not by the kind of task. With a good orchestrator brief, Haiku handles a lot of coding well. Its weakness is clean code, which a collected refactor pass at the end catches.

Further files in this folder, read only when needed: `pipeline.md` (task split across several subagents), `boundaries.md` (live systems, MCP services, read-only work), `fable.md` (before suggesting Fable), `cache.md` (waits over 5 minutes or a large orchestrator context).

## Failure modes, all observed

1. **Sonnet or Opus by reflex.** Ask "can Haiku do this with my brief, and will I notice if it fails?", not "can Haiku do this alone?".
2. **Haiku code that works but is not clean.** Caught by the collected refactor at the end, not a reason to avoid Haiku.
3. **Refactoring after every slice.** Touches the same code several times. One pass at the end, after the review.
4. **Not delegating at all.** Before making more than a few edits yourself, stop and check whether the rest should be delegated. A precise list, for example from `tsc --noUnusedLocals` or a linter, is an ideal Haiku brief.
5. **Loading this skill too late**, only when a first Agent call comes up, after analysis and first changes. Load it as the first step, also for data and ticket work.

## Orchestrator as default

The user wants the main agent to work as orchestrator in every coding, fix, research or data task, not only when asked. The main agent reads and cuts the task, writes the briefs and, where useful, the red tests, checks every result and talks to the user. Implementation, fixes, refactors and mechanical changes go to subagents.

Exception, tiny changes. It depends on how much the brief has to explain:

- **Do it yourself:** about one to ten lines in one place, where the brief would have to contain the code anyway (a one-line fix, a constant, a missing import).
- **Delegate:** once red tests exist, even for 20 to 30 lines of logic. The tests are most of the brief ("make `test_board_check_*` green, do not change the tests, follow `foo()`").
- **In between** (logic without tests): write the red tests first, then delegate.

Reading pre-work is your own job when a few commands are cheaper than the brief and narrow the task. Example: `git cherry` and `git merge-base --is-ancestor` reduced 13 branches to 19 commits, and only those went into the briefs. Delegate once reading and judging content starts.

Forks (`/code-review`, `subagent_type: "fork"`) inherit the main agent's model and ignore `model`. A review fork from an Opus session runs on Opus.

## Look up lessons first

Find the task type in the table, then search for it: `am-search -p global "<task type>"`, and if that finds nothing, one or two short words from the task. Matches are in the "Lessons" part of the output. A matching lesson outweighs the model guide. Older lessons do not start with a task type yet, so also try the words in the last column.

| Task type | Typical model | Older lessons also under |
|---|---|---|
| `Recherche`: look up facts on the web or places in code | Haiku | Fakten-Recherche, Bestandsaufnahme |
| `Analyse`: compare or judge content | Sonnet | Inhaltsvergleich |
| `Live-System-Analyse` | Sonnet | Firewall |
| `Klassifizieren` | Haiku | Tickets |
| `Green-Step` | Haiku | Green-Step |
| `Tests schreiben` | Sonnet | |
| `Mechanisch` | Haiku | toten Code |
| `Refactor`: behavior unchanged | Haiku or Sonnet | God-Funktion |
| `Fix`: cause known | Haiku or Sonnet | Fehlerbehebung, Review fixer |
| `Umsetzung`: new feature, or rebuild with changed behavior | Sonnet | Schnittstellenumbau, merge way, Parallel |
| `Fehlersuche`: cause unclear | Opus, Fable after two failed attempts and asking | |
| `Zweitmeinung` | Opus, Fable after asking | |
| `Architektur` | not delegated, or Opus | |
| `Text schreiben`: docs, tickets, descriptions | Haiku, Sonnet if code must be understood | |

## Decision questions

Ask these for every delegated piece of work. The answers decide the model.

1. **Is the brief clear?** Goal, files, pattern and done criterion are named. If the agent first has to find out *what* to do, go up one level.
2. **Can the result be checked cheaply?** Build, tests, a short diff, the review skill. If yes, a failed Haiku attempt costs little.
3. **How much context is needed at once?** One or two files with a clear interface is Haiku. Several files that interact, side effects, dependencies between modules is Sonnet.
4. **How much judgement is inside?** Trade-offs such as fetch strategy, caching, API design or architecture go to Opus, or are not delegated and discussed with the user.
5. **What does an unnoticed mistake cost?** If a mistake could slip through checks (migrations, data changes, security, concurrency), go up one level.

## Model guide

**Haiku**
- `Recherche` from a fixed list of questions: find usages, list files, summarize a known file, collect versions and features.
- `Green-Step`: tests exist and fail, make them pass without changing the tests.
- `Mechanisch`: renames, boilerplate, the same fix in a list of places.
- `Refactor` when the exact places and the target shape are named.
- `Klassifizieren` by given rules (labels for tickets, categories for rows), result as a JSON proposal, not applied. Rules written out with one or two examples per class, a class `unklar` instead of guessing, batches of about 40 to 60 in parallel. Check a sample per batch and every `unklar`, then apply yourself. Sonnet if the rules need weighing or classes overlap a lot.
- `Text schreiben` when the facts are in the brief.

**Sonnet**
- The task has to be understood before it can be done.
- `Analyse`, research that needs judgement. Example: "is this diff already in the target branch in another form?" is a comparison of content, not a text match.
- `Tests schreiben` when the behavior is known but the setup is not trivial.
- `Umsetzung` across several interacting files, `Refactor` with some design freedom.
- `Live-System-Analyse` with a security angle, such as firewall rules (question 5, a wrong conclusion can lock the user out).
- Fallback after Haiku failed twice on the same piece.

**Opus**
- `Architektur`, trade-offs, `Fehlersuche`, anything where a wrong decision is expensive. Prefer doing this yourself or presenting it to the user with a recommendation. Delegate only well-bounded deep work such as an independent analysis.

**Fable** only after asking the user, for `Zweitmeinung` and stuck `Fehlersuche`. Read `fable.md` first.

**Not delegated:** changes to production systems and writing back to live data. Subagents analyse and propose, you apply after the user agrees (see `boundaries.md`).

**Agent type.** `model` works with every type, the type decides the tools. Read-only search in the codebase: `Explore` (no file write tools, returns its result in the report, reads excerpts). Whole files, diffs or changes: `general-purpose`. Both have Bash and all MCP tools, so for live systems and MCP services read `boundaries.md`.

**Effort.** `lower` for mechanical, self-checking briefs, `higher` for a well-specified piece that needs more reasoning. Sonnet with lower effort and Haiku can both be valid. If unsure, prefer Haiku with a sharper brief.

## Writing a brief

**Every brief** contains:

- **Goal in one sentence** and the done criterion (which tests turn green, which command must pass, which questions are answered).
- **Exact files or systems** to read and to change, and what must not be touched (tests, public interfaces).
- **A short report format:** changed files, test result, anything unclear, no silent guessing. No file contents or long logs, every report lands in the orchestrator context. Give a fixed shape or a length limit for long results, or a result file.
- **Which checks the agent runs itself.** The fast ones: typecheck, build, the affected tests, linter, fixed before reporting. Slow or broad checks stay with you: long full test suites, visual comparison over many outputs, end-to-end runs, anything on a live system. Name both.
- **Current state when handing over mid-work.** Name uncommitted changes. Add: do not commit, no git commands that change state (`checkout`, `stash`, `reset`, `commit`), keep existing changes. If the changes belong to someone else and read-only agents need a clean state, use a reading copy (`boundaries.md`).
- **Boundaries and abort conditions**, at least "nothing is applied, the result is a proposal" for live systems. Details and technical boundaries in `boundaries.md`.

**For Haiku** the brief is the reason it works. Add:

- **A reference example** from the codebase: "follow the structure of `XyzService`". Small models copy examples far better than they follow rules.
- **Concrete style rules** that can be checked: method length, nesting depth, naming with one right and one wrong example, language of comments. Take them from the project prompt or CLAUDE.md.
- **For research:** a source for every answer and the rule "write `unbelegt` instead of guessing".

## Parallel agents and follow-up

- Independent pieces start in ONE message with several Agent calls, as background agents (`run_in_background`) if there is other work meanwhile.
- **Shared interface:** if parallel agents build against the same interface, fix it yourself first, with types and units. In practice an agent that knew the interface only from another agent's tests passed a duration object where seconds were expected.
- **Writing agents in parallel** in the same repo get their own worktree each (`isolation: "worktree"`), so edits, builds and tests do not collide. Merge the results yourself.
- **Check every result** yourself before passing it on or acting on it: read the diff or report, then run the slow checks. For a proposal on a live system check the rollback path in particular (`boundaries.md`).
- **Small corrections** go to the same agent via `SendMessage`, it keeps its context. Start a new agent only when the model should change or the old context went wrong.

## Larger coding tasks

Split across several subagents: tests first, green in small slices, code review, one collected refactor at the end. Read `pipeline.md` before cutting the task.

## Saving lessons

Save a lesson when a model choice turned out wrong in either direction, when it worked in a case that was not obvious beforehand, and after every Fable run. One line, starting with a task type from the table:

`<task type>: <short description> | <model> + <effort> | <result> | <what decided>`

Example: `Live-System-Analyse: nftables Produktivserver | Sonnet + default | korrekt, nur Rollback fehlerhaft | Aussperr-Risiko (Frage 5)`.

Save it with `memory_lesson_save` in project `global`, tags: the task type and the project name. If no task type fits, use the closest and say in the report to the user that the table may need a new one.
