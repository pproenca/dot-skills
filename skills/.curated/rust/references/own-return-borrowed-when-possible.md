---
title: Return Borrowed Data When Possible
impact: CRITICAL
impactDescription: eliminates allocation for accessor methods
tags: own, borrow, lifetime, return, accessor
---

## Return Borrowed Data When Possible

Methods that expose internal data should return references, not clones. Callers who need ownership can clone explicitly.

**Incorrect (clones on every access):**

```rust
struct Config {
    database_url: String,
}

impl Config {
    fn database_url(&self) -> String {
        self.database_url.clone()  // Allocates every call
    }
}

fn main() {
    let config = Config { database_url: String::from("postgres://...") };
    println!("{}", config.database_url());  // Allocates just to print
}
```

**Correct (returns reference):**

```rust
struct Config {
    database_url: String,
}

impl Config {
    fn database_url(&self) -> &str {
        &self.database_url  // No allocation
    }
}

fn main() {
    let config = Config { database_url: String::from("postgres://...") };
    println!("{}", config.database_url());  // No allocation

    // Caller clones only when ownership is needed
    let url_copy = config.database_url().to_string();
}
```

**When to return owned:**
- When the value is computed, not stored
- When the caller almost always needs ownership
- When lifetime constraints make borrowing impractical

Reference: [Rust API Guidelines - C-CALLER-CONTROL](https://rust-lang.github.io/api-guidelines/flexibility.html)
