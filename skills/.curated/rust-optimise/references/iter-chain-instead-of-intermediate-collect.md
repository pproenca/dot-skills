---
title: Chain Iterators Instead of Intermediate Collect
impact: HIGH
impactDescription: eliminates intermediate allocations
tags: iter, chain, collect, lazy, allocation
---

## Chain Iterators Instead of Intermediate Collect

Iterator adapters are lazy - they don't allocate until collected. Chaining operations avoids intermediate Vec allocations.

**Incorrect (allocates intermediate Vec):**

```rust
fn get_active_user_emails(users: &[User]) -> Vec<String> {
    let active_users: Vec<_> = users
        .iter()
        .filter(|u| u.is_active)
        .collect();  // Intermediate allocation

    active_users
        .iter()
        .map(|u| u.email.clone())
        .collect()
}
```

**Correct (single pass, no intermediate allocation):**

```rust
fn get_active_user_emails(users: &[User]) -> Vec<String> {
    users
        .iter()
        .filter(|u| u.is_active)
        .map(|u| u.email.clone())
        .collect()  // Single allocation at the end
}
```

**When intermediate collect IS needed:**
- When you need the length before further processing
- When you need to iterate multiple times
- When ownership is required between steps

Reference: [Performance: Loops vs Iterators - The Rust Book](https://doc.rust-lang.org/book/ch13-04-performance.html)
