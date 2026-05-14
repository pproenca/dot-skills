---
title: Define Three Mutation Statuses
impact: HIGH
impactDescription: wrong status assignment misclassifies mutations, corrupting kill rate by up to 100% and misleading developers into false confidence
tags: result, status, killed, survived, error, classification
---

## Result Statuses

Every mutation has exactly one of three statuses. These statuses are the output of the entire mutation testing pipeline — they tell the developer whether their acceptance tests are strong enough.

### Spec Requirements

| Status | Meaning |
|--------|---------|
| **killed** | Generated tests **failed** after the mutation was applied |
| **survived** | Generated tests **passed** after the mutation was applied |
| **error** | Parsing, IR writing, generation, timeout, runner startup, or infrastructure **failed** |

### What Each Status Means for Test Quality

**Killed** is the desired outcome. It means the acceptance tests detected the changed specification value. The test is connected to the application behavior it claims to verify.

**Survived** means the acceptance tests did **not** detect the changed specification value. This should be investigated — it usually indicates a gap in assertions, a loose match, or a handler that ignores the value.

**Error** is not a test-quality result. It means the mutation could not be evaluated reliably. The infrastructure needs fixing before the mutation can be classified as killed or survived.

### Why Three Statuses, Not Two

A two-status model (killed/survived) would force infrastructure failures into one of those categories. Classifying a generator crash as "killed" inflates test quality metrics. Classifying it as "survived" creates false alarms. Neither is honest.

The three-status model keeps the mutation report trustworthy: killed and survived counts reflect actual test behavior, and error counts reflect infrastructure health.

### Examples

**Incorrect (two-status model -- infrastructure failures classified as killed):**

```json
{
  "results": [
    {
      "Mutation": { "ID": "m1", "Description": "$.scenarios[0].examples[0].count: 20 -> 27" },
      "Status": "killed",
      "Error": "generator crashed: template not found"
    }
  ]
}
```

**Correct (three-status model -- infrastructure failures classified as error):**

```json
{
  "results": [
    {
      "Mutation": { "ID": "m1", "Description": "$.scenarios[0].examples[0].count: 20 -> 27" },
      "Status": "error",
      "Error": "generator crashed: template not found"
    }
  ]
}
```

### Why This Matters

The mutation report is only useful if the statuses are accurate. Developers make decisions based on these numbers: "3 survived, let me investigate" or "all killed, tests are strong." Wrong classification leads to wrong decisions — either false confidence (ignoring real gaps) or wasted investigation (chasing phantom gaps).
