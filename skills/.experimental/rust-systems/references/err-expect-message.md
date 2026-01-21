---
title: Use expect() with Descriptive Messages
impact: LOW
impactDescription: expect() documents why the unwrap should never fail
tags: err, expect, unwrap, messages
---

## Use expect() with Descriptive Messages

When unwrapping values that should never be None/Err due to prior validation or invariants, use `expect()` with a message explaining why.

**Incorrect (problematic pattern):**

```rust
// Silent unwrap - no context when it panics
let handle = thread::Builder::new()
    .name("worker".to_owned())
    .spawn(move || work())
    .unwrap();

// Cryptic panic message
let value = map.get(&key).unwrap();  // "called unwrap on None value"
```

**Correct (recommended pattern):**

```rust
// Descriptive expect message
let handle = thread::Builder::new()
    .name("worker".to_owned())
    .spawn(move || work())
    .expect("Failed to spawn worker thread");

// Explain why it can't be None
let value = map.get(&key)
    .expect("key must exist: was inserted in initialization");

// After validation
fn process(input: &str) -> Result<Output> {
    // Validate first
    if !input.is_ascii() {
        return Err(Error::InvalidInput);
    }

    // Now we know it's ASCII - expect is justified
    let first_char = input.chars().next()
        .expect("non-empty string after validation");

    // Process...
}
```

```rust
// Prefer ? when possible, expect when you need the value and can't propagate
fn must_have_value() -> &str {
    CONFIG.get("required_key")
        .expect("CONFIG must contain 'required_key' - check initialization")
}

// For lock poisoning (usually unrecoverable anyway)
let guard = mutex.lock()
    .expect("mutex poisoned - another thread panicked while holding lock");
```

**When NOT to use:**
- When the failure is recoverable (use `?` or handle the error)
- In library code where callers should handle errors
- When you can return Option or Result instead
