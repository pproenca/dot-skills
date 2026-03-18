---
title: Prefer Iterator Chaining Over Manual Loops
impact: HIGH
impactDescription: 30-50% fewer lines, enables compiler auto-vectorization
tags: iter, chaining, functional, loops, readability
---

## Prefer Iterator Chaining Over Manual Loops

Replace manual `for` loops that push into a `Vec` with iterator chains (`.map()`, `.filter()`, `.collect()`). Iterator chains are more concise, eliminate mutable accumulator variables, and give the compiler more optimization opportunities.

**Incorrect (manual loop with mutable accumulator):**

```rust
fn active_feature_keys(specs: &[FeatureSpec]) -> Vec<String> {
    let mut result = Vec::new();
    for spec in specs {
        if spec.default_enabled {
            result.push(spec.key.to_string());
        }
    }
    result
}
```

**Correct (iterator chain, no mutable state):**

```rust
fn active_feature_keys(specs: &[FeatureSpec]) -> Vec<String> {
    specs
        .iter()
        .filter(|spec| spec.default_enabled)
        .map(|spec| spec.key.to_string())
        .collect()
}
```
