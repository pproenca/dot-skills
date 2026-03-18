---
title: Use LazyLock for Thread-Safe Lazy Initialization
impact: LOW-MEDIUM
impactDescription: O(1) amortized access after one-time initialization
tags: perf, lazy-lock, static, initialization, thread-safety
---

## Use LazyLock for Thread-Safe Lazy Initialization

Use `std::sync::LazyLock` (stable since Rust 1.80) for lazily initialized statics that require runtime computation. It replaces the `lazy_static!` and `once_cell` crates with a standard library solution that is thread-safe and zero-cost after initialization.

**Incorrect (eager initialization or unsafe static mut):**

```rust
static mut REGEX_CACHE: Option<Regex> = None;

fn get_pattern() -> &'static Regex {
    unsafe {
        REGEX_CACHE.get_or_insert_with(|| {
            Regex::new(r"^\d{4}-\d{2}-\d{2}$").unwrap()
        })
    }
}
```

**Correct (LazyLock, safe and zero-cost after init):**

```rust
use std::sync::LazyLock;

static DATE_PATTERN: LazyLock<Regex> = LazyLock::new(|| {
    Regex::new(r"^\d{4}-\d{2}-\d{2}$").expect("date pattern is valid")
});

fn validate_date(input: &str) -> bool {
    DATE_PATTERN.is_match(input)
}
```
