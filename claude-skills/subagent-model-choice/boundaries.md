# Boundaries for subagents

Read this when a subagent works on a live system (server, infrastructure, ticket system, any MCP service) or must stay read-only while it needs whole files or diffs.

## In the brief

- What is allowed and what is not, with examples. For a live system: only reading commands, for example `nft list ruleset` and `docker ps` are allowed, `nft add`, `systemctl restart` or editing files are not.
- When to stop instead of retrying. On an authentication error do not try again (fail2ban may ban the host), report it.
- No secrets, passwords or tokens in the report.
- The result is a proposal. Nothing is applied, the user decides.

A boundary in the brief is only a request. Add a technical boundary where possible (below).

## Technical boundaries

**Agent type.** `Explore` has no file write tools, so for files it is read-only by itself. It can not write a result file, it returns the result in its report, and it reads excerpts, not whole files. It still has Bash and all MCP tools, so on a live system it is not read-only. For read-only work that needs whole diffs or files, such as diff comparisons, use `general-purpose` with the boundary in the brief and a reading copy (see below).

**Shell access.** An SSH (Secure Shell) user without write rights or a read-only API token.

**MCP (Model Context Protocol) tools.** `general-purpose` and `Explore` both get all MCP tools of the session, including writing ones such as `tasks_update`, `labels_delete` or a generic `do_action`. Options, best first:

1. **Fetch the data yourself and hand over a file.** The orchestrator reads with the MCP read tools (for example `tasks_list` page by page) into a JSON file in the scratchpad. The subagent gets only the file path and its brief says it needs no MCP tools. Still only a request, but the agent has no reason to touch the system. Often the cheapest way, and the orchestrator reads the data for checking anyway.
2. **Own agent type with a tool allowlist.** A file `.claude/agents/<name>.md` (project) or `~/.claude/agents/<name>.md` (user) with a `tools:` line that lists only the needed tools, for example `tools: Read, Write, mcp__vikunja__tasks_list, mcp__vikunja__tasks_read, mcp__vikunja__labels_list`. Then call it with `subagent_type: "<name>"`, `model` still works. Agent files are read at session start, so a new one may need a restart or creating it via `/agents`. Worth it for tasks that repeat.
3. **Read-only token** for the MCP server, if the service offers one. Ask the user, never create tokens yourself.

## Reading copy

If the working copy has uncommitted changes of someone else and read-only agents only need a clean state, create a separate detached worktree (`git worktree add --detach ../repo-lesestand <ref>`), name its path in the brief and remove it afterwards.

## Applying the result

Changes to production systems and writing back to live data (labels, comments, status) stay with the orchestrator. Check the proposal, present it, apply it only after the user agrees. Check the rollback path in particular: in practice a Sonnet proposal was sound except for a rollback that would have flushed the firewall completely instead of restoring the old ruleset.
