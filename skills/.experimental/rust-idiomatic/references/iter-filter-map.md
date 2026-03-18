---
title: Use filter_map Instead of filter Then map
impact: HIGH
impactDescription: single pass instead of two, handles Option unwrapping cleanly
tags: iter, filter-map, combinators, option, readability
---

## Use filter_map Instead of filter Then map

Use `.filter_map()` when you need to both filter and transform in one step. This avoids a separate `.filter()` followed by `.map()` and naturally handles the `Option` returned by fallible transformations.

**Incorrect (filter then map, double iteration logic):**

```rust
fn parse_enabled_flags(entries: &BTreeMap<String, bool>) -> Vec<Feature> {
    entries
        .iter()
        .filter(|(_, enabled)| **enabled)
        .map(|(key, _)| feature_for_key(key))
        .filter(|f| f.is_some())
        .map(|f| f.unwrap())
        .collect()
}
```

**Correct (filter_map combines filtering and transformation):**

```rust
fn parse_enabled_flags(entries: &BTreeMap<String, bool>) -> Vec<Feature> {
    entries
        .iter()
        .filter(|(_, enabled)| **enabled)
        .filter_map(|(key, _)| feature_for_key(key))
        .collect()
}
```
