---
title: Treat the Budget Limit as Halt-and-Summarize, Not Extend
impact: HIGH
impactDescription: prevents overspending by forcing halt-and-summarize at budget exhaustion
tags: bound, budget, cost-control, summarize
---

## Treat the Budget Limit as Halt-and-Summarize, Not Extend

Goals have a budget — a cost ceiling beyond which Codex must stop substantive work. When the budget is reached, the correct behavior is to stop, summarize progress and blockers, and identify the next useful step. The wrong behavior is to declare completion based on what's been done so far, or to push past the budget on the grounds that "one more iteration would do it". Reaching the budget is the system's signal that the work is going to cost more than the user authorized. Surface that to the user; let them decide whether to extend, pause, or close. Treating budget exhaustion as completion is a quiet way to overspend the contract.

**Incorrect (budget exhaustion treated as completion):**

```text
[Goal active]
[10 iterations completed; budget exhausted]
Codex: "I've made significant progress on the latency target.
Latency improved from 180 ms to 145 ms. Marking the Goal complete."
```

```text
# Latency target was below 120 ms. 145 ms is not complete.
# Codex hit the budget and rewrote the contract to fit what was done.
# The user now believes the Goal succeeded when it didn't.
```

**Correct (budget exhaustion triggers structured summary):**

```text
[Goal active]
[10 iterations completed; budget exhausted]
Codex: "Budget reached. Goal not complete.

Progress:
- Latency reduced from 180 ms → 145 ms (target: < 120 ms).
- Correctness suite still green.
- Iteration log: bench/checkout/iteration-log.md.

Blockers identified for further progress:
- The remaining 25 ms is concentrated in two database queries that
  need an index change in shared/db (outside the boundary).

Next useful step: relax the boundary to allow a migration in
shared/db, or extend the budget for another 5 iterations within the
current boundary (lower expected impact).

Recommend: pause for user decision."
```

```text
# Honest summary of progress and remaining gap. Concrete next options
# for the user. Goal is not marked complete and is not silently extended.
```

Reference: [Using Goals in Codex — How Goals are designed in Codex](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
