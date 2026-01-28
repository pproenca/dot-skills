---
title: Never use unwrap() in non-test code
impact: CRITICAL
impactDescription: Panics in production code cause crashes and poor user experience
tags: err, unwrap, panic
---

# Never use unwrap() in non-test code

The codebase enforces `#![deny(clippy::unwrap_used)]` at the workspace level. Use proper error handling instead of `unwrap()`.

## Why This Matters

- `unwrap()` panics on `None`/`Err`, crashing the program
- No recovery possible from panics
- Production code must handle all error cases gracefully
- Stack traces from panics are not user-friendly

**Incorrect (avoid this pattern):**

```rust
let value = option.unwrap();
let data = result.unwrap();
let first = vec.first().unwrap();
```

**Correct (recommended):**

```rust
// Option: return error or use default
let value = option.ok_or_else(|| Error::MissingValue)?;
let value = option.unwrap_or_default();
let value = option.unwrap_or(fallback);

// Result: propagate with ?
let data = result?;

// Use if-let for conditional handling
if let Some(first) = vec.first() {
    process(first);
}

// Use expect() only when the invariant is truly guaranteed
// (but prefer returning Result even then)
let value = option.expect("value is always set after init");
```

## Test Code Exception

In test code, `unwrap()` is allowed via `allow_unwrap_in_tests = true` in clippy.toml:

```rust
#[cfg(test)
mod tests {
    #[test
    fn test_something() {
        let result = do_thing().unwrap(); // OK in tests
        assert_eq!(result, expected);
    }
}
```
