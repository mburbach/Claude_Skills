#!/usr/bin/env bash
# Human-in-the-loop (HITL) reproduction loop.
# Adapted from github.com/mattpocock/skills (MIT license).
#
# The agent's Bash tool has no stdin, so the interactive prompts below cannot
# run there. The user runs this script themselves (in Claude Code via
# `! bash <path>`, otherwise in their own terminal). The captured KEY=VALUE
# lines end up in the conversation, where the agent reads them.
#
# Copy this file to a scratch location, edit the steps below, then run it:
#   bash hitl-loop.template.sh
#
# Two helpers:
#   step "<instruction>"          show instruction, wait for Enter
#   capture VAR "<question>"      show question, read response into VAR
#
# `capture` prints its value back to the terminal, so capture observations
# only. Signing in belongs in a `step`. Never capture secrets.

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Enter when done] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- edit below ---------------------------------------------------------

step "Open the app at http://localhost:3000 and sign in."

capture ERRORED "Click the 'Export' button. Did it throw an error? (y/n)"

capture ERROR_MSG "Paste the error message (or 'none'):"

# --- edit above ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
