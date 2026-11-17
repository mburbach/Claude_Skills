---
name: diagnosing-bugs
description: Diagnosis loop for hard bugs, errors, failing tests, crashes, flaky behavior and performance regressions where the cause is unclear. Use for "debug das", "warum geht das nicht", "da ist ein Fehler", "der Test schlägt fehl", "das ist langsam geworden", "finde die Ursache". Do NOT use when the cause is already known and only the fix is left.
---

# Diagnosing Bugs

Discipline for hard bugs, adapted from Matt Pocock's skill (github.com/mattpocock/skills). Skip a phase only with a stated reason.

## Before Phase 1

- Search agentmemory for the symptom: `am-search "<short term>"` and `am-search -p global "Fehlersuche"`. Try several short keywords.
- Orchestrator: you build the loop and the hypotheses yourself (task type `Fehlersuche` in skill `subagent-model-choice`). Send large log digging or code search to an Explore agent on Haiku with a short report. Set `model` on every Agent call.
- Live systems: instrumentation or config changes on production only after the user approves. Read `boundaries.md` of `subagent-model-choice` first.

## Redact

Write `<REDACTED>` in place of every secret in commands, outputs and artifacts you show. Loops read credentials from env vars. Quote only the signal lines of captured artifacts (auth headers). If redacted output is not enough, say so and ask the user.

## Phase 1: Build a feedback loop

This is the core. With a tight pass/fail signal that goes red on exactly this bug you will find the cause. Without one, reading code does not help. Put disproportionate effort here.

Ways to build one, in roughly this order:

1. Failing test at any seam that reaches the bug (unit, integration, e2e).
2. curl or HTTP script against a running dev server.
3. CLI call with a fixture input, diffed against a known-good snapshot.
4. Headless browser script (Playwright, Puppeteer) asserting on DOM, console, network.
5. Replay of a captured trace (request, payload, event log) through the code path.
6. Throwaway harness: a minimal subset of the system with mocked dependencies.
7. Property or fuzz loop for "sometimes wrong output": 1000 random inputs.
8. Bisection harness for a bug that appeared between two states, usable with `git bisect run`.
9. Differential loop: same input through old and new version or two configs, diff the outputs.
10. HITL (human in the loop) script, last resort when a human must click (see below).

Tighten the loop once it exists:

- Faster: cache setup, skip unrelated init, narrow the scope.
- Sharper: assert the specific symptom, not "did not crash".
- More deterministic: pin time, seed the RNG, isolate the filesystem, freeze the network.

Non-deterministic bugs: aim for a higher reproduction rate, not a clean repro. Loop the trigger 100 times, parallelise, add stress, narrow timing windows. A 50 percent flake is debuggable, 1 percent is not.

Cannot build a loop: stop, list what you tried and ask the user for (a) access to an environment that reproduces it, (b) a redacted artifact (HAR, log, core dump, recording with timestamps) or (c) permission for temporary production instrumentation. Do not hypothesise without a loop.

### HITL

Interactive `read` does not work in the Bash tool. Two options:

- Copy `../../shared/diagnosing-bugs/scripts/hitl-loop.template.sh` (resolved from this skill directory) to a scratch location, edit the steps, and ask the user to run it with `! bash <copy>`. The KEY=VALUE output lands in the conversation.
- Ask the steps one by one with the AskUserQuestion tool.

### Done when

You can name one command that you have already run at least once (show invocation and redacted output) and that is:

- Red-capable: it drives the real bug path and asserts the user's exact symptom. "Runs without error" does not count.
- Deterministic: same verdict every run (flaky: pinned high reproduction rate).
- Fast: seconds, not minutes.
- Agent-runnable: unattended, a human only via the HITL script.

If you catch yourself building a theory from code before this command exists, stop. No red-capable command, no Phase 2.

## Phase 2: Reproduce and minimise

- Run the loop and watch it go red.
- Check that it shows the failure the user described, not a neighbouring one.
- Check that it reproduces across runs and capture the exact symptom (message, wrong output, timing).
- Minimise: cut inputs, callers, config, data and steps one at a time, re-running after each cut. Done when removing any remaining element turns the loop green.

## Phase 3: Hypothesise

Write 3 to 5 ranked, falsifiable hypotheses before testing any. Format: "If X is the cause, then changing Y makes the bug disappear and changing Z makes it worse." Without a prediction, discard or sharpen it.

Show the ranked list to the user before testing. They often re-rank it with domain knowledge. Do not block if they are away.

## Phase 4: Instrument

- Every probe maps to a prediction from Phase 3. Change one variable at a time.
- Prefer a debugger or REPL, then targeted logs at the boundaries that separate hypotheses. Never "log everything and grep".
- Tag every debug log with a unique prefix like `[DEBUG-a4f2]` so cleanup is one grep.
- Performance regressions: take a baseline first (timing harness, profiler, query plan), then bisect. Measure first, fix second.

## Phase 5: Fix and regression test

Write the regression test before the fix, but only at a correct seam, where the test exercises the real bug pattern as it occurs at the call site. A too shallow seam gives false confidence. If no correct seam exists, that is itself a finding: note it, the architecture prevents locking the bug down.

1. Turn the minimised repro into a failing test.
2. Watch it fail. If you forced red by mutating code or a fixture, `diff` against a pristine copy.
3. Fix: once the red test exists, brief a Haiku subagent as `Green-Step` ("make test X green, do not change the test"). Fable only after two failed attempts and after asking the user (see `fable.md` of `subagent-model-choice`).
4. Watch it pass.
5. Re-run the Phase 1 loop on the original, un-minimised scenario.

## Phase 6: Cleanup

- [ ] Original repro is gone (Phase 1 loop green)
- [ ] Regression test passes, or the missing seam is documented
- [ ] All `[DEBUG-...]` instrumentation removed (grep the prefix)
- [ ] Throwaway prototypes deleted or moved to a marked debug location
- [ ] Confirmed hypothesis stated in the commit or PR message
- [ ] Lesson saved with `memory_lesson_save` (project = `$AGENTMEMORY_PROJECT_NAME` or folder name), text starting with "Fehlersuche: "
