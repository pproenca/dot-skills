---
title: Use Non-Exhaustive for Extensible Enums
impact: CRITICAL
impactDescription: enables adding variants without breaking downstream code
tags: type, enum, non-exhaustive, api, evolution
---

## Use Non-Exhaustive for Extensible Enums

Mark public enums with `#[non_exhaustive]` when you may add variants in the future. This prevents downstream code from relying on exhaustive matching.

**Incorrect (adding variant breaks downstream):**

```rust
// In library v1.0
pub enum DatabaseError {
    ConnectionFailed,
    QueryFailed,
}

// Downstream code matches exhaustively
fn handle_error(err: DatabaseError) {
    match err {
        DatabaseError::ConnectionFailed => retry_connection(),
        DatabaseError::QueryFailed => log_query_error(),
    }
}

// In library v2.0 - adding this breaks downstream code!
// pub enum DatabaseError {
//     ConnectionFailed,
//     QueryFailed,
//     TimeoutError,  // Breaking change!
// }
```

**Correct (future-proof with non-exhaustive):**

```rust
// In library v1.0
#[non_exhaustive]
pub enum DatabaseError {
    ConnectionFailed,
    QueryFailed,
}

// Downstream code must handle unknown variants
fn handle_error(err: DatabaseError) {
    match err {
        DatabaseError::ConnectionFailed => retry_connection(),
        DatabaseError::QueryFailed => log_query_error(),
        _ => log_unknown_error(),  // Required by non_exhaustive
    }
}

// In library v2.0 - safe to add!
// #[non_exhaustive]
// pub enum DatabaseError {
//     ConnectionFailed,
//     QueryFailed,
//     TimeoutError,  // Non-breaking addition
// }
```

**When NOT to use:**
- Internal enums that won't be extended
- Enums where exhaustive matching is semantically important

Reference: [Rust API Guidelines - Future Proofing](https://rust-lang.github.io/api-guidelines/future-proofing.html)
