---
title: Classify Runner Outcomes Three Ways
impact: HIGH
impactDescription: conflating failure types produces incorrect mutation results, inflating killed or survived counts by the number of infrastructure-error mutations per run
tags: runner, classification, failure, success, infrastructure-error
---

## Classify Runner Outcomes Three Ways

The test runner must distinguish three outcomes, not just pass/fail. This three-way distinction is essential for accurate mutation classification — conflating infrastructure errors with test failures corrupts the mutation report.

### Spec Requirements

The adapter must distinguish:

| Outcome | Meaning |
|---------|---------|
| **Test failure** | Generated tests ran and at least one failed |
| **Test success** | Generated tests ran and all passed |
| **Infrastructure error** | Tests could not be generated, started, completed, or evaluated |

### Why Three-Way, Not Two-Way

Consider a mutation that produces invalid IR (e.g., an empty string where a number was expected). The generator might fail to produce tests. If this is classified as "killed" (tests failed), the report incorrectly suggests the acceptance tests caught the mutation. If classified as "survived" (tests passed), the report incorrectly suggests a gap in test coverage.

Neither is right. The mutation could not be evaluated, so the correct answer is "error" — try again or investigate the infrastructure.

### Examples of Each

- **Test failure:** Tests ran, assertions failed because the mutated value produced wrong behavior. This is a "killed" mutation — the tests work.
- **Test success:** Tests ran, all assertions passed despite the mutated value. This is a "survived" mutation — the tests need strengthening.
- **Infrastructure error:** Generator crashed on malformed IR, test runner timed out, file system full, test framework not installed. This is an "error" — not a test quality signal.

### Examples

**Incorrect (two-way classification, conflating infrastructure errors with test failures):**

```json
{
  "m1": { "status": "killed" },
  "m2": { "status": "survived" },
  "m3": { "status": "killed" }
}
```

In this two-way model, `m3` was actually a generator crash (infrastructure error), but it is misclassified as "killed."

**Correct (three-way classification distinguishes test failure, test success, and infrastructure error):**

```json
{
  "m1": { "status": "killed" },
  "m2": { "status": "survived" },
  "m3": { "status": "error", "error": "generator crashed on malformed IR" }
}
```

### Why This Matters

The mutator uses this three-way classification directly for result status assignment. Without it, the mutation report would either over-count "killed" (inflating test quality metrics) or over-count "survived" (creating false alarms). Both undermine trust in the mutation testing process.
