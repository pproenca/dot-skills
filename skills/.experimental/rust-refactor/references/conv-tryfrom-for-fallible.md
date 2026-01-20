---
title: Use TryFrom for Fallible Conversions
impact: MEDIUM
impactDescription: prevents panic on invalid input, enables graceful handling
tags: conv, tryfrom, fallible, validation, result
---

## Use TryFrom for Fallible Conversions

Use `TryFrom` when conversion can fail. Unlike `From`, it returns `Result` allowing callers to handle failures.

**Incorrect (From panics on invalid input):**

```rust
struct PositiveInt(u32);

impl From<i32> for PositiveInt {
    fn from(value: i32) -> Self {
        if value < 0 {
            panic!("Value must be positive");  // Crash on invalid input
        }
        PositiveInt(value as u32)
    }
}
```

**Correct (TryFrom returns Result):**

```rust
use std::convert::TryFrom;

struct PositiveInt(u32);

#[derive(Debug)]
struct NegativeValueError;

impl TryFrom<i32> for PositiveInt {
    type Error = NegativeValueError;

    fn try_from(value: i32) -> Result<Self, Self::Error> {
        if value < 0 {
            Err(NegativeValueError)
        } else {
            Ok(PositiveInt(value as u32))
        }
    }
}

fn main() {
    // Caller decides how to handle failure
    match PositiveInt::try_from(-5) {
        Ok(n) => println!("Got positive: {}", n.0),
        Err(_) => println!("Invalid negative value"),
    }

    // Or use ? operator
    let n = PositiveInt::try_from(42)?;
}
```

**Common TryFrom use cases:**
- Numeric conversions that might overflow
- String parsing with validation
- Creating validated domain types

**Note:** `TryFrom<T>` automatically provides `TryInto<U>`, just like `From`/`Into`.

Reference: [TryFrom - Rust Standard Library](https://doc.rust-lang.org/std/convert/trait.TryFrom.html)
