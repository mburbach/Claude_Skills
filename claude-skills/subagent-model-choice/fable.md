# Fable

Read this before suggesting Fable (`model: "fable"`, included in the user's subscription).

- **Only after asking the user.** Before every Fable call, say why Fable and not Opus, what the agent gets and roughly how long it will run, then wait for a yes. This rule holds until the user loosens it. Save a lesson after every Fable run, so the user can later decide on experience.
- **Independent second opinion where a mistake is expensive** (question 5: migrations, security, architecture). Fable checks a proposal from the orchestrator or from Sonnet with fresh context before it is applied. A verifier with fresh context finds more than the author's self-check.
- **Bug hunt where the orchestrator is stuck.** The bug is unclear and two attempts with Opus or Sonnet failed. Fable gets the findings so far and may search the git history.
- Per Anthropic's docs the most capable model, at 2.5 times the token price of Opus. Single runs on hard tasks often take many minutes, so check the prompt cache (`cache.md`). Lower effort is often enough.
- **Brief for Fable:** state goal, context and boundaries, not a step list. Over-prescriptive briefs make its results worse, the opposite of Haiku. Name explicitly what it must not do, since it sometimes takes adjacent actions nobody asked for.
- Not for implementation, green steps, refactors or mechanical work. The TDD pipeline with Haiku and Sonnet is cheaper there and easy to check.
