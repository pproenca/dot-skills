---
title: Use #[from] for automatic error conversion
impact: MEDIUM
impactDescription: Reduces boilerplate for common error conversions
tags: err, thiserror, from
---

# Use #[from] for automatic error conversion

Apply the `#[from]` attribute to error variants for automatic `From` trait implementation. This enables using `?` operator seamlessly.

## Why This Matters

- Eliminates manual `From` impl boilerplate
- Makes `?` operator work automatically
- Cleaner error propagation
- Compile-time guaranteed conversions

**Incorrect (avoid this pattern):**

```rust
#[derive(Debug, Error)
pub enum MyError {
    #[error("IO error: {0}")
    Io(std::io::Error),
}

// Manual From impl - verbose
impl From<std::io::Error> for MyError {
    fn from(e: std::io::Error) -> Self {
        MyError::Io(e)
    }
}
```

**Correct (recommended):**

```rust
use thiserror::Error;

#[derive(Debug, Error)
pub enum MyError {
    #[error(transparent)
    Io(#[from] std::io::Error),

    #[error(transparent)
    Json(#[from] serde_json::Error),

    #[error("request failed")
    Request(#[from] reqwest::Error),
}

// Now ? operator works automatically
fn load_data(path: &Path) -> Result<Data, MyError> {
    let content = fs::read_to_string(path)?; // auto-converts io::Error
    let data = serde_json::from_str(&content)?; // auto-converts serde_json::Error
    Ok(data)
}
```

## With #[error(transparent)

Use `#[error(transparent)]` when the wrapped error's message is sufficient:

```rust
#[error(transparent)
Io(#[from] std::io::Error),
// Display shows: "No such file or directory (os error 2)"

#[error("failed to parse config")
Parse(#[from] toml::de::Error),
// Display shows: "failed to parse config"
```
