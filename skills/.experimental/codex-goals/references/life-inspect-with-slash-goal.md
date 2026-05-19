---
title: Use Bare `/goal` to Inspect Current Objective and State Before Continuation
impact: HIGH
impactDescription: prevents surprise about what Codex thinks the active objective is
tags: life, inspect, state, debugging
---

## Use Bare `/goal` to Inspect Current Objective and State Before Continuation

Typing `/goal` with no arguments displays the current Goal — its text, its state (active, paused, complete, budget-limited), and its progress. This is the first thing to do when (a) you resume a thread, (b) Codex's behavior between turns surprises you, or (c) you're about to set a new Goal and want to confirm there isn't one already. The Goal is persisted state — you can't assume it matches your mental model unless you've checked. Inspecting is free; surprises later are not. The same command is also useful as a checkpoint mid-Goal to confirm what Codex is iterating against.

**Incorrect (assuming what the active Goal is without checking):**

```text
[Resume thread from last week]

User: Keep working on the latency Goal
Codex: [Goal in the thread is actually "Cut bundle size below 500 KB",
not latency — Codex starts conflating the two objectives]
```

```text
# The user remembered the wrong Goal. Codex tried to continue against
# the one that's actually stored. Behavior diverges from intent.
```

**Correct (inspect first):**

```text
[Resume thread from last week]

User: /goal
Codex: [shows the currently stored Goal text and its state — the
exact display format varies by Codex version, but the surfaced
information should include the Goal text, its lifecycle state, and
some form of progress indicator]

User: Right — that's still the priority. Continue from the last
iteration.
```

```text
# Inspection corrects the user's memory before action. Codex continues
# against the actual Goal, not a confabulated one.
```

Reference: [Using Goals in Codex — Quickstart](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
