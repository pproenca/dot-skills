---
title: Define an Iteration Policy — How Codex Chooses the Next Experiment Between Turns
impact: HIGH
impactDescription: prevents thrashing and preserves learning across iterations via a recorded reasoning trail
tags: bound, iteration, policy, reasoning-trail
---

## Define an Iteration Policy — How Codex Chooses the Next Experiment Between Turns

Between iterations, Codex must decide what to try next. Without instruction, this defaults to "try the next plausible thing", which is fast but throws away the learning from each attempt. An iteration policy tells Codex how to choose the next experiment: record what changed, what the evidence showed, and what the next best step is given the evidence. This produces a reasoning trail that compounds — by iteration 5, Codex has a written history of what was tried, what worked, what didn't, and why. The policy also slows Codex down enough to avoid thrashing on the same hot path with cosmetically different fixes.

**Incorrect (no iteration policy — opaque trial and error):**

```text
/goal Reduce p95 checkout latency below 120 ms on bench/checkout
while keeping the correctness suite green. Use only services/checkout/**.
```

```text
# Codex tries fix A → benchmark → tries fix B → benchmark → tries fix C.
# No record of what each attempt was supposed to test. If it succeeds,
# we don't know which fix mattered. If it fails, we may repeat fixes.
```

**Correct (named iteration policy):**

```text
/goal Reduce p95 checkout latency below 120 ms on bench/checkout
while keeping the correctness suite green. Use only services/checkout/**.

Between iterations:
1. Record what changed (one-line diff summary).
2. Record what the benchmark showed (p95, p99, error rate).
3. Record the hypothesis you're testing and whether it was confirmed.
4. Choose the next experiment based on the highest-impact bottleneck
   in the most recent flamegraph, not on aesthetic improvements.
5. Maintain this log in bench/checkout/iteration-log.md, appending
   one entry per iteration.
```

```text
# Each iteration leaves a written trace. The log is itself an artifact
# the user can review even before the Goal completes. Codex picks the
# next experiment from evidence, not intuition.
```

Reference: [Using Goals in Codex — How to write a Goal](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
