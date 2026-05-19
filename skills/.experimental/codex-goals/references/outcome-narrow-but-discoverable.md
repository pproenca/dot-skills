---
title: Make the Outcome Narrow Enough to Audit, Broad Enough to Allow Discovery
impact: HIGH
impactDescription: prevents both over-narrow Goals that miss the root cause and over-broad Goals with no audit surface
tags: outcome, scope, discovery, root-cause
---

## Make the Outcome Narrow Enough to Audit, Broad Enough to Allow Discovery

Goal scope sits on a spectrum. Too narrow ("fix line 42 of session.ts") blocks discovery — if the real bug is in an upstream dependency, the Goal is unsolvable as stated. Too broad ("improve the whole system") has no audit surface — Codex cannot prove completion. The sweet spot is an outcome that names the user-observable behavior or measurable property while leaving the implementation path open. "Make the checkout test suite pass on the current branch without changing public API behavior" is a strong example: it names what must be true (suite passes, API unchanged), but does not prescribe where the bug is or how to fix it. Codex can investigate, find the actual cause, and verify against the audit surface.

**Incorrect (over-narrow — prescribes the fix location):**

```text
/goal Fix the bug in CheckoutController.processPayment that's making
the integration test fail
```

```text
# If the failure is caused by a stale fixture, a race in the queue
# worker, or an upstream API change, this Goal is unsolvable as stated.
# Codex is constrained to a location that may not contain the bug.
```

**Correct (names the behavior, leaves the path open):**

```text
/goal Make the checkout integration test suite pass on the current
branch without changing the public API behavior of CheckoutController
```

```text
# Audit surface: the test suite.
# Constraint: public API of CheckoutController unchanged.
# Path: open — Codex can investigate fixtures, queue, upstream, or the
# controller itself, and verify any fix against the suite.
```

Reference: [Using Goals in Codex — How to write a Goal](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
