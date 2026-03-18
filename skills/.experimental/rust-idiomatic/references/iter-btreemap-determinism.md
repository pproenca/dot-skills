---
title: Use BTreeMap for Deterministic Iteration
impact: HIGH
impactDescription: eliminates nondeterministic serialization and flaky test failures
tags: iter, btreemap, determinism, serialization, collections
---

## Use BTreeMap for Deterministic Iteration

Use `BTreeMap` instead of `HashMap` when the map will be serialized, logged, compared in tests, or iterated in user-visible order. `BTreeMap` iterates in sorted key order. `HashMap` iteration is random per run, causing flaky snapshots and non-reproducible configs.

**Incorrect (nondeterministic iteration order):**

```rust
use std::collections::HashMap;

#[derive(Serialize, Deserialize)]
pub struct PermissionsToml {
    #[serde(flatten)]
    pub entries: HashMap<String, PermissionProfile>,
}
// JSON output order changes between runs
```

**Correct (stable, sorted key order):**

```rust
use std::collections::BTreeMap;

#[derive(Serialize, Deserialize)]
pub struct PermissionsToml {
    #[serde(flatten)]
    pub entries: BTreeMap<String, PermissionProfile>,
}
// Output is always alphabetically ordered by key
```
