---
title: Avoid Unnecessary Clone Calls
impact: CRITICAL
impactDescription: eliminates O(n) allocations in hot paths
tags: own, clone, performance, allocation, borrowing
---

## Avoid Unnecessary Clone Calls

Remove `.clone()` calls that exist only to satisfy the borrow checker when restructuring code can avoid them.

**Incorrect (clone to avoid borrow checker):**

```rust
fn process_users(users: &mut Vec<User>) {
    for user in users.clone() {  // O(n) clone of entire vector
        if user.is_active {
            users.retain(|u| u.id != user.id);  // Mutate original
        }
    }
}
```

**Correct (restructure to avoid clone):**

```rust
fn process_users(users: &mut Vec<User>) {
    // Collect IDs to remove first, then remove in one pass
    let ids_to_remove: Vec<_> = users
        .iter()
        .filter(|u| u.is_active)
        .map(|u| u.id)
        .collect();

    users.retain(|u| !ids_to_remove.contains(&u.id));
}
```

**Alternative (drain_filter when available):**

```rust
fn process_users(users: &mut Vec<User>) {
    users.retain(|u| !u.is_active);  // Single pass, no clone
}
```

**Common unnecessary clone patterns:**
- Cloning to iterate while mutating - restructure the algorithm
- Cloning strings for format! - use references in format string
- Cloning to pass to a function - check if function can take reference

**Clippy lint:** `clippy::redundant_clone` catches some cases automatically.

Reference: [Clippy - redundant_clone](https://rust-lang.github.io/rust-clippy/master/index.html#redundant_clone)
