---
title: Restrict Mutation Scope to Example Values
impact: HIGH
impactDescription: mutating the wrong elements produces meaningless mutations that cannot be classified, wasting 100% of compute on non-actionable results
tags: mut, scope, examples, values, boundaries
---

## Restrict Mutation Scope to Example Values

The mutator creates candidate mutations from a precisely defined scope. Understanding what is and is not mutated is essential for both implementing the mutator and interpreting its results.

### Spec Requirements

The mutator **only mutates** example cell values.

The mutator **does not mutate:**
- Feature names
- Scenario names
- Step text
- Step keywords
- Background steps
- Example headers (column names)

### Mutation Enumeration

For each scenario, for each example row, for each example key in **lexicographic order**:

1. Read the original string value.
2. Compute the mutated value using the value mutation rules.
3. If the mutated value is **identical** to the original, skip it.
4. Create one mutation that changes only that **single** example cell.

### Why Only Example Values

Example values are the concrete data that drives acceptance test behavior. If changing an example value does not cause a test failure, it means the test is not actually checking that value — it is disconnected from the application behavior it claims to verify.

Mutating step text would change the specification itself (what the test checks), not the data it checks with. Mutating keywords or names would change labeling, not behavior. Mutating backgrounds would affect all scenarios simultaneously, making it impossible to isolate which test is weak.

### Why Lexicographic Key Order

JSON object key order is not guaranteed. By processing keys in lexicographic order, the mutator produces the same mutation sequence regardless of the JSON library's internal ordering. This ensures stable, deterministic mutation IDs across platforms.

### Examples

**Incorrect (mutates step text and scenario names, producing unclassifiable results):**

```json
{
  "scenarios": [{
    "name": "Mutated Scenario Name",
    "steps": [
      { "keyword": "Given", "text": "the mutated step text" }
    ],
    "examples": [
      { "count": "20", "status": "accepted" }
    ]
  }]
}
```

**Correct (only example cell values are mutated, one cell per mutation):**

```json
{
  "scenarios": [{
    "name": "Verify order count",
    "steps": [
      { "keyword": "Given", "text": "the order has <count> items" }
    ],
    "examples": [
      { "count": "27", "status": "accepted" }
    ]
  }]
}
```

### Why Skip Identical Mutations

Some mutation rules might produce the same value (e.g., dithering a single character that maps back to itself). Including these as mutations would create entries that can never be killed — they would always survive because the IR is unchanged. Skipping them keeps the mutation set meaningful.
