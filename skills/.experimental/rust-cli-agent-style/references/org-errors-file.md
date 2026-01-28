---
title: Define error types in dedicated errors.rs file
impact: MEDIUM
impactDescription: Centralized error definitions improve discoverability and consistency
tags: org, errors, modules
---

# Define error types in dedicated errors.rs file

Place error type definitions in `errors.rs` or `error.rs` file within the module.

## Why This Matters

- All errors in one discoverable location
- Easy to audit error handling
- Consistent error definitions
- Clear module structure

**Incorrect (errors scattered across files):**

```rust
// src/config/loader.rs
#[derive(Debug, Error)]
pub enum LoadError { /* ... */ }

// src/config/validation.rs
#[derive(Debug, Error)]
pub enum ValidationError { /* ... */ }

// Hard to find all error types!
```

**Correct (errors in dedicated file):**

```text
src/
├── lib.rs
├── errors.rs           # Crate-level errors
└── config/
    ├── mod.rs
    ├── errors.rs       # Config-specific errors
    └── loader.rs
```

```rust
// src/errors.rs
//! Error types for the crate.

use thiserror::Error;

/// The main error type for this crate.
#[derive(Debug, Error)]
pub enum Error {
    #[error("configuration error")]
    Config(#[from] ConfigError),

    #[error("network error")]
    Network(#[from] NetworkError),

    #[error("IO error")]
    Io(#[from] std::io::Error),
}

/// Convenience type alias for Results.
pub type Result<T> = std::result::Result<T, Error>;
```

## Module-Level errors.rs

```rust
// src/config/errors.rs
use thiserror::Error;

#[derive(Debug, Error)]
pub enum ConfigError {
    #[error("failed to read config file: {path}")]
    ReadFailed { path: String, source: std::io::Error },

    #[error("invalid configuration: {0}")]
    Invalid(String),
}
```

## Re-exporting Errors

```rust
// src/lib.rs
mod errors;
pub use errors::{Error, Result};

// src/config/mod.rs
mod errors;
pub use errors::ConfigError;
```
