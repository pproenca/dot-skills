---
title: Pause the Goal Before Unrelated Detours, Resume When Returning
impact: HIGH
impactDescription: prevents Codex from continuing toward the Goal while you're context-switching to unrelated work
tags: life, pause, resume, context-switch
---

## Pause the Goal Before Unrelated Detours, Resume When Returning

When you have an active Goal and need to do something unrelated in the same thread — answer a quick question, run a probe, look at unrelated code — pause the Goal with `/goal pause` first. Otherwise, after each unrelated turn completes, Codex may attempt to continue the Goal, applying the persistence machinery to a thread that's no longer focused on the objective. Pausing decouples the side work from the Goal's continuation logic. Resume with `/goal resume` when you're returning to the main objective. The Goal's progress, budget, and iteration log are preserved across the pause — pause is cheap and safe.

**Incorrect (unrelated probe during an active Goal, no pause):**

```text
[Goal active: Reduce p95 latency below 120 ms]

User: Before the next iteration — what's the schema of the
recommendations table?
Codex: [answers the question]
[Goal still active; Codex now attempts to continue iterating on
latency, possibly mixing the side-investigation context into the
next experiment]
```

```text
# Side investigation is now entangled with the latency work. Codex
# may try to optimize the recommendations table because it just looked
# at it, even though the table is outside the Goal's boundary.
```

**Correct (pause for the detour, resume after):**

```text
[Goal active: Reduce p95 latency below 120 ms]

User: /goal pause
[Goal paused]

User: What's the schema of the recommendations table?
Codex: [answers cleanly; no continuation pressure]

User: /goal resume
[Goal resumed — continues iterating on latency from the last state]
```

```text
# The pause draws a hard line between Goal work and side work.
# Codex doesn't carry the side context into the next Goal iteration.
```

Reference: [Using Goals in Codex — Quickstart](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
