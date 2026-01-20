---
title: Use thiserror for Library Error Types
impact: HIGH
impactDescription: reduces boilerplate, provides ergonomic error types for consumers
tags: err, thiserror, library, derive, error-types
---

## Use thiserror for Library Error Types

Use `thiserror` to derive `Error` implementations for library error types. It eliminates boilerplate while providing rich error information.

**Incorrect (manual Error implementation):**

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
enum DatabaseError {
    ConnectionFailed(String),
    QueryFailed { query: String, cause: String },
    NotFound,
}

impl fmt::Display for DatabaseError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::ConnectionFailed(msg) => write!(f, "connection failed: {}", msg),
            Self::QueryFailed { query, cause } => {
                write!(f, "query '{}' failed: {}", query, cause)
            }
            Self::NotFound => write!(f, "record not found"),
        }
    }
}

impl Error for DatabaseError {}
```

**Correct (thiserror derives everything):**

```rust
use thiserror::Error;

#[derive(Debug, Error)]
enum DatabaseError {
    #[error("connection failed: {0}")]
    ConnectionFailed(String),

    #[error("query '{query}' failed: {cause}")]
    QueryFailed { query: String, cause: String },

    #[error("record not found")]
    NotFound,

    #[error("I/O error")]
    Io(#[from] std::io::Error),  // Automatic From impl
}
```

**Benefits:**
- `#[error("...")]` generates `Display` implementation
- `#[from]` generates `From` implementation for automatic conversion
- `#[source]` links error causes for the error chain

Reference: [thiserror crate](https://docs.rs/thiserror)
