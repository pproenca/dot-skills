---
title: Use filter_map for Combined Filter and Transform
impact: LOW-MEDIUM
impactDescription: reduces iterator chain length, clearer intent
tags: iter, filter-map, option, transformation, chaining
---

## Use filter_map for Combined Filter and Transform

Use `filter_map` when filtering and transforming in one step. It takes a closure returning `Option<T>` and keeps only `Some` values.

**Incorrect (separate filter and map):**

```rust
fn parse_valid_numbers(input: &[&str]) -> Vec<i32> {
    input.iter()
        .map(|s| s.parse::<i32>())
        .filter(|r| r.is_ok())
        .map(|r| r.unwrap())
        .collect()
}

fn get_admin_emails(users: &[User]) -> Vec<String> {
    users.iter()
        .filter(|u| u.role == Role::Admin)
        .filter(|u| u.email.is_some())
        .map(|u| u.email.clone().unwrap())
        .collect()
}
```

**Correct (filter_map combines operations):**

```rust
fn parse_valid_numbers(input: &[&str]) -> Vec<i32> {
    input.iter()
        .filter_map(|s| s.parse::<i32>().ok())
        .collect()
}

fn get_admin_emails(users: &[User]) -> Vec<String> {
    users.iter()
        .filter(|u| u.role == Role::Admin)
        .filter_map(|u| u.email.clone())  // email is Option<String>
        .collect()
}
```

**Common filter_map patterns:**

```rust
// Parse and keep valid
strings.iter().filter_map(|s| s.parse().ok())

// Extract Some values
options.iter().filter_map(|o| o.as_ref())  // or just .flatten()

// Conditional transformation
items.iter().filter_map(|i| {
    if i.is_valid() {
        Some(i.transform())
    } else {
        None
    }
})
```

Reference: [filter_map - Rust Standard Library](https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.filter_map)
