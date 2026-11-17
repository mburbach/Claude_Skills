---
name: grilling
description: Relentless interview in rounds that stress-tests a plan, decision or idea until every branch is settled. Started only by the user with /grilling.
disable-model-invocation: true
---

# Grilling

Interview the user relentlessly until you reach a shared understanding. Adapted from Matt Pocock's skill (github.com/mattpocock/skills).

## Before the first round

Search agentmemory for earlier decisions on the topic: `am-search "<short term>"`, several short keywords. A decision found there is a settled prerequisite. List it at the top of the first round so the user can reopen it.

## Design tree and frontier

Map the plan as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are settled: the questions you can ask now without guessing at answers you have not heard yet. Ask the whole frontier in one round, then wait for the answers. A question whose answer depends on another question still open in this round belongs to a later round.

Each round of answers reshapes the tree. Settled decisions push the frontier outward. Recompute it and ask the next round.

## Round format

Write in the user's language, without dashes or semicolons. Pick the form per round:

- **Selection dialog** (`AskUserQuestion`): the round has at most 4 questions, each with 2 to 4 real alternatives and a reason that fits in one option description. Put your recommendation first, with "(Recommended)" in the label. Make each question stand on its own, chat text above the dialog may be hidden while it is open.
- **Chat text**: everything else. More than 4 questions, long reasoning, or a question with no real alternative where only "ja" or "nein" fits.

Chat text format:

```
❓ **F1: <Titel>**
<Frage, gern über mehrere Absätze, mit Optionen>

➡️ Empfehlung: <deine Empfehlung mit kurzem Grund>

---

❓ **F2: <Titel>**
...
```

Word each question so that "ja" accepts your recommendation. Then a short answer like "F1 ja, F2 Option B" settles the round.

## Facts and decisions

Finding **facts** is your job. When a frontier question needs a fact from code, files, tools or the web, send an `Explore` agent with `model: "haiku"` and a short report format (task type `Recherche` in skill `subagent-model-choice`). Only the questions downstream of a running lookup wait for it. Ask the rest of the frontier now.

**Decisions** belong to the user. Put each one to them and wait.

## Done

The frontier is empty: every branch of the design tree visited, nothing silently assumed. Then:

1. Write the decisions as a numbered list, one line each, plus any points the user left open on purpose.
2. Ask the user to confirm that this is the shared understanding. Correct the list until they do.
3. After confirmation, save the list with `memory_save`, `type` = `decision`, `project` = `$AGENTMEMORY_PROJECT_NAME` or the folder name. Save it also in the project's file memory as a `project` memory.
4. Act on the plan only when the user says so.
