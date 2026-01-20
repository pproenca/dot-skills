---
title: Use filter_map for Combined Filter and Map
impact: HIGH
impactDescription: single pass instead of two
tags: iter, filter_map, option, result, transformation
---

## Use filter_map for Combined Filter and Map

When filtering and transforming based on the same condition, `filter_map` combines both into a single pass.

**Incorrect (two passes over data):**

```rust
fn parse_valid_numbers(inputs: &[&str]) -> Vec<i32> {
    inputs
        .iter()
        .filter(|s| s.parse::<i32>().is_ok())  // First pass: check
        .map(|s| s.parse::<i32>().unwrap())     // Second pass: parse again
        .collect()
}
```

**Correct (single pass):**

```rust
fn parse_valid_numbers(inputs: &[&str]) -> Vec<i32> {
    inputs
        .iter()
        .filter_map(|s| s.parse::<i32>().ok())  // Parse once, filter None
        .collect()
}
```

**Also useful for extracting Some values:**

```rust
fn get_user_emails(users: &[User]) -> Vec<&str> {
    users
        .iter()
        .filter_map(|u| u.email.as_deref())  // Extract Some, skip None
        .collect()
}
```

Reference: [Iterator::filter_map documentation](https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.filter_map)
