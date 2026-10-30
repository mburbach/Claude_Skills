---
name: subagent-model-choice
description: Choose the right model (Haiku, Sonnet or Opus) and effort for a subagent before delegating, and plan larger coding work as a TDD pipeline where tests are fixed first, Haiku or Sonnet make them green in small slices, and one collected refactor pass runs at the end, after the code review. Also checks whether waits on subagents will exceed the 5 minute prompt cache and weighs raising it to 1 hour. Use this whenever you are about to call the Agent tool with a model choice, split a coding task across several subagents, act as orchestrator for a story or ticket, or catch yourself defaulting to Sonnet or Opus "to be safe", including requests like "verteil das auf Subagents", "nimm Haiku dafür", "welches Modell soll das machen", "du bist Orchestrator" or a prompt file that assigns you the orchestrator role.
---

# Subagent Model Choice

Pick the subagent model by the quality of the brief and the cost of checking the result, not by the kind of task. With a good orchestrator brief, Haiku handles a lot of coding well. Its known weakness is clean code, so that weakness is caught in a dedicated refactor pass instead of being a reason to avoid Haiku.

## Why this exists

Failure modes this skill exists to prevent, all observed in practice:

1. **Sonnet or Opus by reflex.** The question "can Haiku do this alone?" is the wrong one. The right question is "can Haiku do this with my brief, and will I notice if it fails?" When the orchestrator has cut the task, named files and fixed the tests, what remains is often plain implementation.
2. **Haiku code that works but is not clean.** Long methods, duplication, vague names, ignored project conventions. Tests are green, the code still needs work.
3. **Refactoring too early.** Refactoring after every slice of a larger task touches the same code several times, and the review afterwards finds things the refactor should have covered. One collected pass at the end is cheaper and sees the whole picture.

## Decision questions

Ask these for every delegated piece of work. The answers decide the model.

1. **Is the brief clear?** Goal, files, pattern and done criterion are named. If the agent first has to find out *what* to do, go up one level.
2. **Can the result be checked cheaply?** Build, tests, a short diff, the review skill. If yes, a failed Haiku attempt costs little.
3. **How much context is needed at once?** One or two files with a clear interface is Haiku. Several files that interact, side effects, architecture is Sonnet.
4. **How much judgement is inside?** Trade-offs such as fetch strategy, caching or API design go to Opus, or are not delegated at all and discussed with the user instead.
5. **What does an unnoticed mistake cost?** If a mistake could slip through checks (migrations, data changes, security, concurrency), go up one level.

## Model guide

**Haiku**
- Simple research: find usages, list files, summarize a known file, collect facts with a clear question.
- Green step in TDD: tests exist and fail, make them pass without changing the tests.
- Mechanical changes along a given pattern: renames, boilerplate, applying the same fix to a list of places.
- Refactor steps when the orchestrator names the exact places and the target shape.

**Sonnet**
- The task has to be understood before it can be done.
- Writing tests when the behavior is known but the test setup is not trivial.
- Changes across several interacting files.
- Refactor steps that need some design freedom inside a given direction.
- Fallback after Haiku failed twice on the same piece.

**Opus**
- Trade-offs, architecture, unclear bug hunts, anything where a wrong decision is expensive.
- Prefer doing this yourself as orchestrator or presenting it to the user with a recommendation. Delegate to Opus only for well-bounded deep work such as an independent analysis.

**Effort.** The Agent tool also takes `effort`. Use `lower` for mechanical, self-checking briefs, `higher` for a well-specified piece that needs more reasoning. Sonnet with lower effort and Haiku can both be valid. If unsure, prefer Haiku with a sharper brief.

## Writing a brief for Haiku

A Haiku brief is the reason Haiku works. It contains:

- **Goal in one sentence** and the done criterion (which tests turn green, which command must pass).
- **Exact files** to read and to change, and what must not be touched (tests, public interfaces).
- **A reference example** from the codebase: "follow the structure of `XyzService`". Small models copy examples far better than they follow abstract rules.
- **Concrete style rules** that can be checked: method length, nesting depth, naming convention with one correct and one wrong example, language of comments. Take them from the project prompt or CLAUDE.md.
- **What to report back:** changed files, test result, anything unclear. No silent guessing.

## Workflow for larger coding tasks

Use this when a task is split across several subagents.

**1. Cut the task.** Split into slices that can be built and tested on their own. Note dependencies, independent slices can run in parallel.

**2. Red: fix the tests first.** Per slice, write the tests yourself or let Sonnet write them from your specification. Check that they fail for the right reason. The understanding of the task lives in these tests.

**3. Green: implement per slice.** Choose the model per slice with the decision questions. Typically Haiku with a full brief. Verify after each slice: build and all tests green, diff matches the brief, tests unchanged.

**4. Escalate on failure.** If a slice fails twice on the same point, sharpen the brief once or move up one model. Note in a sentence why it failed, this feeds the lessons (see below).

**5. Code review.** When all slices are green, run the review skill the project prescribes (for example `/evidence-code-review`). Confirmed blockers that are bugs are fixed now, by the model that fits the fix.

**6. Collected refactor at the end.** Only now, once for the whole task:
- Go through the diff yourself and list the places that need cleanup: long methods, duplication, unclear names, broken conventions. Add the clean code findings from the review.
- Give each place a concrete target: "extract the loop in `foo()` into `loadAntraegeByMandanten()`", not "make it cleaner".
- Hand the list to Haiku (exact places and target shape) or Sonnet (needs some design freedom). Split by file or area if it is long.
- Tests stay unchanged and must stay green. Check the result yourself.

Small single tasks without a split do not need the full pipeline. Implement, check, then a short refactor list, done.

## Prompt cache: 5 minutes or 1 hour

While a subagent runs, the orchestrator makes no requests, and its cache ages from its last request. This holds for foreground and background subagents. If the wait exceeds the cache lifetime, the next orchestrator request rewrites the whole conversation at write price instead of reading it at read price. With a large orchestrator context that is the most expensive moment of the whole task.

**Facts (Claude Code docs, checked 2026-10-30)**
- Write with 5 min lifetime costs 1.25x base input, write with 1 h costs 2x. A read costs 0.1x (0.05x on Opus 5.5 and Sonnet 5.5). Every read resets the timer.
- Two separate settings: `promptCacheTtl` (env `CLAUDE_CODE_PROMPT_CACHE_TTL`) for the main conversation, `subagentPromptCacheTtl` (env `CLAUDE_CODE_SUBAGENT_PROMPT_CACHE_TTL`) for subagents. Values `"5m"` or `"1h"`. `ENABLE_PROMPT_CACHING_1H=1` sets both, `FORCE_PROMPT_CACHING_5M=1` overrides everything.
- Defaults: subscription within plan usage has 1 h for the main conversation and 5 min for subagents. API key, cloud provider, or subscription drawing on usage credits has 5 min everywhere unless set explicitly.
- The model cannot change the lifetime of the running session. Whether a change takes effect without restart is not documented. Assume a restart.

**Check at the start of an orchestrated task**
1. Estimate the longest waits. Typical candidates over 5 minutes: a full build with integration tests (Testcontainers, Maven, Gradle), the review skill with a second opinion, a subagent with many slices, and the user thinking or testing between turns.
2. Look up the configured lifetime: `promptCacheTtl` and `subagentPromptCacheTtl` in `~/.claude/settings.json` and the project settings, and the env vars above. Whether the subscription is in overage is not visible from inside. Ask the user if it matters, or point to `/usage`, which shows a line "Prompt cache (main)".
3. Weigh it (below). If 1 h is worth it and not set, recommend it to the user with the reason and the expected waits. Change settings only after the user agrees, via the `update-config` skill, and note that a restart is likely needed.

**Weighing it**
- 1 h costs 0.75x extra only on newly written tokens. A miss rewrites the entire context. So one avoided miss on a large orchestrator context usually pays for many turns of extra write cost.
- 1 h is worth it when waits over 5 minutes are expected at least occasionally and the orchestrator context is large (long prompt file, many results collected).
- 5 min is enough when all waits are short (small slices, fast unit tests) or the context is still small.
- Before raising the lifetime, check whether the wait can be cut instead: smaller slices, running only the affected tests in the green step and the full build once per slice.
- Subagent side: a subagent only needs 1 h for itself if it has gaps over 5 minutes between its own requests, for example one long build as a single tool call. Its context is usually small, so this rarely pays off. Do not raise `subagentPromptCacheTtl` to protect the orchestrator, it does not help there.

## Lessons

When a model choice turned out wrong in either direction (Haiku failed, or Sonnet was used where Haiku would have done), save a short lesson with the task type, the model, and what made the difference. Over time this replaces gut feeling with experience.
