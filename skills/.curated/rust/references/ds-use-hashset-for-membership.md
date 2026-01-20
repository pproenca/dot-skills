---
title: Use HashSet for Membership Tests
impact: HIGH
impactDescription: O(n) to O(1) per lookup
tags: ds, hashset, lookup, membership, performance
---

## Use HashSet for Membership Tests

Replace `Vec::contains()` with `HashSet::contains()` when performing repeated membership tests. Vec scans linearly; HashSet uses hashing.

**Incorrect (O(n) per check):**

```rust
fn filter_allowed_users(users: &[User], allowed_ids: &[u64]) -> Vec<&User> {
    users
        .iter()
        .filter(|u| allowed_ids.contains(&u.id))  // O(n) per user
        .collect()
}
```

**Correct (O(1) per check):**

```rust
use std::collections::HashSet;

fn filter_allowed_users(users: &[User], allowed_ids: &[u64]) -> Vec<&User> {
    let allowed: HashSet<_> = allowed_ids.iter().collect();
    users
        .iter()
        .filter(|u| allowed.contains(&u.id))  // O(1) per user
        .collect()
}
```

**When to use Vec instead:**
- Very small collections (< 10 elements)
- Elements are not `Hash` + `Eq`
- Insertion order matters

Reference: [The Rust Performance Book - Hashing](https://nnethercote.github.io/perf-book/hashing.html)
