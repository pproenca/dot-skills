---
title: Use Into<T> for Flexible Ownership Transfer
impact: CRITICAL
impactDescription: avoids allocation when caller already owns data
tags: own, into, from, conversion, generic
---

## Use Into<T> for Flexible Ownership Transfer

When a function needs ownership, accept `impl Into<T>` to let callers pass either owned or convertible types. This avoids forcing allocations.

**Incorrect (forces specific type):**

```rust
struct User {
    name: String,
}

impl User {
    fn new(name: String) -> Self {
        Self { name }
    }
}

fn main() {
    let user = User::new("alice".to_string());  // Forced allocation
}
```

**Correct (accepts any convertible type):**

```rust
struct User {
    name: String,
}

impl User {
    fn new(name: impl Into<String>) -> Self {
        Self { name: name.into() }
    }
}

fn main() {
    let user1 = User::new("alice");  // &str converts efficiently
    let user2 = User::new(String::from("bob"));  // String passed through

    let existing = format!("user_{}", 42);
    let user3 = User::new(existing);  // Ownership transferred, no clone
}
```

**Common Into bounds:**
- `impl Into<String>` for string parameters
- `impl Into<PathBuf>` for path parameters
- `impl Into<Vec<T>>` for collection parameters

Reference: [Rust API Guidelines - C-CALLER-CONTROL](https://rust-lang.github.io/api-guidelines/flexibility.html)
