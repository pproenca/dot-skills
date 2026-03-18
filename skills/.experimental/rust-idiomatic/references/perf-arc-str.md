---
title: Use Arc str Over Arc String for Shared Strings
impact: LOW-MEDIUM
impactDescription: saves 24 bytes per shared string, one fewer indirection
tags: perf, arc, string, shared, memory
---

## Use Arc str Over Arc String for Shared Strings

Use `Arc<str>` instead of `Arc<String>` for immutable shared strings. `Arc<String>` stores the Arc header, a String struct (pointer + length + capacity), and the heap buffer. `Arc<str>` stores the Arc header and the string bytes inline, saving one heap allocation and one level of indirection.

**Incorrect (double indirection: Arc -> String -> heap bytes):**

```rust
struct FeatureRegistry {
    descriptions: BTreeMap<String, Arc<String>>,
}

fn register(registry: &mut FeatureRegistry, key: String, desc: String) {
    registry.descriptions.insert(key, Arc::new(desc));
}
```

**Correct (single indirection: Arc -> inline str bytes):**

```rust
struct FeatureRegistry {
    descriptions: BTreeMap<String, Arc<str>>,
}

fn register(registry: &mut FeatureRegistry, key: String, desc: String) {
    registry.descriptions.insert(key, Arc::from(desc));
}
```
