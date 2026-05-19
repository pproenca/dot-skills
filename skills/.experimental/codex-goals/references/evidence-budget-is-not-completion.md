---
title: Reaching the Budget Limit Is Not the Same as Completing the Objective
impact: HIGH
impactDescription: prevents overstating progress by collapsing budget-limited into complete
tags: evidence, budget, completion, distinction
---

## Reaching the Budget Limit Is Not the Same as Completing the Objective

A Goal has two distinct terminal states the user must keep separate: complete (the evidence shows the outcome is true) and budget-limited (Codex ran out of authorized iterations or cost ceiling without reaching completion). These look superficially similar — both end with Codex stopping — but their meanings are opposite. Completion means the contract was satisfied. Budget exhaustion means the contract was not satisfied within the authorized cost. Treating budget exhaustion as completion silently overstates progress. The Goals architecture treats them as separate states for exactly this reason; honor the distinction in the user-facing summary. When budget is reached, the right action is to summarize progress, identify what would unblock further progress, and let the user decide whether to extend, pause, or close.

**Incorrect (collapsing budget-limited into complete):**

```text
[Budget reached at iteration 12; latency Goal not satisfied]
Codex: "Goal complete. Latency reduced from 180 ms to 145 ms."
```

```text
# Target was < 120 ms. 145 ms is not complete. The "complete" label
# misrepresents the state to anyone reading the log later.
```

**Correct (budget-limited stated as its own terminal state):**

```text
[Budget reached at iteration 12; latency Goal not satisfied]
Codex: "Goal state: budget-limited (not complete).

Best result: p95 = 145 ms (target < 120 ms).
Constraints honored: correctness suite green, API unchanged.

To reach the target, the next iterations would need:
- Index change in shared/db (currently outside boundary), or
- Caching layer in services/checkout/cache (estimated 2 more iterations)

Recommend: extend budget by 5 iterations with caching path, or expand
boundary to allow the index change, or close the Goal at this
partial improvement."
```

```text
# "Budget-limited (not complete)" is unambiguous. The user can choose
# the next step from real options instead of inheriting a "done" label
# that hides the gap.
```

Reference: [Using Goals in Codex — How Goals are designed in Codex](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
