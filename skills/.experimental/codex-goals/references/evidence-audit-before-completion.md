---
title: Audit the Objective Against Concrete Evidence Before Marking a Goal Complete
impact: HIGH
impactDescription: prevents completion claims based on model belief rather than verification surface output
tags: evidence, audit, completion, before-complete
---

## Audit the Objective Against Concrete Evidence Before Marking a Goal Complete

A Goal should only be marked complete after the objective has been checked against the relevant files, tests, logs, benchmark output, generated artifacts, or research evidence. Codex's belief that completion is likely is not evidence; only the verification surfaces named in the Goal are. This is the design center of Goals — the architecture lets Codex keep moving across turns, but the evidence decides when it's done. The audit is not optional and not implicit. Before declaring complete, Codex must run the named checks (benchmark, suite, build, query), confirm the result against the Goal's threshold, and confirm constraints are not violated. If any named check is skipped or any constraint is unverified, the Goal is not complete.

**Incorrect (declaring complete on model belief):**

```text
[Iteration 4 of latency Goal]
Codex: "I've applied the database connection pooling fix from
iteration 3 and removed the redundant JSON serialization from
iteration 4. Based on the changes, p95 latency should now be well
below 120 ms. Marking the Goal complete."
```

```text
# "Based on the changes... should now be" is belief, not evidence.
# The benchmark was not run. The correctness suite was not run.
# The "complete" claim is unverified.
```

**Correct (run the verification surfaces, then complete):**

```text
[Iteration 4 of latency Goal]
Codex: "Running named verification surfaces before marking complete.
- bench/checkout (50 runs): p95 = 108 ms ✓ (target < 120 ms)
- tests/integration/checkout/** : 47/47 pass ✓
- error rate: 0.04% ✓ (constraint < 0.1%)
- public CheckoutController API: unchanged ✓ (constraint)
All verification surfaces satisfied. Marking Goal complete."
```

```text
# Every named surface was run. Every threshold and constraint was
# verified. The complete claim is backed by evidence.
```

Reference: [Using Goals in Codex — What changes when a Goal is active](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
