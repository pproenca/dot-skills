---
title: Encode transient vs permanent failures as two enum variants
impact: CRITICAL
impactDescription: prevents boolean retry-policy checks that drift out of sync with the error source
tags: errors, thiserror, retry, auth
---

## Encode transient vs permanent failures as two enum variants

When a failure can be either "log in again" (fatal) or "try in 2s" (retryable), a single error type plus a `fn is_retryable(&self) -> bool` is a refactor hazard — the decision is recomputed at every call site. Codex defines two variants whose names encode the retry policy, not the cause, and implements `From` conversions that explicitly map each variant to the right downstream error kind. The decision is made once, at the lowest level that has the information, and never recomputed.

**Incorrect (one variant, boolean policy decided by callers):**

```rust
pub struct RefreshError {
    pub kind: RefreshErrorKind,
    pub message: String,
}
impl RefreshError {
    pub fn is_retryable(&self) -> bool {
        matches!(self.kind, RefreshErrorKind::Transient)
    }
}
```

**Correct (two variants, conversions decide policy once):**

```rust
// login/src/auth/manager.rs
#[derive(Debug, Error)]
pub enum RefreshTokenError {
    #[error("{0}")]
    Permanent(#[from] RefreshTokenFailedError),
    #[error(transparent)]
    Transient(#[from] std::io::Error),
}

// core/src/client.rs — caller branches once, never recomputes
Err(RefreshTokenError::Permanent(failed)) => {
    Err(CodexErr::RefreshTokenFailed(failed))
}
Err(RefreshTokenError::Transient(other)) => {
    Err(CodexErr::Io(other))
}
```

`Permanent` maps to a dedicated user-facing variant; `Transient` routes through `CodexErr::Io`, which `is_retryable()` reports as `true`. The retry loop handles it automatically — the two paths never need a shared conditional.

Reference: `codex-rs/login/src/auth/manager.rs:88`, `codex-rs/core/src/client.rs:1754`.
