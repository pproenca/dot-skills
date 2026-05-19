---
title: Clear Stale Goals on Resumed Threads
impact: HIGH
impactDescription: prevents Codex from acting on an objective that no longer applies to the current work
tags: life, clear, stale, thread-resume
---

## Clear Stale Goals on Resumed Threads

When you resume a Codex thread that had an active Goal, the Goal comes back with it. That's usually what you want — but not always. If the work has moved on, the original Goal may no longer apply, or its boundary, constraints, or verification surface may now be wrong. Continuing against a stale Goal produces work that looks plausible but is aimed at the wrong target. Make it a habit on resumed threads to run `/goal` first to inspect what's still active, and to clear it with `/goal clear` if it no longer applies. Clearing is not destructive — the thread keeps its history; only the persistent objective is removed.

**Incorrect (continuing a stale Goal on a resumed thread):**

```text
[Resume thread from yesterday]
[Goal still active: Reduce p95 checkout latency below 120 ms]

User: Now I want to add a new feature flag for the recommendations panel
Codex: [reads the message, but the Goal continuation kicks in after
the new feature is added — Codex tries to also optimize the latency
of the new code path because the Goal is still active]
```

```text
# The Goal is irrelevant to the new work but still gates continuation.
# Codex inserts performance work where the user wanted a simple flag.
```

**Correct (inspect, then clear, then start new work):**

```text
[Resume thread from yesterday]

User: /goal
Codex: [displays the active Goal — exact format varies by version,
but typically includes the Goal text and current state such as
active / paused / complete / budget-limited]

User: /goal clear
[Goal cleared]

User: Now I want to add a new feature flag for the recommendations panel
Codex: [handles the new request without persistence machinery from
the previous Goal]
```

```text
# The old Goal is inspected, confirmed irrelevant, and cleared.
# The new work runs cleanly without inherited objectives.
```

Reference: [Using Goals in Codex — Quickstart and lifecycle](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
