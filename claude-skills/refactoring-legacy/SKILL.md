---
name: refactoring-legacy
description: Restructures existing code without changing behavior. Pins behavior with characterization tests first, then refactors in small green steps, one commit each. Started only by the user with /refactoring-legacy.
disable-model-invocation: true
---

# Refactoring Legacy Code

Refactoring existing code with unchanged behavior. Cleanup after a new feature stays with step 6 of `pipeline.md` (skill `subagent-model-choice`) and `/simplify`, do not start this skill for that. Project rules (CLAUDE.md, CONTRIBUTING.md) take precedence.

## Before Phase 1

- Search agentmemory: `am-search "<short term>"` and `am-search -p global "Refactor"`. Try several short keywords.
- Orchestrator: you analyse, cut the steps with exact places and target shape, and check results. Subagents execute. Model, effort and brief follow skill `subagent-model-choice`, task type `Refactor` (writing tests: `Tests schreiben`). Set `model` on every Agent call.
- Own branch for the refactoring. Push and PR only after the user's OK.

## Phase 1: Entry

- User names a goal ("split god class X into Y and Z"): skip to Phase 3 and implement it.
- User names only code ("clean up module X"): Phase 2 first. Do not refactor before the user has picked.

## Phase 2: Analyse

Read the code and judge it with the catalog `../../shared/code-smells.md` (resolved from this skill directory). Check build, tests and callers per candidate: test coverage and number of callers decide the risk. Read the build file (`pom.xml`, `package.json` and similar) once to know which libraries are already there: own code that one of them covers is a Reinvented Wheel.

Present a list sorted by benefit to risk. Top: high effect, low risk (good tests, few callers). Per entry:

- Code Smell and place (file, method)
- Target shape
- Effort
- Risk and why

The user picks entries. Only those are refactored.

## Phase 3: Pin behavior

No refactoring without a safety net. Per chosen entry, check whether the affected behavior is tested. If not, write characterization tests first (`Tests schreiben`) that pin today's behavior, even if it looks wrong.

- Bugs found go into a bug list (place, observed behavior, expected behavior). Do not fix them. Behavior stays the same.
- A test that pins clearly wrong behavior gets a comment pointing to its bug list entry.
- Characterization tests stay in the repo permanently.
- No seam for a test (e.g. static DB access inside the method): pin from outside as a Golden Master. Save output, HTTP response or DB state before, compare after.
- Neither works: stop and ask the user, with a proposal.

Commit the tests as their own step. Run them on the untouched code and see them green before Phase 4.

## Phase 4: Small steps

Cut each entry into steps that build and pass on their own. Per step:

1. Brief the subagent with exact places, target shape and the done criterion "build and all tests green, tests unchanged".
2. Check the diff, build and tests yourself.
3. One commit per step.

A red step is reverted completely and cut smaller, not repaired. Tests coupled to internals (e.g. a mock of an own class) may be adapted only in a separate step, announced to the user beforehand.

### Many callers

Expand and contract: build the new form next to the old, move the callers in batches, remove the old form at the end. Batches may run in parallel on Haiku, each writing agent in its own worktree (see `subagent-model-choice`). Every batch ends green.

## Phase 5: Review

Run `/evidence-code-review` over the whole branch. Bugs from it go to the bug list. Code Smells from it become further steps after the user's OK, with the rules of Phase 4.

## Phase 6: Close

- [ ] All chosen entries done, build and tests green
- [ ] Characterization tests committed, wrong-behavior tests point to the bug list
- [ ] Review done, findings sorted into bug list and further steps
- [ ] Bug list handed to the user as a result
- [ ] Push and PR only after the user's OK
- [ ] Lesson saved with `memory_lesson_save` (project = `$AGENTMEMORY_PROJECT_NAME` or folder name), text starting with "Refactoring: "
