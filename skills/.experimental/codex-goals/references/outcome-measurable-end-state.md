---
title: State the Outcome as a Measurable End State, Not an Activity
impact: CRITICAL
impactDescription: prevents drift by making every iteration check a boolean condition
tags: outcome, end-state, measurable, anti-aspiration
---

## State the Outcome as a Measurable End State, Not an Activity

A Goal's outcome should describe what is true when the work is done, not what Codex is doing along the way. "Optimize the renderer" describes activity — there is no point at which optimization is provably done. "Reduce render time of the dashboard below 16 ms per frame on the perf harness" describes an end state Codex can check after each iteration. Activity-shaped outcomes drift; end-state outcomes terminate. The test is simple: can you write a single boolean expression that evaluates true the moment the work is done? If yes, the outcome is end-state-shaped. If no, rewrite it.

**Incorrect (activity-shaped):**

```text
/goal Optimize the dashboard renderer for better performance
```

```text
# "Optimize" and "better" are verbs and comparatives. No terminal
# condition. After any improvement, "better" still admits further
# improvement — the Goal never satisfies.
```

**Correct (end-state-shaped):**

```text
/goal Reduce dashboard render time to below 16 ms per frame on the
existing perf harness, measured across the same five fixtures the
harness already uses
```

```text
# Boolean condition: render_time_ms < 16 across all five fixtures.
# Codex runs the harness after each change and checks the condition.
# The Goal terminates the moment the condition holds.
```

Reference: [Using Goals in Codex — How to write a Goal](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
