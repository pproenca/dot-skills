---
title: Define Domain-Specific Error Variants
impact: CRITICAL
impactDescription: enables precise error matching and retryability checking
tags: err, thiserror, error-enum, domain-errors
---

## Define Domain-Specific Error Variants

The `CodexErr` enum in `codex-rs/core/src/error.rs` uses domain-specific variants with structured data instead of generic string errors. Each variant carries the data needed for error handling decisions (retryability, UI messages, status codes). Adding a new error case means adding a new variant, not wrapping a string.

**Incorrect (opaque string error prevents programmatic handling):**

```rust
fn handle_response(status: StatusCode) -> Result<()> {
    if status == StatusCode::TOO_MANY_REQUESTS {
        return Err(anyhow!("rate limited"));
    }
    if status == StatusCode::INTERNAL_SERVER_ERROR {
        return Err(anyhow!("server error"));
    }
    Ok(())
}
```

**Correct (structured variants enable retryability and UI logic):**

```rust
#[derive(Error, Debug)]
pub enum CodexErr {
    #[error("exceeded retry limit, last status: {}", .status)]
    RetryLimit(RetryLimitReachedError),

    #[error("We're currently experiencing high demand.")]
    InternalServerError,

    #[error("{0}")]
    UsageLimitReached(UsageLimitReachedError),
}

impl CodexErr {
    pub fn is_retryable(&self) -> bool {
        match self {
            CodexErr::RetryLimit(_) => false,
            CodexErr::InternalServerError => true,
            CodexErr::UsageLimitReached(_) => false,
            // ...
        }
    }
}
```
