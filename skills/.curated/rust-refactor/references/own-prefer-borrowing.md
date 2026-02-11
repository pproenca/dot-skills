---
title: Prefer Borrowing Over Ownership in Function Parameters
impact: CRITICAL
impactDescription: reduces unnecessary clones, enables caller flexibility
tags: own, borrowing, parameters, clone, references
---

## Prefer Borrowing Over Ownership in Function Parameters

Accept references instead of owned values when the function doesn't need ownership. This avoids forcing callers to clone.

**Incorrect (requires ownership, forces clone):**

```rust
fn validate_username(username: String) -> bool {
    username.len() >= 3 && username.chars().all(|c| c.is_alphanumeric())
}

fn main() {
    let username = String::from("alice");
    let is_valid = validate_username(username.clone());  // Unnecessary clone
    println!("Username: {}", username);  // Still need username
}
```

**Correct (borrows, no clone needed):**

```rust
fn validate_username(username: &str) -> bool {
    username.len() >= 3 && username.chars().all(|c| c.is_alphanumeric())
}

fn main() {
    let username = String::from("alice");
    let is_valid = validate_username(&username);  // No clone
    println!("Username: {}", username);  // username still available
}
```

**When to take ownership:**
- Function stores the value (e.g., in a struct field)
- Function passes ownership to another function that requires it
- Taking `&str` and calling `.to_string()` inside anyway

Reference: [Flexibility - Rust API Guidelines](https://rust-lang.github.io/api-guidelines/flexibility.html)
