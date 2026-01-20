---
title: Return Owned Types for Caller Flexibility
impact: CRITICAL
impactDescription: eliminates forced clones when caller needs ownership
tags: own, return-types, ownership, flexibility, api
---

## Return Owned Types for Caller Flexibility

Return owned types like `String` or `Vec<T>` from functions. Callers can always borrow from an owned value, but can't own a borrowed value.

**Incorrect (returns reference, limits caller):**

```rust
struct Config {
    name: String,
}

impl Config {
    // Caller can't take ownership without cloning
    fn get_name(&self) -> &str {
        &self.name
    }
}

fn main() {
    let config = Config { name: "app".to_string() };
    let name = config.get_name();
    // let owned_name: String = config.get_name();  // Can't convert
    let owned_name: String = config.get_name().to_string();  // Must clone
}
```

**Correct (provide both options):**

```rust
struct Config {
    name: String,
}

impl Config {
    // Borrow when caller just needs to read
    fn name(&self) -> &str {
        &self.name
    }

    // Take ownership when caller needs the value
    fn into_name(self) -> String {
        self.name
    }
}

fn main() {
    let config = Config { name: "app".to_string() };
    let name_ref = config.name();  // Borrow

    let config2 = Config { name: "app2".to_string() };
    let owned_name = config2.into_name();  // Take ownership, no clone
}
```

**Naming convention:**
- `fn name(&self) -> &str` - borrows
- `fn into_name(self) -> String` - consumes self, returns owned
- `fn to_name(&self) -> String` - clones and returns owned

Reference: [Rust API Guidelines - Naming](https://rust-lang.github.io/api-guidelines/naming.html)
