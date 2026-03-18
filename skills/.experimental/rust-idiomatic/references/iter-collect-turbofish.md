---
title: Use Turbofish on collect for Clarity
impact: HIGH
impactDescription: eliminates type inference ambiguity, makes target collection explicit
tags: iter, collect, turbofish, type-inference, readability
---

## Use Turbofish on collect for Clarity

When the target collection type is not obvious from context, use turbofish syntax (`::<>`) on `.collect()` or annotate the binding. This prevents cryptic "type annotations needed" compiler errors and makes the intended collection type clear to readers.

**Incorrect (ambiguous type, compiler cannot infer):**

```rust
fn enabled_keys(features: &Features) -> impl Iterator<Item = &str> {
    let keys = features
        .enabled_features()
        .iter()
        .map(Feature::key)
        .collect(); // Error: cannot infer type
    keys.into_iter()
}
```

**Correct (explicit turbofish on collect):**

```rust
fn enabled_keys(features: &Features) -> Vec<&str> {
    features
        .enabled_features()
        .iter()
        .map(Feature::key)
        .collect::<Vec<_>>()
}
```
