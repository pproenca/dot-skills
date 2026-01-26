---
title: Use should_panic for Panic Testing
impact: MEDIUM
impactDescription: verifies code panics correctly on invalid input
tags: assert, panic, should-panic, invariants, contracts
---

## Use should_panic for Panic Testing

Use `#[should_panic]` to test that code panics on invalid input. Add `expected` to verify the panic message contains specific text.

**Incorrect (no panic verification):**

```rust
#[test]
fn test_divide_by_zero() {
    // This test would just fail if divide panics
    // But we WANT it to panic!
    let result = std::panic::catch_unwind(|| {
        divide(10, 0)
    });
    assert!(result.is_err());  // Clunky, doesn't check message
}
```

**Correct (should_panic attribute):**

```rust
#[test]
#[should_panic]
fn test_divide_by_zero_panics() {
    divide(10, 0);  // Test passes if this panics
}

#[test]
#[should_panic(expected = "division by zero")]
fn test_divide_by_zero_message() {
    divide(10, 0);  // Passes only if panic message contains "division by zero"
}

#[test]
#[should_panic(expected = "index out of bounds")]
fn test_array_bounds_check() {
    let arr = [1, 2, 3];
    let _ = arr[10];  // Panics with bounds error
}
```

**Testing custom panic messages:**

```rust
impl Config {
    pub fn validate(&self) {
        if self.timeout_ms == 0 {
            panic!("timeout_ms must be positive, got 0");
        }
        if self.max_retries > 100 {
            panic!("max_retries cannot exceed 100, got {}", self.max_retries);
        }
    }
}

#[test]
#[should_panic(expected = "timeout_ms must be positive")]
fn test_zero_timeout_panics() {
    let config = Config { timeout_ms: 0, max_retries: 3 };
    config.validate();
}

#[test]
#[should_panic(expected = "max_retries cannot exceed 100")]
fn test_excessive_retries_panics() {
    let config = Config { timeout_ms: 1000, max_retries: 999 };
    config.validate();
}
```

**When to use should_panic vs Result:**

| Use `#[should_panic]` | Use `Result<T, E>` |
|-----------------------|-------------------|
| Programming errors | Expected errors |
| Invariant violations | User input errors |
| Debug assertions | Recoverable failures |
| Contract violations | IO errors |

**Alternative: catch_unwind for more control:**

```rust
use std::panic;

#[test]
fn test_panic_with_complex_assertion() {
    let result = panic::catch_unwind(|| {
        risky_operation()
    });

    let panic_info = result.unwrap_err();
    let message = panic_info.downcast_ref::<&str>().unwrap();
    assert!(message.contains("specific error condition"));
}
```

Reference: [The Rust Book - Testing for Panics](https://doc.rust-lang.org/book/ch11-01-writing-tests.html#checking-for-panics-with-should_panic)
