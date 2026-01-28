---
title: Use thiserror for domain error types
impact: CRITICAL
impactDescription: Consistent error types enable proper error propagation and debugging across the codebase
tags: err, thiserror, domain
---

# Use thiserror for domain error types

Define domain-specific error types using the `thiserror` derive macro. This provides automatic `Display` and `Error` trait implementations with structured error variants.

## Why This Matters

- Compile-time checked error messages
- Automatic `From` implementations with `#[from]`
- Structured error variants enable pattern matching
- Clear error messages for debugging

**Incorrect (avoid this pattern):**

```rust
// String-based errors lose type information
struct MyError(String);

impl std::fmt::Display for MyError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

// Or using anyhow for domain errors
fn parse_config() -> anyhow::Result<Config> {
    // anyhow is for application code, not library code
}
```

**Correct (recommended):**

```rust
use thiserror::Error;

#[derive(Debug, Error)
pub enum ConfigError {
    #[error("failed to read config file: {path}")
    ReadFailed {
        path: PathBuf,
        #[source
        source: std::io::Error,
    },

    #[error("invalid config format: {0}")
    InvalidFormat(String),

    #[error(transparent)
    Io(#[from] std::io::Error),
}

fn parse_config(path: &Path) -> Result<Config, ConfigError> {
    let content = fs::read_to_string(path)
        .map_err(|source| ConfigError::ReadFailed {
            path: path.to_owned(),
            source,
        })?;
    // ...
}
```
