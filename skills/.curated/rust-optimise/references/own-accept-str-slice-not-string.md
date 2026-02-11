---
title: Accept &str Instead of &String
impact: CRITICAL
impactDescription: eliminates allocation for &str callers
tags: own, str, string, borrow, deref
---

## Accept &str Instead of &String

Functions accepting `&str` work with `String`, `&str`, string literals, and any type implementing `Deref<Target=str>`. Using `&String` unnecessarily restricts callers.

**Incorrect (forces String allocation):**

```rust
fn validate_username(name: &String) -> bool {
    name.len() >= 3 && name.chars().all(|c| c.is_alphanumeric())
}

fn main() {
    let literal = "alice";
    validate_username(&literal.to_string());  // Forced allocation
}
```

**Correct (accepts any string-like type):**

```rust
fn validate_username(name: &str) -> bool {
    name.len() >= 3 && name.chars().all(|c| c.is_alphanumeric())
}

fn main() {
    let literal = "alice";
    validate_username(literal);  // No allocation

    let owned = String::from("bob");
    validate_username(&owned);  // Deref coercion, no allocation
}
```

**Same principle applies to:**
- `&[T]` instead of `&Vec<T>`
- `&Path` instead of `&PathBuf`
- `&OsStr` instead of `&OsString`

Reference: [Rust API Guidelines - C-CALLER-CONTROL](https://rust-lang.github.io/api-guidelines/flexibility.html)
