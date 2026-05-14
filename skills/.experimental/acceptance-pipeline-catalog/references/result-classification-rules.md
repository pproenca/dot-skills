---
title: Classify Results from Test Outcomes
impact: HIGH
impactDescription: wrong classification mapping misclassifies mutations, corrupting kill rate by up to 100% and producing incorrect mutation reports
tags: result, classification, rules, mapping, runner-output
---

## Classification Rules

These rules map test runner outcomes to mutation statuses. The mapping must be applied consistently for every mutation — any deviation corrupts the report.

### Spec Requirements

| Runner Outcome | Mutation Status | Rationale |
|----------------|-----------------|-----------|
| Generated tests **failed** | `killed` | Tests detected the mutation |
| Generated tests **passed** | `survived` | Tests did not detect the mutation |
| Parsing failed | `error` | Could not parse feature file |
| IR writing failed | `error` | Could not write mutated IR |
| Generation failed | `error` | Could not generate tests from mutated IR |
| Timeout expired | `error` | Mutation evaluation did not complete |
| Runner startup failed | `error` | Could not invoke the test runner |
| Infrastructure failure | `error` | Any other non-test failure |

### The Key Distinction

The distinction between `killed` and `error` requires understanding **why** the tests failed:

- If the generated tests **ran and produced assertion failures** — that is `killed`. The tests are doing their job.
- If the generated tests **could not be created or started** — that is `error`. The infrastructure failed.

The test runner adapter's three-way output (test failure, test success, infrastructure error) provides exactly this distinction. The classification rules simply map that output to mutation statuses.

### Why This Matters

Consider a mutation that makes the IR invalid for the generator. The generator fails, no tests are created, and no tests run. If this is classified as `killed`, the report claims the tests caught the mutation — but no tests ran. The report would be wrong.

Correct classification ensures the mutation report accurately reflects which mutations were **genuinely caught by tests** (killed), which were **missed by tests** (survived), and which could not be evaluated (error).

### Examples

**Incorrect (generator crash classified as killed -- inflates kill rate):**

```json
{
  "Mutation": { "ID": "m1", "Path": "$.scenarios[0].examples[0].count" },
  "Status": "killed",
  "Error": "generation failed: invalid IR schema",
  "Output": ""
}
```

**Correct (generator crash classified as error -- keeps kill rate honest):**

```json
{
  "Mutation": { "ID": "m1", "Path": "$.scenarios[0].examples[0].count" },
  "Status": "error",
  "Error": "generation failed: invalid IR schema",
  "Output": ""
}
```
