---
title: Pin Thresholds with Numbers, Not Relative Comparatives
impact: CRITICAL
impactDescription: eliminates the moving target where any positive delta passes for done
tags: outcome, threshold, quantification, numbers
---

## Pin Thresholds with Numbers, Not Relative Comparatives

Comparatives ("faster", "smaller", "fewer") have no termination point — any positive delta technically satisfies them, but no specific delta is enough. Pin the threshold with a number Codex can check absolutely. "Reduce p95 latency" is a direction; "reduce p95 latency below 120 ms" is a target. The difference is whether Codex can declare completion. With a numeric threshold, a benchmark run answers yes or no. Without one, the Goal stays open even after large wins because "could be faster still" is always true. Numbers are how outcomes become auditable.

**Incorrect (comparative without anchor):**

```text
/goal Make checkout faster
```

```text
# 180 ms → 175 ms satisfies "faster". 180 ms → 50 ms also satisfies it.
# Codex has no way to choose between "we improved enough" and "keep going".
# Either it stops too early or it never stops.
```

**Correct (numeric threshold):**

```text
/goal Reduce p95 checkout latency below 120 ms on the checkout
benchmark while keeping the correctness suite green
```

```text
# Threshold: p95 < 120 ms.
# 180 → 135 ms: not done, keep iterating.
# 180 → 118 ms: done (if correctness suite is still green).
# No ambiguity.
```

**When NOT to use this pattern:**

- Outcomes that are inherently boolean or categorical (e.g., "all tests pass", "compilation succeeds") — the threshold is implicit.

Reference: [Using Goals in Codex — Turning a weak Goal into a strong one](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
