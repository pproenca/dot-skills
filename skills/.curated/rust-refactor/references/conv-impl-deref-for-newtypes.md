---
title: Implement Deref for Transparent Newtype Access
impact: MEDIUM
impactDescription: enables calling inner type methods without explicit unwrapping
tags: conv, deref, newtype, transparency, ergonomics
---

## Implement Deref for Transparent Newtype Access

Implement `Deref` for newtypes to allow transparent access to the inner type's methods. Use sparingly - only when the newtype "is-a" wrapper.

**Incorrect (manual delegation):**

```rust
struct Username(String);

impl Username {
    fn len(&self) -> usize {
        self.0.len()
    }

    fn is_empty(&self) -> bool {
        self.0.is_empty()
    }

    fn to_lowercase(&self) -> String {
        self.0.to_lowercase()
    }
    // Must manually delegate every String method...
}
```

**Correct (Deref provides String methods):**

```rust
use std::ops::Deref;

struct Username(String);

impl Deref for Username {
    type Target = str;

    fn deref(&self) -> &str {
        &self.0
    }
}

fn main() {
    let username = Username("Alice".to_string());

    // All &str methods available via Deref
    println!("Length: {}", username.len());
    println!("Lowercase: {}", username.to_lowercase());
    println!("Contains 'li': {}", username.contains("li"));

    // Can pass where &str is expected
    fn greet(name: &str) { println!("Hello, {}", name); }
    greet(&username);
}
```

**When to implement Deref:**
- Smart pointers (`Box`, `Rc`, `Arc`)
- Transparent wrappers where inner type should be accessible

**When NOT to use Deref:**
- Types with different semantics than inner type
- When you want to hide inner type methods
- Converting between unrelated types (use `From`/`Into` instead)

Reference: [Deref - Rust Book](https://doc.rust-lang.org/book/ch15-02-deref.html)
