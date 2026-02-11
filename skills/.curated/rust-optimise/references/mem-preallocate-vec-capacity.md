---
title: Preallocate Vec Capacity
impact: CRITICAL
impactDescription: reduces allocations by 3-5× for growing vectors
tags: mem, vec, capacity, allocation, with_capacity
---

## Preallocate Vec Capacity

When the final size is known or estimable, use `Vec::with_capacity()` to avoid repeated reallocations during growth. Each reallocation copies all elements.

**Incorrect (multiple reallocations):**

```rust
fn collect_user_ids(users: &[User]) -> Vec<u64> {
    let mut ids = Vec::new();  // Capacity 0
    for user in users {
        ids.push(user.id);  // Reallocates at 0→4→8→16→32...
    }
    ids
}
```

**Correct (single allocation):**

```rust
fn collect_user_ids(users: &[User]) -> Vec<u64> {
    let mut ids = Vec::with_capacity(users.len());  // Exact capacity
    for user in users {
        ids.push(user.id);  // No reallocations
    }
    ids
}
```

**Alternative (iterator collect):**

```rust
fn collect_user_ids(users: &[User]) -> Vec<u64> {
    users.iter().map(|u| u.id).collect()  // Uses size_hint automatically
}
```

The iterator version uses `size_hint()` to preallocate, making it both concise and efficient.

Reference: [Heap Allocations - The Rust Performance Book](https://nnethercote.github.io/perf-book/heap-allocations.html)
