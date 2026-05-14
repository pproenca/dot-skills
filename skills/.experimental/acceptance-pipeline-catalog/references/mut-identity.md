---
title: Assign Stable Deterministic Mutation IDs
impact: HIGH
impactDescription: unstable IDs make mutation results non-reproducible and non-diffable, breaking cross-run comparison for every mutation in the report
tags: mut, identity, id, path, description, deterministic
---

## Assign Stable Deterministic Mutation IDs

Every mutation needs a stable, deterministic identity so that results can be reproduced, diffed across runs, and referenced in discussions. The spec defines three identity components: ID, path, and description.

### Spec Requirements

**Mutation IDs** are sequential and stable for a fixed input IR:

```text
m1
m2
m3
...
```

**Mutation paths** use this format:

```text
$.scenarios[<scenario_index>].examples[<example_index>].<key>
```

- Indexes are **zero-based**.
- Keys are the literal example object keys.

**Mutation descriptions** use:

```text
<path>: <original> -> <mutated>
```

### Example

For a feature with one scenario, two example rows, and a key `count`:

```text
m1  $.scenarios[0].examples[0].count: 20 -> 27
m2  $.scenarios[0].examples[1].count: 5 -> 12
```

### Why Sequential IDs

Sequential IDs (`m1`, `m2`, ...) are compact, sortable, and human-friendly. They are assigned in enumeration order (scenarios by index, example rows by index, keys in lexicographic order), so the same IR always produces the same ID assignment.

### Why JSON Path Notation

The `$.scenarios[i].examples[j].key` format precisely locates the mutation in the IR structure. Developers can use this path to navigate directly to the mutated cell in the IR JSON file, making investigation straightforward.

### Examples

**Incorrect (random UUIDs as mutation IDs, non-reproducible across runs):**

```json
{
  "mutations": [
    { "id": "a3f2-b8c1", "path": "scenarios[0].examples[0].count", "desc": "changed count" },
    { "id": "d7e4-19a0", "path": "scenarios[0].examples[1].count", "desc": "changed count" }
  ]
}
```

**Correct (sequential IDs, JSON-path notation, value-change descriptions):**

```json
{
  "mutations": [
    { "id": "m1", "path": "$.scenarios[0].examples[0].count", "desc": "$.scenarios[0].examples[0].count: 20 -> 27" },
    { "id": "m2", "path": "$.scenarios[0].examples[1].count", "desc": "$.scenarios[0].examples[1].count: 5 -> 12" }
  ]
}
```

### Why This Matters

When a mutation survives, the developer needs to understand exactly what changed and where. The description `$.scenarios[0].examples[0].count: 20 -> 27` tells them: scenario 0, example row 0, the `count` field was changed from `20` to `27`. They can then look at the step handlers for steps that use `<count>` and determine why the test did not catch the change.

Deterministic IDs also enable tracking mutation results over time — if `m3` survived yesterday and is killed today, the fix can be correlated to the code change.
