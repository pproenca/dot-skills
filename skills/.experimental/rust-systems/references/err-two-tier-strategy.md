---
title: Use Two-Tier Error Strategy
impact: HIGH
impactDescription: Separating library and application errors enables both precision and convenience
tags: err, thiserror, anyhow, strategy, architecture
---

## Use Two-Tier Error Strategy

Use `thiserror` for typed errors in library crates and `anyhow` for dynamic errors in application code. This provides type safety where it matters and convenience where it helps.

**Incorrect (problematic pattern):**

```rust
// Using anyhow in library code - loses type information
// lib.rs in a library crate
use anyhow::Result;

pub fn parse_config(s: &str) -> Result<Config> {
    // Callers can't match on specific error types
    // Can't implement Error for downstream crates
}

// Using thiserror in application code - unnecessary verbosity
// main.rs
#[derive(Debug, Error)]
enum AppError {
    #[error("Config: {0}")]
    Config(#[from] config::Error),
    #[error("Database: {0}")]
    Database(#[from] db::Error),
    #[error("Network: {0}")]
    Network(#[from] net::Error),
    // ... 20 more variants for every possible error
}
```

**Correct (recommended pattern):**

```rust
// Library crate: thiserror for typed errors
// procfs/src/lib.rs
use thiserror::Error;

#[derive(Debug, Error)]
pub enum Error {
    #[error("Failed to read {path:?}")]
    ReadError {
        #[source]
        source: std::io::Error,
        path: PathBuf,
    },
    #[error("Parse error in {path:?}: {message}")]
    ParseError { path: PathBuf, message: String },
}

pub type Result<T> = std::result::Result<T, Error>;

// Callers can match on specific errors
pub fn read_stat() -> Result<Stat> { ... }
```

```rust
// Application code: anyhow for convenience
// app/src/main.rs
use anyhow::{Context, Result};

fn main() -> Result<()> {
    let config = load_config()
        .context("Failed to load configuration")?;

    let stats = procfs::read_stat()
        .context("Failed to read /proc/stat")?;

    // anyhow wraps all error types seamlessly
    run_collector(&config, stats)?;

    Ok(())
}
```

**When NOT to use:**
- Tiny single-file utilities (anyhow-only is fine)
- Libraries that need callers to handle specific errors (thiserror-only)
