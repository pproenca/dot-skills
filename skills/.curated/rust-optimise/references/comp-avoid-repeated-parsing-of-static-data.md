---
title: Avoid Repeated Parsing of Static Data
impact: MEDIUM
impactDescription: 100-1000× speedup for repeated operations
tags: comp, lazy_static, once_cell, parsing, initialization
---

## Avoid Repeated Parsing of Static Data

For data that's parsed from strings (regexes, config) but never changes, parse once at startup using `OnceLock` or `LazyLock`.

**Incorrect (parses regex on every call):**

```rust
use regex::Regex;

fn is_valid_email(email: &str) -> bool {
    let re = Regex::new(r"^[\w.+-]+@[\w.-]+\.\w{2,}$").unwrap();  // Compiles every call
    re.is_match(email)
}
```

**Correct (parses once):**

```rust
use regex::Regex;
use std::sync::LazyLock;

static EMAIL_REGEX: LazyLock<Regex> = LazyLock::new(|| {
    Regex::new(r"^[\w.+-]+@[\w.-]+\.\w{2,}$").unwrap()
});

fn is_valid_email(email: &str) -> bool {
    EMAIL_REGEX.is_match(email)  // Reuses compiled regex
}
```

**For fallible initialization:**

```rust
use std::sync::OnceLock;

static CONFIG: OnceLock<Config> = OnceLock::new();

fn get_config() -> &'static Config {
    CONFIG.get_or_init(|| {
        load_config_from_file().expect("Failed to load config")
    })
}
```

**Note:** `LazyLock` was stabilized in Rust 1.80. For older versions, use the `once_cell` or `lazy_static` crates.

Reference: [std::sync::LazyLock documentation](https://doc.rust-lang.org/std/sync/struct.LazyLock.html)
