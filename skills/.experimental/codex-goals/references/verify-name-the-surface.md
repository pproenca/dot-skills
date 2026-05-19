---
title: Always Name the Verification Surface Inside the Goal
impact: CRITICAL
impactDescription: prevents completion claims grounded in model belief rather than concrete artifacts
tags: verify, evidence, surface, audit
---

## Always Name the Verification Surface Inside the Goal

A verification surface is the concrete thing Codex inspects to decide whether the outcome holds — a test suite, a benchmark, a generated artifact, a command's output, a source document, or a query result. Naming it inside the Goal converts completion from "the model believes it's done" to "the evidence shows it's done". Without a named surface, Codex falls back to its own judgment, which is the failure mode the Goals architecture is specifically designed to eliminate. The surface should be specific enough that two reviewers would agree on whether it passes — not "the tests" but "the checkout benchmark"; not "the docs" but "the page at docs/codex/goals.md as built by the docs build script".

**Incorrect (no verification surface):**

```text
/goal Reduce p95 latency below 120 ms without regressing correctness tests
```

```text
# Which benchmark measures p95 latency? Which suite is "correctness"?
# Codex picks. The user and Codex may not pick the same surfaces, and
# completion against the wrong surface is indistinguishable from
# completion against the right one.
```

**Correct (verification surface named):**

```text
/goal Reduce p95 checkout latency below 120 ms, verified by the
checkout benchmark at bench/checkout, while keeping the correctness
suite (tests/integration/checkout/**) green
```

```text
# Primary verification: bench/checkout output reports p95 < 120 ms.
# Constraint verification: tests/integration/checkout/** all pass.
# Both surfaces are specific paths. Reviewers cannot disagree about
# what Codex must check.
```

Reference: [Using Goals in Codex — How to write a Goal](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
