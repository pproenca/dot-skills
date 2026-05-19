---
title: Include Constraints That Must Not Regress Alongside the Primary Metric
impact: CRITICAL
impactDescription: prevents Pyrrhic completions where the headline metric improves but something important broke
tags: verify, constraints, regressions, multi-check
---

## Include Constraints That Must Not Regress Alongside the Primary Metric

Most Goals have one outcome metric and one or more constraints — things that must remain true while the metric moves. A latency Goal needs the correctness suite to stay green. A refactor Goal needs the public API to stay unchanged. A docs Goal needs the build to keep passing. Constraints belong inside the Goal text, not in the user's head. If you don't name them, Codex will optimize the primary metric without checking, and you'll get a "complete" Goal that broke production. The pattern is "Achieve X while preserving Y" — both X and Y are checked every iteration, and the Goal completes only when X is true and Y is unviolated.

**Incorrect (metric without constraints):**

```text
/goal Reduce p95 checkout latency below 120 ms
```

```text
# Codex may rip out the correctness checks that were adding latency.
# Latency target hit. Correctness suite now red. Goal "complete".
# This is the classic Pyrrhic completion — the headline passed and
# something else broke.
```

**Correct (metric + named constraints):**

```text
/goal Reduce p95 checkout latency below 120 ms on bench/checkout,
while keeping (1) the correctness suite tests/integration/checkout/**
green, (2) the public CheckoutController API unchanged, and (3) the
error rate on bench/checkout below 0.1%
```

```text
# Every iteration: run benchmark + suite + API diff + error rate.
# Completion only when latency below 120 ms AND all three constraints
# still hold. Trade-offs Codex makes must respect the full contract.
```

Reference: [Using Goals in Codex — Example: performance tuning](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
