---
title: Prefer BTreeMap for Deterministic Output
impact: CRITICAL
impactDescription: eliminates nondeterministic serialization in configs and snapshots
tags: type, btreemap, determinism, serialization
---

## Prefer BTreeMap for Deterministic Output

Use `BTreeMap` instead of `HashMap` when the map will be serialized, logged, or compared in tests. `BTreeMap` iterates in sorted key order, producing deterministic output. `HashMap` iteration order is random, causing flaky tests and non-reproducible configs.

**Incorrect (nondeterministic iteration order):**

```rust
use std::collections::HashMap;

#[derive(Serialize, Deserialize)]
pub struct FeaturesToml {
    #[serde(flatten)]
    pub entries: HashMap<String, bool>,
}
// Serialized output order changes between runs
```

**Correct (stable, sorted key order):**

```rust
use std::collections::BTreeMap;

#[derive(Serialize, Deserialize)]
pub struct FeaturesToml {
    #[serde(flatten)]
    pub entries: BTreeMap<String, bool>,
}
// Serialized output is always alphabetically ordered
```
