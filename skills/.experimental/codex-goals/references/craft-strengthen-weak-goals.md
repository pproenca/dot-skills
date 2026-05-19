---
title: Strengthen a Weak Goal by Naming the End State, Verification Surface, and Constraints
impact: MEDIUM
impactDescription: enables a repeatable weak-to-strong upgrade path for one-line aspirational Goals
tags: craft, strengthen, weak-to-strong, upgrade
---

## Strengthen a Weak Goal by Naming the End State, Verification Surface, and Constraints

Most weak Goals share the same shape — they name a direction without an end state, or an outcome without evidence, or a metric without a constraint. The fastest upgrade path is the same in every case: explicitly name (a) the end state as a measurable condition, (b) the verification surface that proves it, and (c) the constraints that must not regress. Just doing those three turns most weak Goals into workable ones. The remaining three components (boundaries, iteration policy, blocked stop) take Goals from workable to strong, but the first three are the difference between a Goal that can complete and a Goal that can't.

**Incorrect (weak — direction only):**

```text
/goal Improve performance
```

```text
# Direction without end state. No verification. No constraints.
# The fastest weak Goal to spot — and to fix.
```

**Correct (strengthened — end state + verification + constraint):**

```text
/goal Reduce p95 latency below 120 ms on the checkout benchmark while
keeping the correctness test suite green
```

```text
# End state: p95 < 120 ms.
# Verification: the checkout benchmark.
# Constraint: correctness suite still green.
# Workable. From here, adding boundaries, iteration policy, and a
# blocked stop makes it strong. But this version already terminates
# correctly.
```

**Alternative (same pattern applied to a docs Goal):**

```text
# Weak:
/goal Write docs for this feature

# Strengthened:
/goal Produce a docs page for Goals that explains the lifecycle,
command surface, and two examples. Verify that the page builds
locally and that all referenced commands match the current CLI
behavior.
```

```text
# Same upgrade: end state (docs page exists with named sections),
# verification (builds locally; commands match CLI), constraint
# (commands referenced must be current).
```

Reference: [Using Goals in Codex — Turning a weak Goal into a strong one](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
