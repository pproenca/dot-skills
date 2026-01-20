---
title: Implement Default Instead of new() Without Arguments
impact: MEDIUM
impactDescription: enables derive(Default) propagation, reduces manual initialization
tags: idiom, default, constructor, derive, convention
---

## Implement Default Instead of new() Without Arguments

When a type has a sensible default state, implement `Default` rather than just `fn new()`. This enables derive macros and standard library integration.

**Incorrect (only new(), misses ecosystem integration):**

```rust
pub struct Config {
    pub timeout_ms: u64,
    pub retries: u32,
    pub verbose: bool,
}

impl Config {
    pub fn new() -> Self {
        Config {
            timeout_ms: 30_000,
            retries: 3,
            verbose: false,
        }
    }
}

// Can't use #[derive(Default)] on types containing Config
// #[derive(Default)]
// struct App { config: Config }  // Error!
```

**Correct (implement Default):**

```rust
#[derive(Default)]
pub struct Config {
    #[default = 30_000]
    pub timeout_ms: u64,
    pub retries: u32,  // defaults to 0
    pub verbose: bool, // defaults to false
}

// Or manually for custom defaults
impl Default for Config {
    fn default() -> Self {
        Config {
            timeout_ms: 30_000,
            retries: 3,
            verbose: false,
        }
    }
}

// Now works with derive
#[derive(Default)]
struct App {
    config: Config,  // Uses Config::default()
    name: String,
}

// And with struct update syntax
let config = Config {
    verbose: true,
    ..Default::default()
};
```

**Convention:** Provide both `new()` and `Default` when `new()` takes no arguments:

```rust
impl Config {
    pub fn new() -> Self {
        Self::default()
    }
}
```

Reference: [Default - Rust Standard Library](https://doc.rust-lang.org/std/default/trait.Default.html)
