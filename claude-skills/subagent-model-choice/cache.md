# Prompt cache: 5 minutes or 1 hour

Read this when waits over 5 minutes are expected during an orchestrated task or the orchestrator context is already large. For short delegations it is not needed.

While a subagent runs, the orchestrator makes no requests, and its cache ages from its last request. This holds for foreground and background subagents. If the wait exceeds the cache lifetime, the next orchestrator request rewrites the whole conversation at write price instead of reading it at read price. With a large orchestrator context that is the most expensive moment of the whole task.

## Facts (Claude Code docs, checked 2026-10-30)

- Write with 5 min lifetime costs 1.25x base input, write with 1 h costs 2x. A read costs 0.1x (0.05x on Opus 5.5 and Sonnet 5.5). Every read resets the timer.
- Two separate settings: `promptCacheTtl` (env `CLAUDE_CODE_PROMPT_CACHE_TTL`) for the main conversation, `subagentPromptCacheTtl` (env `CLAUDE_CODE_SUBAGENT_PROMPT_CACHE_TTL`) for subagents. Values `"5m"` or `"1h"`. `ENABLE_PROMPT_CACHING_1H=1` sets both, `FORCE_PROMPT_CACHING_5M=1` overrides everything.
- Defaults: subscription within plan usage has 1 h for the main conversation and 5 min for subagents. API key, cloud provider, or subscription drawing on usage credits has 5 min everywhere unless set explicitly.
- The model cannot change the lifetime of the running session. Whether a change takes effect without restart is not documented. Assume a restart.

## Check

1. Estimate the longest waits. Typical candidates over 5 minutes: a full build with integration tests (Testcontainers, Maven, Gradle), the review skill with a second opinion, a subagent with many slices, and the user thinking or testing between turns.
2. Look up the configured lifetime: `promptCacheTtl` and `subagentPromptCacheTtl` in `~/.claude/settings.json` and the project settings, and the env vars above. Whether the subscription is in overage is not visible from inside. Ask the user if it matters, or point to `/usage`, which shows a line "Prompt cache (main)".
3. Weigh it (below). If 1 h is worth it and not set, recommend it to the user with the reason and the expected waits. Change settings only after the user agrees, via the `update-config` skill, and note that a restart is likely needed.

## Weighing it

- 1 h costs 0.75x extra only on newly written tokens. A miss rewrites the entire context. So one avoided miss on a large orchestrator context usually pays for many turns of extra write cost.
- 1 h is worth it when waits over 5 minutes are expected at least occasionally and the orchestrator context is large (long prompt file, many results collected).
- 5 min is enough when all waits are short (small slices, fast unit tests) or the context is still small.
- Before raising the lifetime, check whether the wait can be cut instead: smaller slices, running only the affected tests in the green step and the full build once per slice.
- Subagent side: a subagent only needs 1 h for itself if it has gaps over 5 minutes between its own requests, for example one long build as a single tool call. Its context is usually small, so this rarely pays off. Do not raise `subagentPromptCacheTtl` to protect the orchestrator, it does not help there.
- Already set to 1 h (main or subagents): leave it, do not suggest reverting it without a concrete reason. If it looks unintended, ask the user briefly whether it is wanted.
