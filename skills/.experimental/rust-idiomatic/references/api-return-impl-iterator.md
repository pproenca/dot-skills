---
title: Return impl Iterator Over Collected Vec
impact: MEDIUM
impactDescription: avoids intermediate allocation, enables lazy evaluation
tags: api, iterator, lazy-evaluation, allocation, return-type
---

## Return impl Iterator Over Collected Vec

Return `impl Iterator<Item = T>` instead of `Vec<T>` when the caller does not need random access or the full collection. This avoids allocating and filling a Vec when the caller only needs to iterate, take a prefix, or chain with other iterators.

**Incorrect (allocates Vec even if caller only needs first match):**

```rust
fn experimental_features(features: &Features) -> Vec<&FeatureSpec> {
    FEATURES
        .iter()
        .filter(|spec| matches!(spec.stage, Stage::Experimental { .. }))
        .collect()
}
```

**Correct (lazy iterator, zero allocation):**

```rust
fn experimental_features(features: &Features) -> impl Iterator<Item = &FeatureSpec> {
    FEATURES
        .iter()
        .filter(|spec| matches!(spec.stage, Stage::Experimental { .. }))
}
```

**When NOT to use this pattern:**

- When the caller needs `.len()`, indexing, or multiple passes over the data
- When the iterator borrows from a local variable that would be dropped
