# Workflow for larger coding tasks

Read this when a coding task is split across several subagents. Small single tasks do not need it: implement, check, then a short refactor list, done.

**1. Cut the task.** Split into slices that can be built and tested on their own. Note dependencies, independent slices can run in parallel. If parallel slices share an interface, fix it yourself first, with types and units (see "Parallel agents and follow-up" in `SKILL.md`).

**2. Red: fix the tests first.** Per slice, write the tests yourself or let Sonnet write them from your specification. Check that they fail for the right reason. The understanding of the task lives in these tests.

**3. Green: implement per slice.** Choose the model per slice with the decision questions. Typically Haiku with a full brief. Verify after each slice: build and all tests green, diff matches the brief, tests unchanged.

**4. Escalate on failure.** If a slice fails twice on the same point, sharpen the brief once or move up one model. Fable is the last step and needs the user's yes. Note in a sentence why it failed, this feeds the lessons.

**5. Code review.** When all slices are green, run the review skill the project prescribes (for example `/evidence-code-review`). Confirmed blockers that are bugs are fixed now, by the model that fits the fix.

**6. Collected refactor at the end.** Only now, once for the whole task:
- Go through the diff yourself and list the places that need cleanup: long methods, duplication, unclear names, broken conventions. Add the clean code findings from the review.
- Give each place a concrete target: "extract the loop in `foo()` into `loadAntraegeByMandanten()`", not "make it cleaner".
- Hand the list to Haiku (exact places and target shape) or Sonnet (needs some design freedom). Split by file or area if it is long.
- Tests stay unchanged and must stay green. Check the result yourself.
