---
title: Use #[error(transparent)] for wrapped errors
impact: MEDIUM
impactDescription: Preserves original error messages when wrapping without additional context
tags: err, thiserror, transparent
---

# Use #[error(transparent)] for wrapped errors

Use the `transparent` attribute when wrapping errors without adding additional context. The wrapped error's Display impl is used directly.

## Why This Matters

- Avoids redundant error messages
- Original error details preserved
- Cleaner error output
- Proper source chain maintained

**Incorrect (avoid this pattern):**

```rust
#[derive(Debug, Error)
pub enum MyError {
    #[error("IO error: {0}")]  // Redundant - io::Error already says "IO error"
    Io(#[from] std::io::Error),

    #[error("JSON error: {0}")]  // Adds noise
    Json(#[from] serde_json::Error),
}
// Output: "IO error: No such file or directory (os error 2)"
```

**Correct (recommended):**

```rust
#[derive(Debug, Error)
pub enum MyError {
    #[error(transparent)
    Io(#[from] std::io::Error),

    #[error(transparent)
    Json(#[from] serde_json::Error),
}
// Output: "No such file or directory (os error 2)"
```

## When NOT to Use Transparent

Add context when the error needs clarification:

```rust
#[derive(Debug, Error)
pub enum ConfigError {
    // transparent - the io::Error is self-explanatory
    #[error(transparent)
    Io(#[from] std::io::Error),

    // NOT transparent - add context about what failed
    #[error("failed to parse config file")
    Parse(#[source] toml::de::Error),

    // Structured variant with context
    #[error("invalid value for {field}: {message}")
    InvalidField { field: String, message: String },
}
```
