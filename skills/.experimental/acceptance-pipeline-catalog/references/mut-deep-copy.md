---
title: Deep Copy IR before Each Mutation
impact: HIGH
impactDescription: in-place mutation corrupts the base IR, producing cumulative changes that invalidate every subsequent mutation in the run
tags: mut, deep-copy, isolation, immutability
---

## Deep Copy IR before Each Mutation

Each mutation must be applied to a deep copy of the base IR, never to the original. This is a correctness requirement, not just a best practice — in-place mutation makes the entire mutation set wrong.

### Spec Requirements

The original JSON IR must **not be modified in place**. Each mutation is applied to a **deep copy** of the base IR.

### Why This Is Critical

Consider three mutations: m1 changes `count` in row 0, m2 changes `status` in row 0, m3 changes `count` in row 1.

With in-place mutation:
1. m1 modifies the base IR (changes `count` in row 0).
2. m2 starts from the already-modified IR — now it has **both** m1's change and m2's change.
3. m3 starts from the doubly-modified IR — now it has m1, m2, and m3's changes.

Each mutation was supposed to test a **single** value change. Instead, later mutations test cumulative changes, making their results meaningless. A survived mutation might have been killed if tested in isolation.

### Implementation Notes

Deep copying means:
- All nested objects and arrays must be copied, not just the top-level object.
- String values (which are immutable in most languages) do not need explicit copying.
- The copy must be complete before the mutation is applied.

In most languages, `JSON.parse(JSON.stringify(ir))` or equivalent serialization round-trip achieves a correct deep copy. Language-specific deep copy utilities also work, but be careful of shared references in complex data structures.

### Examples

**Incorrect (mutates IR in place, corrupting subsequent mutations):**

```python
for mutation in mutations:
    # base_ir is modified in place — m2 sees m1's change
    base_ir["scenarios"][mutation.scenario]["examples"][mutation.row][mutation.key] = mutation.value
    result = run_tests(base_ir)
```

**Correct (deep copies IR before each mutation):**

```python
import copy

for mutation in mutations:
    ir_copy = copy.deepcopy(base_ir)
    ir_copy["scenarios"][mutation.scenario]["examples"][mutation.row][mutation.key] = mutation.value
    result = run_tests(ir_copy)
```

### Why This Matters

The mutation model's validity depends on each mutation being **independent**. The report says "mutation m2 survived" — this means "changing only this one cell value was not detected." If the IR was not deep-copied, "only this one cell" is false, and the report is misleading.
