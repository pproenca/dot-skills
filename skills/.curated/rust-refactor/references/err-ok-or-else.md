---
title: Use ok_or_else for Expensive Error Construction
impact: LOW
impactDescription: Lazy evaluation prevents allocation when the Option is Some
tags: err, option, ok-or, lazy-evaluation
---

## Use ok_or_else for Expensive Error Construction

Use `ok_or_else()` instead of `ok_or()` when error construction involves allocation or formatting. The closure is only called when needed.

**Incorrect (problematic pattern):**

```rust
// Eager evaluation - always allocates even when Some
fn get_value(key: &str) -> Result<Value, Error> {
    map.get(key)
        .ok_or(Error::NotFound(format!("Key '{}' not found", key)))?
        //     ^^^ format! runs even if map.get returns Some
}

// Clones path even when file exists
fn read_file(path: &Path) -> Result<String, Error> {
    std::fs::metadata(path)
        .ok()
        .ok_or(Error::NotFound(path.to_path_buf()))?;
        //     ^^^ to_path_buf clones even if metadata succeeds
}
```

**Correct (recommended pattern):**

```rust
// Lazy evaluation - only constructs error when None
fn get_value(key: &str) -> Result<Value, Error> {
    map.get(key)
        .ok_or_else(|| Error::NotFound(format!("Key '{}' not found", key)))
        //          ^^^ closure only called if None
}

fn read_file(path: &Path) -> Result<String, Error> {
    std::fs::metadata(path)
        .ok()
        .ok_or_else(|| Error::NotFound(path.to_path_buf()))?;
        //          ^^^ only clones path if metadata failed
}

// ok_or is fine for cheap errors
fn get_simple(opt: Option<i32>) -> Result<i32, &'static str> {
    opt.ok_or("value not found")  // &'static str is cheap
}
```

```rust
// Same pattern applies to unwrap_or vs unwrap_or_else
let value = expensive_option
    .unwrap_or_else(|| compute_expensive_default());

// And or_else for Result
let result = might_fail()
    .or_else(|_| fallback_operation());
```

**When NOT to use:**
- When the error is a static string or zero-sized type
- When the error is already constructed (just use `ok_or`)
