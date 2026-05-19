---
title: Define a Blocked Stop Condition — What to Report When No Defensible Path Remains
impact: HIGH
impactDescription: prevents Codex from declaring false completion or spinning when the real answer is "stuck"
tags: bound, blocked, stop-condition, reporting
---

## Define a Blocked Stop Condition — What to Report When No Defensible Path Remains

Sometimes Codex cannot complete a Goal — the data is unavailable, the benchmark is broken, the required API doesn't exist, the change would violate the constraints. The Goal must tell Codex what to do in that case. Without a blocked stop condition, Codex either declares completion against a proxy (hiding the failure) or loops trying weaker and weaker fixes. Spell out the stop contract: under what conditions to stop, what evidence to gather before stopping, and what the user needs to unblock progress. "Blocked" is a valid Goal terminal state — when it's the truthful one, surfacing it is the highest-value action Codex can take.

**Incorrect (no blocked stop condition):**

```text
/goal Reduce p95 checkout latency below 120 ms on bench/checkout
while keeping the correctness suite green
```

```text
# If the only path to <120 ms requires a database index Codex cannot
# create, Codex may either keep trying weaker fixes that can't reach
# the target or "improve" something and declare progress. The user
# never learns the actual blocker.
```

**Correct (blocked stop condition stated):**

```text
/goal Reduce p95 checkout latency below 120 ms on bench/checkout
while keeping the correctness suite green. Use only services/checkout/**.

If blocked or no valid paths remain inside the boundary:
1. Stop substantive work.
2. Report:
   - Paths attempted (with iteration log entries).
   - Best result achieved (latency, error rate).
   - The blocker (what specifically prevents further progress).
   - The next input needed to unblock (a permission, a credential,
     a constraint relaxation, a boundary expansion, a missing tool).
3. Do not declare the Goal complete and do not continue iterating
   inside the boundary if you've exhausted the search space.
```

```text
# Codex has a defined off-ramp. The user gets a structured blocker
# report instead of a fake "done" or an indefinite spin.
```

Reference: [Using Goals in Codex — How to write a Goal](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
