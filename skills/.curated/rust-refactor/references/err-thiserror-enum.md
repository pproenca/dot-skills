---
title: Use thiserror for Custom Error Types
impact: HIGH
impactDescription: thiserror provides automatic Error trait implementation with minimal boilerplate
tags: err, thiserror, error-types, derive
---

## Use thiserror for Custom Error Types

Define domain-specific error types as enums deriving `thiserror::Error`. This provides automatic `Display` and `Error` trait implementations.

**Incorrect (problematic pattern):**

```rust
// Manual implementation - verbose and error-prone
#[derive(Debug)]
pub enum Error {
    IoError(std::io::Error),
    ParseError(String),
    InvalidFormat(PathBuf),
}

impl std::fmt::Display for Error {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Error::IoError(e) => write!(f, "IO error: {}", e),
            Error::ParseError(s) => write!(f, "Parse error: {}", s),
            Error::InvalidFormat(p) => write!(f, "Invalid format: {:?}", p),
        }
    }
}

impl std::error::Error for Error {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            Error::IoError(e) => Some(e),
            _ => None,
        }
    }
}
```

**Correct (recommended pattern):**

```rust
use thiserror::Error;
use std::path::PathBuf;

#[derive(Debug, Error)]
pub enum Error {
    #[error("Invalid file format: {0:?}")]
    InvalidFileFormat(PathBuf),

    #[error("{1:?}: {0}")]
    IoError(#[source] std::io::Error, PathBuf),

    #[error("Parse error in line '{line}' from {path:?}: failed to parse {item} as {type_name}")]
    ParseError {
        line: String,
        item: String,
        type_name: String,
        path: PathBuf,
    },

    #[error("Unexpected line ({1}) in file: {0:?}")]
    UnexpectedLine(PathBuf, String),
}

// Module-local Result alias
pub type Result<T> = std::result::Result<T, Error>;
```

```toml
# Cargo.toml
[dependencies]
thiserror = "2"
```

**When NOT to use:**
- Application-level code (use `anyhow` instead)
- Trivial error cases where `std::io::Error` or similar suffices
