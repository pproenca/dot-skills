---
title: Use Method References Over Closures
impact: HIGH
impactDescription: reduces visual noise, Clippy lint redundant_closure_for_method_calls
tags: iter, method-reference, closures, clippy, readability
---

## Use Method References Over Closures

Replace closures that only call a single method with a method reference. Clippy flags `redundant_closure_for_method_calls` and the codebase enforces this lint. Method references are shorter and immediately convey intent.

**Incorrect (redundant closure wrapping a method call):**

```rust
let names: Vec<&str> = features
    .iter()
    .map(|f| f.key())
    .filter(|k| k.is_empty())
    .collect();
```

**Correct (method reference where applicable):**

```rust
let names: Vec<&str> = features
    .iter()
    .map(Feature::key)
    .filter(|k| k.is_empty())
    .collect();
```

**When NOT to use this pattern:**

- When the closure captures additional variables beyond the iterator element
- When the method takes extra arguments besides `self`
