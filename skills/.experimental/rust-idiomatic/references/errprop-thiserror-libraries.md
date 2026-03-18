---
title: Use thiserror for Library Error Definitions
impact: CRITICAL
impactDescription: 2-3x less boilerplate per error enum
tags: errprop, thiserror, library, derive, error-types
---

## Use thiserror for Library Error Definitions

Use the `thiserror` crate to derive `Error`, `Display`, and `From` implementations for library error types. Manual implementations are verbose, error-prone, and drift out of sync with the actual variants.

**Incorrect (manual Display and From, 40+ lines of boilerplate):**

```rust
#[derive(Debug)]
pub enum SandboxError {
    Denied(ExecOutput),
    Timeout(ExecOutput),
    Signal(i32),
}

impl std::fmt::Display for SandboxError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Denied(o) => write!(f, "sandbox denied: {}", o.stderr),
            Self::Timeout(o) => write!(f, "timeout: {}ms", o.duration_ms),
            Self::Signal(s) => write!(f, "killed by signal {s}"),
        }
    }
}

impl std::error::Error for SandboxError {}
```

**Correct (thiserror derives everything):**

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum SandboxError {
    #[error("sandbox denied exec, exit code: {}", .0.exit_code)]
    Denied(ExecOutput),
    #[error("command timed out")]
    Timeout(ExecOutput),
    #[error("command killed by signal {0}")]
    Signal(i32),
}
```
